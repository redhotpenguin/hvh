package HVH::Bookit;

use strict;
use warnings;

use base qw( CGI::Application );

use HVH ();

use CGI::Application::Plugin::Redirect;
use CGI::Application::Plugin::TT;
use CGI::Application::Plugin::ValidateRM qw( check_rm );

use Data::FormValidator ();
use Data::FormValidator::Constraints qw(:closures);

use Business::PayPal::NVP;
use DateTime        ();
use URI::Escape     ();
use Data::Dumper;

use constant DEBUG => $ENV{HVH_DEBUG} || 0;

my $branch = DEBUG ? 'test' : 'live';

our %Paypal = (
    test => {
        user => 'gunthe_1236035242_biz_api1.yahoo.com',
        pwd  => '1236035264',
        sig  => 'AOkez-Qt58iwz5J-Ge-o4XsPgbKKA3zrI4VO4HHiPGu3RXI0TB7343YC',
    },

    live => {
        user => 'mike_api1.hvh.com',
        pwd  => '5Q2XGE9DZA27EFYL',
        sig  => 'AFcWxV21C7fd0v3bYYYRCpSSRl31AEOrqYMCSxLRpjsqiednmuLG7h7t',
    },
    branch => $branch,
);


# don't touch this
delete $ENV{$_} for grep { /^(HTTPS|SSL)/ } keys %ENV;

# don't touch this either, unless you need to get a new api token
if (DEBUG) {
    $ENV{HTTPS_CERT_FILE} = './conf/cert.pem';

} else {
    $ENV{HTTPS_CERT_FILE} = '/etc/pki/tls/cert.pem';
}

sub setup {
    my $self = shift;
    $self->start_mode('bookit');
    $self->run_modes( [qw( bookit process_booking payment process_payment booked )] );
}

sub cgiapp_init {
    my $self = shift;
    $self->tt_include_path('/var/www/hvh2.hvh.com/tmpl');
}


sub bookit {
    my ($self, $errors) = @_;

    my $prop_id = $self->query->param('prop_id');
    my %tmpl = ( prop_id => $prop_id);
    if ( $errors ) {
	$tmpl{'errors'} = $errors;
    }

    my $prop = HVH->memd->get("property|$prop_id");
    unless ($prop) { # we need to fetch it

	warn("hitting salesforce cache for $prop_id");
	$prop = $self->retrieve_property($prop_id);
        HVH->memd->set("property|$prop_id" => $prop);
    }

    $tmpl{'prop'} = $prop;
    $tmpl{'query'} = $self->query;
    $tmpl{'prop_id'} = $self->query->param('prop_id');
    my $output = $self->tt_process('bookit.tmpl', \%tmpl);

    return $output;
}




