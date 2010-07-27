package HVH::Hold;

use strict;
use warnings;

use base qw( CGI::Application );

use CGI::Application::Plugin::Redirect;
use CGI::Application::Plugin::TT;
use CGI::Application::Plugin::ValidateRM qw( check_rm );

use Data::FormValidator ();
use Data::FormValidator::Constraints qw(:closures);

use Business::PayPal::NVP;
use WWW::Salesforce          ();
use DateTime                ();
use URI::Escape ();
use Data::Dumper;
use Cache::Memcached;

use Template::Plugin::Number::Format;

my $memd = Cache::Memcached->new({ servers => [ 'localhost:11211' ] });


my $sf = eval { WWW::Salesforce->login(
           username => 'api@hvh.com',
           password => 'SaaS69dBfUy0GkDQB7oAdOxu77DJBFt', ); };
if ($@) {
	warn($@);
	die "Temporary technical error\n";
}

use constant DEBUG => $ENV{HVH_DEBUG} || 0;

use constant KAMALA => 'a0650000003DhL8AAK';

# don't touch this
delete $ENV{$_} for grep { /^(HTTPS|SSL)/ } keys %ENV;

# don't touch this either, unless you need to get a new api token
if (DEBUG) {

    $ENV{HTTPS_CERT_FILE} = './conf/cert.pem';

}
else {

    $ENV{HTTPS_CERT_FILE} = '/etc/pki/tls/cert.pem';
}

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

sub setup {
    my $self = shift;
    $self->start_mode('hold');
    $self->run_modes( [qw( hold process held )] );
}

sub cgiapp_init {
    my $self = shift;
    $self->tt_include_path('/var/www/hvh2.hvh.com/tmpl');
}

	
our %Inquiry = (
    address  => 'Inquiry_Address_1__c',
    city     => 'Inquiry_City__c',
    state    => 'Inquiry_State__c',
    zip      => 'Inquiry_Zip_Code__c',
    country  => 'Inquiry_Country__c',
    phone    => 'Inquiry_Phone__c',
    guests   => 'Number_of_Guests__c',
    comments => 'Inquiry_Comments__c',
);


# fixes up our SOAP request the hard way
sub _hack_the_soap {
    my ( $q, $sf_args ) = @_;

    # hack for SOAP bug
    if ( $q->param('zip') =~ m/^\d+$/ ) {
        $sf_args->{Inquiry_Zip_Code__c} = $q->param('zip') . '-0000';
    }

    # hack for salesforce bug
    if ( length( $q->param('guests') ) == 1 ) {
        $sf_args->{Number_of_Guests__c} = '0' . $q->param('guests');
    }

    return 1;
}

sub _sf_login {
    my $Sf = WWW::Salesforce->login(
        username => 'api@hvh.com',
        password => 'SaaS69dBfUy0GkDQB7oAdOxu77DJBFt',
    ) or die $!;
    return $Sf;
}