sub _payment {
    my ( $self, $q ) = @_;

    my @required = qw( prop_name first_name last_name
      phone checkin_date checkout_date exp_month exp_year
      cvc card_type card_number billing_address billing_city
      billing_state billing_zip billing_country email guests
      first_payment booking_id bktcc_next second_payment
      num_nights local_taxes cleaning_fee nightly_rate deposit
    );

    my %profile = (
        required           => \@required,
        optional           => [qw( )],
        constraint_methods => {
            email           => email(),
            billing_zip     => zip(),
            phone           => phone(),
            first_name      => valid_first(),
            last_name       => valid_last(),
            exp_month       => qr/^\d{2}$/,
            exp_year        => qr/^\d{4}$/,
            cvc             => valid_cvv(),
            billing_city    => valid_city(),
            checkin_date    => valid_date(),
            checkout_date   => valid_date(),
            billing_address => valid_street(),
            card_type       => cc_type(),

            #    card_number     => cc_number( { fields => ['card_type'] } ),
        }
    );
    my $results = Data::FormValidator->check( $q, \%profile );

    my $first_payment  = $q->param('first_payment');
    my $second_payment = $q->param('second_payment');
    my $num_nights     = $q->param('num_nights');
    my $local_taxes    = $q->param('local_taxes');
#   my $cleaning_fee   = $q->param('cleaning_fee');
    my $cleaning_fee   = "0.00";
    my $nightly_rate   = $q->param('nightly_rate');
#   my $deposit        = $q->param('deposit');
    my $deposit = "0.00";
    my $booking_id     = $q->param('booking_id');

    my ( $month, $day, $year ) = split( /\//, $q->param('checkin_date') );

    my $second_charge_date =
      DateTime->new( month => $month, year => $year, day => $day )
      ->subtract( days => 30 )->mdy('/');

    my $rental_subtotal = $num_nights * $nightly_rate;
    $local_taxes =~ s/\%$//;
    my $total_rental_amount = $rental_subtotal * ( 1 + $local_taxes / 100 );

    # recalc second payment
    $second_payment = $total_rental_amount + $deposit - $first_payment;

    if ( $results->has_missing or $results->has_invalid ) {

        warn(
            "missing are "
              . join( ',',
                keys %{ $results->{missing} },
                keys %{ $results->{invalid} } )
        ) if DEBUG;
        my $url = _gen_redirect( $results, $q,
"&bktcc=1&first_payment=$first_payment&second_payment=$second_payment&booking_id=$booking_id&num_nights=$num_nights&local_taxes=$local_taxes&cleaning_fee=$cleaning_fee&nightly_rate=$nightly_rate&second_charge_date=$second_charge_date&deposit=$deposit&rental_subtotal=$rental_subtotal&total_rental_amount=$total_rental_amount"
        );

        return $self->redirect($url);
    }

    ###########################################
    # make the paypal payment

    warn( "making paypal call for booking id " . $q->param("booking_id") )
      if DEBUG;
    my $billto_name =
      join( ' ', $q->param('first_name'), $q->param('last_name') );

    my %billing_args = (
        MailingStreet  => $q->param('billing_address'),
        MailingCity    => $q->param('billing_city'),
        MailingCountry => $q->param('billing_country'),
        MailingState   => $q->param('billing_state'),
    );

    if ( $q->param('billing_zip') =~ m/^\d+$/ ) {
        $billing_args{MailingPostalCode} = $q->param('billing_zip') . '-0000';
    }
    else {
        $billing_args{MailingPostalCode} = $q->param('billing_zip');
    }

    my $Paypal = Business::PayPal::NVP->new(%Paypal);

    my %paypal_args = (
        PaymentAction     => 'Sale',
        OrderTotal        => $q->param('first_payment') || 'oops',
        TaxTotal          => '0.00',
        ShippingTotal     => '0.00',
        ItemTotal         => '0.00',
        HandlingTotal     => '0.00',
        CreditCardType    => ucfirst( $q->param('card_type') ) || 'oops',
        CreditCardNumber  => $q->param('card_number') || 'oops',
        ExpMonth          => $q->param('exp_month') || 'oops',
        ExpYear           => $q->param('exp_year') || 'oops',
        CVV2              => $q->param('cvc') || 'oops',
        FirstName         => $q->param('first_name') || 'oops',
        LastName          => $q->param('last_name') || 'oops',
        Street1           => $q->param('billing_address') || 'oops',
        CityName          => $q->param('billing_city') || 'oops',
        StateOrProvince   => $q->param('billing_state') || 'oops',
        PostalCode        => $q->param('billing_zip') || 'oops',
        Payer             => $q->param('email') || 'oops',
        Country           => $q->param('billing_country') || 'oops',
        CurrencyID        => 'USD',
        IPAddress         => $ENV{'REMOTE_ADDR'} || 'oops',
        MerchantSessionID => int( rand(100_000) ),
    );

    #$DB::single = 1;

    # recurring args


    my $thirty = DateTime->now->add( days => 30 );
    my $thirty_before_checkin =
      DateTime->new( month => $month, year => $year, day => $day )
      ->subtract( days => 30 );

    my $cmp = DateTime->compare( $thirty, $thirty_before_checkin );

    if ( ( $cmp == 1 ) or ( $cmp == 0 ) ) {
        $first_payment += $second_payment;
    }


    %paypal_args = (
        SubscriberName   => $billto_name,
        ProfileStartDate => $thirty->mdy,
        ProfileReference => $booking_id,

        #        TrialBillingPeriod      => 'Day',
        #        TrialBillingFrequency   => 30,
        #        TrialTotalBillingCycles => 1,
        #        TrialAmount             => $q->param('first_payment'),

        BillingPeriod      => 'Month',
        BilllingFrequency  => '1',
        TotalBillingCycles => '2',
        AMT                => $second_payment,

        Payer                => $q->param('email'),
        PayerName            => $billto_name,
        PayerStreet1         => $q->param('billing_address'),
        PayerStreet2         => '',
        PayerCityname        => $q->param('billing_city'),
        PayerStateOrProvince => $q->param('billing_state'),
        PayerCountry         => $q->param('billing_country'),
        PayerPostalCode      => $q->param('billing_zip'),
        PayerPhone           => $q->param('phone'),

        CreditCardType   => ucfirst( $q->param('card_type') ),
        CreditCardNumber => $q->param('card_number'),
        ExpMonth         => $q->param('exp_month'),
        ExpYear          => $q->param('exp_year'),
        CVV2             => $q->param('cvc'),
    );

    if (DEBUG) {
        open( FH, '>/tmp/payment_args' ) or die $!;
        print FH Dumper( \%paypal_args );
        close(FH) or die $!;
    }
    local $IO::Socket::SSL::VERSION = undef;

    my %ucargs;
    foreach my $key ( keys %paypal_args ) {
        $ucargs{ uc($key) } = $paypal_args{$key};

    }
    $DB::single = 1;

    # do the first payment
    my $return = $ENV{'HTTP_REFERER'} || 'http://www.hvh.com/';
    my $cancel = 'http://www.hvh.com/';

   my %ex_args = (
        InvoiceID       => $booking_id,
        Name            => $billto_name,
        Street1         => $q->param('billing_address'),
        CityName        => $q->param('billing_city'),
        StateOrProvince => $q->param('billing_state'),
        PostalCode      => $q->param('billing_zip'),
        Country         => $q->param('billing_country'),
        BillingType     => 'MerchantInitiatedBilling',
        AMT             => $first_payment,
        ReturnURL       => $return,
        CancelURL       => $cancel,
    );

     warn( "express checkout args: " . Dumper( \%ex_args ) ) if DEBUG;

    my %pay_args = (
	PAYMENTACTION => 'sale',
	IPADDRESS => $ENV{REMOTE_ADDR} || '127.0.0.1',
        CREDITCARDTYPE => ucfirst( $q->param('card_type') ),
        ACCT => $q->param('card_number'),
        EXPDATE         => $q->param('exp_month') . $q->param('exp_year'),
        CVV2             => $q->param('cvc'),
	PAYERID => $booking_id,
        EMAIL => $q->param('email'),
	PAYERSTATUS => 'verified',
	COUNTRYCODE => 'US',
	BUSINESS => $billto_name,
	AMT => $first_payment,
	STREET => $q->param('billing_address'),
	CITY => $q->param('billing_city'),
	STATE => $q->param('billing_state'),
	ZIP => $q->param('billing_zip'),
	FIRSTNAME =>	$q->param('first_name'),
	LASTNAME =>  $q->param('last_name'),
    );

	
     warn( "pay args: " . Dumper( \%pay_args ) );

    my %pay_res = $Paypal->DoDirectPayment( %pay_args );

    if ( $pay_res{ACK} eq 'Failure' ) {

        warn( "express checkout failed: " . Dumper( \%pay_res ) );

        $results->{invalid}->{payment_errors} = 1;

        my $url = _gen_redirect( $results, $q,
"&bktcc=1&first_payment=$first_payment&second_payment=$second_payment&booking_id=$booking_id&num_nights=$num_nights&local_taxes=$local_taxes&cleaning_fee=$cleaning_fee&nightly_rate=$nightly_rate&second_charge_date=$second_charge_date&deposit=$deposit&rental_subtotal=$rental_subtotal&total_rental_amount=$total_rental_amount"
        );

        return $self->redirect($url);
    }

    warn( "first payment returned token " . $pay_res{TOKEN} ) if DEBUG;

    my $sf = eval { _sf_login() };
    die $@ if $@;

    my $card = $q->param('card_number');
    my $exp  = join( '/', $q->param('exp_month'), $q->param('exp_year') );
    my $date = DateTime->now->mdy('/');

    # update salesforce booking
    eval {
        $sf->update(
            type => 'Booking__c',
            {
                id                        => $q->param('booking_id'),
                Booking_Stage__c          => 'Booked - First Payment',
                Credit_Card_Last_4__c  => substr( $card, length($card) - 4 ),
                Credit_Card_Exp_Date__c   => $exp,
                X1st_Payment__c           => $first_payment,  # this is not an error
                First_Payment_Received__c => $date,
                Date__c                   => $date,
                Second_Payment_Due_Date__c => $second_charge_date,
            },
        );
    };
    die $@ if $@;

    my $uri = $ENV{'HTTP_REFERER'};
    $uri =~ s/bkt\=1/bkt\=success/;
    return $self->redirect($uri);
}

sub _reserve {
    my ( $self, $q ) = @_;

    my @required = qw( prop_name first_name last_name
      phone checkin_date checkout_date email guests );

    my %profile = (
        required           => \@required,
        optional           => [qw( guests )],
        constraint_methods => {
            email         => email(),
            phone         => phone(),
            first_name    => valid_first(),
            last_name     => valid_last(),
            checkin_date  => valid_date(),
            checkout_date => valid_date(),
        }
    );
    my $results = Data::FormValidator->check( $q, \%profile );

    if ( $results->has_missing or $results->has_invalid ) {

        my $url = _gen_redirect( $results, $q );

        return $self->redirect($url);
    }

    # create salesforcebooking
    # the required args
    my $name = join( ' ',
        $q->param('first_name'),
        $q->param('last_name'),
    );

    my $sf = eval { _sf_login() };
    die $@ if $@;

    my ( $is_available, $checkin_date, $checkout_date ) = check_booking(
        $sf,
        $q->param('checkin_date'),
        $q->param('checkout_date'),
        $q->param('prop_id'),
    );

    unless ($is_available) {
        my $url = _gen_redirect( $results, $q, '&booked=1' );
        return $self->redirect($url);
    }

    # warn("booking date available") if DEBUG;

    # look for a contact first
    my %contact_args = (
        Email           => $q->param('email'),
        FirstName       => $q->param('first_name'),
        LastName        => $q->param('last_name'),
        Phone           => $q->param('phone'),
        Contact_Type__c => 'Renter',
    );

    my $contact_id = _find_or_create_contact( $sf, \%contact_args );

    # now make a booking
    my ( $r, %sf_args );
    eval {
        %sf_args = (

            type                   => 'Booking__c',
            Name                   => $name,
            Property_name__c       => $q->param('prop_id'),
            Check_in_Date__c       => _dbdate( $q->param('checkin_date') ),
            Check_out_Date__c      => _dbdate( $q->param('checkout_date') ),
            Booking_Stage__c       => 'Pending',
            Contact__c             => $contact_id,
            Booking_Description__c => $q->param('comments'),
            Payment_Method__c      => 'PayPal',
        );

        # hack for salesforce bug
        if ( length( $q->param('guests') ) == 1 ) {
            $sf_args{Number_of_Guests__c} = '0' . $q->param('guests');
        }

        $r = $sf->create(%sf_args);
    };
    die $@ if $@ or !$r;

    my $result = $r->envelope->{Body}->{createResponse}->{result};

    if (DEBUG) {
        open( FH, '>/tmp/create_booking' ) or die $!;
        print FH Dumper($result);
        close(FH) or die $!;
    }

    die "error creating booking\n"
      unless ( ( $result->{success} eq 'true' ) && ( defined $result->{id} ) );

    my $booking_id = $result->{id};

    # ok the booking was made ok
    # warn("booking created id $booking_id, sf api call to get payment amounts")
    #  if DEBUG;

    ######################
    # get the booking details
    my $query =
"Select Id, Security_Deposit_Amount__c, First_Payment_Amount__c, Second_Payment_Amount__c, Number_of_Nights__c, Tax_Rate__c, Cleaning_Fee__c, Nightly_List_Price__c from Booking__c where Id = '$booking_id'";

    my $res = $sf->query( query => $query );
    $result = $res->envelope->{Body}->{queryResponse}->{result};

    if (DEBUG) {
        open( FH, '>/tmp/select_booking' ) or die $!;
        print FH Dumper($result);
        close(FH) or die $!;
    }

    unless ( defined $result->{done} && $result->{done} eq 'true' ) {
        die("query to select booking id $booking_id failed\n");
    }
    ###########################

    my $first_payment  = $result->{records}->{First_Payment_Amount__c};
    my $second_payment = $result->{records}->{Second_Payment_Amount__c};
    my $num_nights     = $result->{records}->{Number_of_Nights__c};
    my $local_taxes    = $result->{records}->{Tax_Rate__c};
    # my $cleaning_fee   = $result->{records}->{Cleaning_Fee__c};
    my $cleaning_fee = "0.00";
    my $nightly_rate   = $result->{records}->{Nightly_List_Price__c};
    # my $deposit        = $result->{records}->{Security_Deposit_Amount__c};
	my $deposit = "0.00";
    my ( $month, $day, $year ) = split( /\//, $q->param('checkin_date') );
    my $second_charge_date =
      DateTime->new( month => $month, year => $year, day => $day )
      ->subtract( days => 30 )->mdy('/');

    my $rental_subtotal = $num_nights * $nightly_rate;
    $local_taxes =~ s/\%$//;
    my $total_rental_amount = $rental_subtotal * ( 1 + $local_taxes / 100 );

    # recalc second payment
    $second_payment = $total_rental_amount + $deposit - $first_payment;

    # redirect to cc page
    my $url = _gen_redirect( $results, $q,
"&bktcc=1&first_payment=$first_payment&second_payment=$second_payment&booking_id=$booking_id&num_nights=$num_nights&local_taxes=$local_taxes&cleaning_fee=$cleaning_fee&nightly_rate=$nightly_rate&second_charge_date=$second_charge_date&deposit=$deposit&rental_subtotal=$rental_subtotal&total_rental_amount=$total_rental_amount"
    );

    return $self->redirect($url);
}

1;