sub _dtdate {
    my $date = shift;

    #	warn("Date is $date");
    my ( $month, $day, $year ) = split( /\//, $date );
    if ( length($year) == 2 ) {
        $year = '20' . $year;
    }

    $date = DateTime->new(
        year  => $year,
        month => $month,
        day   => $day,
    );
    return $date;
}

sub _dbdate {
    my $date = shift;

    #	warn("Date is $date");
    my ( $month, $day, $year ) = split( /\//, $date );
    if ( length($year) == 2 ) {
        $year = '20' . $year;
    }

    $date = DateTime->new(
        year  => $year,
        month => $month,
        day   => $day,
    );

    #	$date->set_time_zone( 'local' );
    $date = $date->ymd('-');

    return $date;
}

sub check_booking {
    my ( $sf, $checkin_date, $checkout_date, $prop_id ) = @_;

    my $dt_ci = _dtdate($checkin_date);
    my $dt_co = _dtdate($checkout_date);

    warn("checkin $checkin_date, checkout $checkout_date");

    # allow up to a week of back booking
    my $tomorrow = DateTime->now->subtract( weeks => 1 );

    if (   ( $dt_ci->epoch < $tomorrow->epoch )
        or ( $dt_co->epoch < $tomorrow->epoch ) )
    {

        warn("trying to book too early!");
        return;

    }

    $checkin_date  = _dbdate($checkin_date);
    $checkout_date = _dbdate($checkout_date);

    # warn("checkin date $checkin_date, co $checkout_date");

    my $sql =
"Select Id from Booking__c where (Booking_Stage__c != 'Dead' and Booking_Stage__c != 'Pending')  and Property_name__c = '$prop_id' and ( ";

    $sql .=
"( ( Check_in_Date__c < $checkin_date ) and ( Check_out_Date__c > $checkin_date ) and ( Check_in_Date__c < $checkout_date ) and ( Check_out_Date__c >= $checkout_date) ) ";

    # (booked_checkin) (new_checkin) (new_checkout) (booked_checkout)

    $sql .=
" or ( ( Check_in_Date__c <= $checkin_date ) and (  Check_out_Date__c > $checkin_date ) and ( Check_in_Date__c < $checkout_date ) and ( Check_out_Date__c <= $checkout_date ) ) ";

    # (booked_checkin) (new_checkin) (booked_checkout) (new_checkout)

    $sql .=
" or ( ( Check_in_Date__c >= $checkin_date ) and ( Check_out_Date__c > $checkin_date )  and ( Check_in_Date__c < $checkout_date ) and ( Check_out_Date__c >= $checkout_date ) )";

    # (new_checkin) (booked_checkin)  (new_checkout) (booked_checkout)

    $sql .=
" or ( ( Check_in_Date__c >= $checkin_date ) and ( Check_out_Date__c > $checkin_date ) and ( Check_in_Date__c < $checkout_date ) and ( Check_out_Date__c <= $checkout_date ) ) )";

    # (new_checkin) (booked_checkin) (booked_checkout) (new_checkout)

    my $res = $sf->query( query => $sql );

    if ( $res->valueof('//queryResponse/result')->{size} != 0 )
    {    # found a conflicting booking

        warn("booking conflict! ") if DEBUG;

        return;
    }

    return ( 1, $checkin_date, $checkout_date );
}

sub _find_or_create_contact {
    my ( $sf, $contact_args ) = @_;

    my $name =
      join( ' ', $contact_args->{'FirstName'}, $contact_args->{'LastName'} );
    my $contact_id = _find_contact( $sf, $name );

    if (DEBUG) {
        open( FH, '>', '/tmp/contact_args' ) or die $!;
        print FH Dumper($contact_args);
        close(FH) or die $!;
    }

    if ($contact_id) {

        # warn("found a contact id $contact_id, updating it") if DEBUG;

        # update the contact
        my $res = $sf->update(
            type => 'Contact',
            {
                id => $contact_id,
                %{$contact_args},
            },
        );

        my $result = $res->envelope->{Body}->{updateResponse}->{result};
        if (DEBUG) {
            open( FH, '>', '/tmp/contact_update' ) or die $!;
            print FH Dumper($result);
            close(FH) or die $!;
        }
        die "error updating contact id $contact_id\n"
          unless ( $result->{success} eq 'true' );

        # warn("updated contact id $contact_id ok") if DEBUG;
        return $contact_id;
    }

    ###########################################
    # otherwise create a new account and contact
    my $r = $sf->create(
        Name => $name,
        Type => 'Rental Customer',
        type => 'Account'
    );
    my $result = $r->envelope->{Body}->{createResponse}->{result};
    die "error creating account name $name\n"
      unless ( ( $result->{success} eq 'true' ) && ( defined $result->{id} ) );
    my $account_id = $result->{id};

    # make the contact
    $r = $sf->create(
        type => 'Contact',
        %{$contact_args},
        AccountId => $account_id,
    );
    $result = $r->envelope->{Body}->{createResponse}->{result};

    if (DEBUG) {
        open( FH, '>', '/tmp/create_new_contact.txt' ) or die $!;
        print FH Dumper($result);
        close(FH);
    }

    die "error creating contact name $name\n"
      unless ( ( $result->{success} eq 'true' ) && ( defined $result->{id} ) );

    warn( "created new contact for name $name, new id " . $result->{id} )
      if DEBUG;

    # return the newly created id
    return $result->{id};
}

sub _find_contact {
    my ( $sf, $name ) = @_;

    my $sql = <<SQL;
SELECT Id from Contact where Name = '$name'
SQL

    # warn("looking for contact name $name\n") if DEBUG;
    my $r = $sf->query( query => $sql, limit => '1' )
      or die "SF query failed!: $sql";

    # things get ugly here
    my $result = $r->envelope->{Body}->{queryResponse}->{result};

    if (DEBUG) {
        open( FH, '>', '/tmp/find_contact_results.txt' ) or die $!;
        print FH Dumper($result);
        close(FH) or die $!;
    }

    # size > 0 indicates records returned
    my $size = $result->{size};
    my $contact_id;
    if ( defined $size && ( $size == 1 ) ) {

        # warn("Found some records for contact name $name") if DEBUG;

        # uh huh, just get the first id
        $contact_id = $result->{records}->{Id}->[0];
        return $contact_id;
    }
    else {
        warn("Could not find contact name $name") if DEBUG;
        return;
    }
}

sub bookit {
    my $self = shift;

    my $q = $self->query;

    if ( $q->param('bktcc_next') && ( $q->param('bktcc_next') == 1 ) ) {

        return $self->_payment($q);

    }
    else {

        return $self->_reserve($q);

    }
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
  #  $DB::single = 1;

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

sub held {
    my ($self) = @_;

    my $output = $self->tt_process('held.tmpl', {query => $self->query});
    return $output;
}


sub hold {
    my ($self, $errors) = @_;

    my $prop_id = $self->query->param('prop_id');
    my %tmpl = ( prop_id => $prop_id);
    if ( $errors ) {
	$tmpl{'errors'} = $errors;
    }

    my $prop = $memd->get("property|$prop_id");
#    unless ($prop) { # we need to fetch it

	warn("hitting cache for $prop_id");
	$prop = $self->retrieve_property($prop_id);
        $memd->set("property|$prop_id" => $prop);
 #   }

    $tmpl{'prop'} = $prop;
    $tmpl{'query'} = $self->query;
    my $output = $self->tt_process('hold.tmpl', \%tmpl);

    return $output;
}

sub retrieve_property {
    my ($self, $prop_id) = @_;

    my @amenities = (
"Wireless_Internet__c", "Private_Hot_Tub__c",
        "Swimming_Pool__c", "High_Definition_TV_DVR__c",
        "Stereo_System__c", "CD_Player__c", "Music_Library__c", "VCR__c",
        "DVD_Player__c",
 "Air_Conditioning__c",
        "Full_Kitchen__c", 
"Barbecue__c",
    "Garage_Parking__c", "Street_Parking__c",
);

    my @outdoors = (
        "Extremely_Private__c", "Large_Yard__c", "Outdoor_Shower__c", "Hammock__c",
        "Patio_Lanai__c", "Tennis_Courts__c", "Basketball_Hoop__c", "Volleyball_Court__c",);


    my @features = ( 
        "Fireplace__c", "Kid_Friendly__c", "No_Smoking__c",
        "Pets_Allowed__c",
"Waterfront__c", "Views__c",
        "Ocean_View__c", "Mountain_View__c",
	);

	my @media = (
        "Unlimited_Domestic_Long_Distance__c", "Cable_Satellite_TV__c", "Telephone__c", "Computer__c",
"Video_Library__c",
	);

    my @bed = (
 "Hair_Dryer__c",
 "Bath_Towels__c", "Bed_Linens__c", "Washer_Dryer__c",
        "Crib__c", "Jets_in_Bathtub__c",);

	my @kitchen = (
 "Ice_Maker__c", "Blender__c",
        "Microwave__c",
"Cooking_Utensils__c", 
        "Refrigerator__c", "Dishwasher__c", "Oven__c",
);


    my $q_fields = join(',', @amenities, @outdoors, @features, @media, @bed, @kitchen);

    my @bases = qw( Id Name Property_Calendar_Code__c Property_Address__c Category__c
Teaser__c Description__c Location__c Image_URL_1__c Image_URL_2__c
Image_URL_3__c Image_URL_4__c Image_URL_5__c Image_URL_6__c
Image_URL_7__c Image_URL_8__c State__c City__c Special_Amenities__c
Solutions_Customer__c Check_in_Time__c Check_out_Time__c
Nightly_Rate_List_Price__c Local_Tax_Rate__c Security_Deposit__c 
Housekeeping_Fee__c Website__c Sleeps__c Bedrooms__c Bathrooms__c
Bathtubs__c Showers__c );
    my $base_fields = join(',', @bases);

    my $sql = <<"SQL";
SELECT $base_fields, $q_fields
FROM Property__c where Id='$prop_id' and Available_to_the_Public__c=true
SQL

    my $result = $self->run_select($sql);

    foreach my $am ( @amenities ) {
        push @{$result->{amenities}}, $self->convert($am);
    }


    foreach my $am ( @outdoors ) {
        push @{$result->{outdoors}}, $self->convert($am);
    }

    foreach my $am ( @features ) {
        push @{$result->{features}}, $self->convert($am);
    }

    foreach my $am ( @media ) {
        push @{$result->{media}}, $self->convert($am);
    }

    foreach my $am ( @bed ) {
        push @{$result->{beds}}, $self->convert($am);
    }

    foreach my $am ( @kitchen ) {
        push @{$result->{kitchens}}, $self->convert($am);
    }


    return $result;
}

sub convert {
	my ($self, $am) = @_;
	$am =~ s/__c$//g;
	$am =~ s/_/ /g;
	return $am;
}

sub run_select {
    my ($self, $sql) = @_;

    my $r = $sf->query( query => $sql, limit => '1' );
    unless ($r) {
        return;
    }

    # things get ugly here
    my $result = $r->envelope->{Body}->{queryResponse}->{result};

    # size > 0 indicates records returned
    my $size = $result->{size};
    my $id;
    if ( defined $size && ( $size > 0 ) ) {

	return $result->{records};

    }

     # no data, just return;
     return;
}

sub results_to_errors {
    my ( $self, $results ) = @_;
    my %errors;

    if ( $results->has_missing ) {
        %{ $errors{missing} } = map { $_ => 1 } $results->missing;
    }
    if ( $results->has_invalid ) {
        %{ $errors{invalid} } = map { $_ => 1 } $results->invalid;
    }

    return \%errors;
}

sub process {
    my $self = shift;
    my @required = qw( prop_id first_name last_name email
      phone checkin_date checkout_date country zip);

    my %profile = (
        required           => \@required,
        optional           => [qw( comments )],
        constraint_methods => {
            email         => email(),
            first_name    => valid_first(),
            last_name     => valid_last(),
            checkin_date  => valid_date(),
            checkout_date => valid_date(),
        }
    );

    my $results = $self->check_rm('hold', \%profile);

    if ($results->has_missing or $results->has_invalid) {
	my $errors = $self->results_to_errors($results);
    	return $self->hold($errors);
    }

    my $q = $self->query;

    my $sf = _sf_login();
    my ( $is_available, $checkin_date, $checkout_date ) = check_booking(
        $sf,
        $q->param('checkin_date'),
        $q->param('checkout_date')
    );

    return $self->hold({ already_booked => 1 }) unless $is_available;

    my $name = join( ' ',
        $q->param('first_name'),
        $q->param('last_name'),
    );

    # look for a contact first
    my %contact_args = (
        Email           => $q->param('email'),
        FirstName       => $q->param('first_name'),
        LastName        => $q->param('last_name'),
        MailingStreet   => $q->param('address'),
        MailingCity     => $q->param('city'),
        MailingCountry  => $q->param('country'),
        MailingState    => $q->param('state'),
        Phone           => $q->param('phone'),
        Contact_Type__c => 'Renter',
    );

    if ( $q->param('billing_zip') =~ m/^\d+$/ ) {
        $contact_args{MailingPostalCode} = $q->param('billing_zip') . '-0000';
    }
    else {
        $contact_args{MailingPostalCode} = $q->param('billing_zip');
    }
    my $contact_id = _find_or_create_contact( $sf, \%contact_args );

    # now make a booking
    my $date = DateTime->now->mdy('/');
    my ( $r, %sf_args );
    eval {
        %sf_args = (

            type                   => 'Booking__c',
            Name                   => $name,
            Property_name__c       => $q->param('prop_id'),
            Check_in_Date__c       => _dbdate( $q->param('checkin_date') ),
            Check_out_Date__c      => _dbdate( $q->param('checkout_date') ),
            Booking_Stage__c       => '48 Hour Hold',
            Contact__c             => $contact_id,
            Booking_Description__c => $q->param('comments'),
            Payment_Method__c      => '',
            Date__c                   => _dbdate($date),
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

    return $self->redirect("/cgi-bin/hold.cgi?rm=held&booking_id=$booking_id&prop_id=" . $q->param('prop_id'));
}



sub _add_optional_args {
    my ( $q, $Inquiry, $sf_args ) = @_;

    # add the optional args
    foreach my $opt ( keys %{$Inquiry} ) {
        if ( $q->param($opt) ) {

	    if ($opt eq 'phone') {
		unless ($q->param($opt) =~ m/[\-\(\)]/) {
			my ($area, $prefix, $ext) = $q->param($opt) =~ m/(\d{3})(\d{3})(\d{4})/;
			$sf_args->{$Inquiry->{$opt}} = "$area-$prefix-$ext";
		}
	    } else {
	            $sf_args->{ $Inquiry->{$opt} } = $q->param($opt);
	    }
        }
    }
}

sub valid_date {

    return sub {
        my $dfv = shift;
        my $val = $dfv->get_current_constraint_value;

        my ( $mon, $day, $year ) =
          $val =~ m{^(\d{1,2})/(\d{1,2})/((?:20)?\d{2})$};

        #	warn("year is $year, day $day, month $mon");
        return unless ( $day && $mon && $year );

        eval {
            my $dt = DateTime->new( year => $year, month => $mon, day => $day );
        };

        #	warn $@ if $@;
        return if $@;

        if ( length($year) == 2 ) {

            #	warn("year is $year");
            # two digit year used
            $val = sprintf( "%d/%d/%d", $day, $mon, '20' . $year );
        }

        return $val;

      }
}

sub valid_first {

    return sub {
        my $dfv = shift;
        my $val = $dfv->get_current_constraint_value;

        return if $val eq 'First';

        return $val;
      }
}

sub valid_last {

    return sub {
        my $dfv = shift;
        my $val = $dfv->get_current_constraint_value;

        return if $val eq 'Last';

        return $val;
      }
}

sub valid_cvv {
    return sub {
        my $dfv = shift;
        my $val = $dfv->get_current_constraint_value;

        return if $val !~ /^(\d+)$/;

        return $val;
      }
}

sub valid_city {
    return sub {
        my $dfv = shift;
        my $val = $dfv->get_current_constraint_value;

        return if $val =~ /^ex\./;

        return $val;
      }
}

sub valid_street {
    return sub {
        my $dfv = shift;
        my $val = $dfv->get_current_constraint_value;

        return if $val =~ /^ex\./;

        return $val;
      }
}

1;