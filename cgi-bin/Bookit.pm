package Bookit;

use strict;
use warnings;

use base qw( CGI::Application );

use Data::FormValidator ();
use Data::FormValidator::Constraints qw(:closures);
use Business::PayPal::NVP;
use WWW::Salesforce::Simple ();
use DateTime                ();
use CGI::Application::Plugin::Redirect;
use URI::Escape ();
use Data::Dumper;
use Number::Format;

BEGIN {
    $WWW::Salesforce::Constants::TYPES{booking__c}->{x1st_payment__c} = 'xsd:double';
}

use constant DEBUG => $ENV{HVH_DEBUG} || 0;

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
    $self->start_mode('bookit');
    $self->run_modes( [qw( bookit contact hold )] );
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

# there's a better way to do this

sub _gen_redirect {
    my ( $results, $q, $extra ) = @_;

    # set new url;
    my @fields =
      ( keys %{ $results->{invalid} }, keys %{ $results->{missing} } );

    my $url = '&invalid=' . join( '|', @fields );

    # add the current field values
    foreach my $invalid ( keys %{ $results->{invalid} } ) {
        no warnings;
        $url .=
          '&' . $invalid . '=' . URI::Escape::uri_escape( $q->param($invalid) );
    }

    my %params = $q->Vars;
    foreach my $param ( keys %params ) {
        $url .= '&' . $param . '=' . URI::Escape::uri_escape( $params{$param} );
    }

    my ($lead) = $ENV{'HTTP_REFERER'} || '';

    ($lead) =~ m/^(.*?prop_id=\w+\&(?:bkt|fhh|cto)=1)/;

    $url = $lead . $url;

    $url .= $extra if $extra;

    return $url;
}

# handles form submissions for the contact page

sub contact {
    my ($self) = @_;

    my @required = qw( first_name last_name email
      checkin_date checkout_date  );

    my %profile = (
        required           => \@required,
        optional           => [ keys %Inquiry ],
        constraint_methods => {
            email         => email(),
            first_name    => valid_first(),
            last_name     => valid_last(),
            checkin_date  => valid_date(),
            checkout_date => valid_date(),
	    phone         => american_phone(),
        }
    );

    my $q = $self->query;
    my $results = Data::FormValidator->check( $q, \%profile );

    if ( $results->has_missing or $results->has_invalid ) {

        my $url = _gen_redirect( $results, $q );

        return $self->redirect($url);
    }

    # create salesforce inquiry
    my $r;
    my $sf;
    eval {$sf = _sf_login();};
    die $@ if $@;

        # the required args
    my %sf_args = (
            type => 'Inquiry__c',
            Name => join( ' ',
                $q->param('first_name'), $q->param('last_name'),
                int( rand(1000) ), ),

            Inquiry_First_Name__c => $q->param('first_name'),
            Inquiry_Last_Name__c  => $q->param('last_name'),
            Inquiry_Email__c      => $q->param('email'),
            Property__c           => $q->param('prop_id'),
            Check_in_Date__c      => _dbdate( $q->param('checkin_date') ),
            Check_out_Date__c     => _dbdate( $q->param('checkout_date') ),
            Inquiry_Stage__c      => 'Open',
        );

        _add_optional_args( $q, \%Inquiry, \%sf_args );

        # fixup the request
        # hack for SOAP bug
        if ( $q->param('zip') =~ m/^\d+$/ ) {
            $sf_args{Inquiry_Zip_Code__c} = $q->param('zip') . '-0000';
        }

        # hack for salesforce bug
        if ( length( $q->param('guests') ) == 1 ) {
            $sf_args{Number_of_Guests__c} = '0' . $q->param('guests');
        }

        $r = eval { $sf->create(%sf_args)};
	die $@ if $@;

        my $result = $r->envelope->{Body}->{createResponse}->{result};

        # warn('result is ' . $result->{success});
        if ( $result->{success} eq 'false' ) {
            die(
                "Salesforce failed to create inquiry: "
                  . Dumper(
                    $result->{errors} . ", args: " . Dumper( \%sf_args )
                  )
            );
        }

    my $uri = $ENV{'HTTP_REFERER'};
    $uri =~ s/cto\=1/cto\=success/;
    return $self->redirect($uri);
}

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
"Select Id from Booking__c where (Booking_Stage__c != 'Dead' and Booking_Stage__c != 'Working' and Booking_Stage__c != 'Unqualified'  and Booking_Stage__c != 'Canceled'  and Booking_Stage__c != 'Lost' )  and Property_name__c = '$prop_id' and ( ";

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


        return;
    }

    return ( 1, $checkin_date, $checkout_date );
}

sub _find_or_create_contact {
    my ( $sf, $contact_args ) = @_;

    my $name =
      join( ' ', $contact_args->{'FirstName'}, $contact_args->{'LastName'} );
    my $contact_id = _find_contact( $sf, $name );


    if ($contact_id) {

        # update the contact
        my $res = $sf->update(
            type => 'Contact',
            {
                id => $contact_id,
                %{$contact_args},
            },
        );

        my $result = $res->envelope->{Body}->{updateResponse}->{result};
        die "error updating contact id $contact_id\n"
          unless ( $result->{success} eq 'true' );

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


    die "error creating contact name $name\n"
      unless ( ( $result->{success} eq 'true' ) && ( defined $result->{id} ) );

    # return the newly created id
    return $result->{id};
}

sub _find_contact {
    my ( $sf, $name ) = @_;

    my $sql = <<SQL;
SELECT Id from Contact where Name = '$name'
SQL

    my $r = $sf->query( query => $sql, limit => '1' )
      or die "SF query failed!: $sql";

    # things get ugly here
    my $result = $r->envelope->{Body}->{queryResponse}->{result};

    # size > 0 indicates records returned
    my $size = $result->{size};
    my $contact_id;
    if ( defined $size && ( $size == 1 ) ) {


        # uh huh, just get the first id
        $contact_id = $result->{records}->{Id}->[0];
        return $contact_id;
    }
    else {
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
    $total_rental_amount = Number::Format::round($total_rental_amount, 2);

    # recalc second payment
    $second_payment = $total_rental_amount + $deposit - $first_payment;

    if ( $results->has_missing or $results->has_invalid ) {

        my $url = _gen_redirect( $results, $q,
"&bktcc=1&first_payment=$first_payment&second_payment=$second_payment&booking_id=$booking_id&num_nights=$num_nights&local_taxes=$local_taxes&cleaning_fee=$cleaning_fee&nightly_rate=$nightly_rate&second_charge_date=$second_charge_date&deposit=$deposit&rental_subtotal=$rental_subtotal&total_rental_amount=$total_rental_amount"
        );

        return $self->redirect($url);
    }

    ###########################################
    # make the paypal payment

    my $billto_name =
      join( ' ', $q->param('first_name'), $q->param('last_name') );

    my $Paypal = Business::PayPal::NVP->new(%Paypal);

    my $thirty = DateTime->now->add( days => 30 );
    my $thirty_before_checkin =
      DateTime->new( month => $month, year => $year, day => $day )
      ->subtract( days => 30 );

    my $cmp = DateTime->compare( $thirty, $thirty_before_checkin );

    if ( ( $cmp == 1 ) or ( $cmp == 0 ) ) {
        $first_payment += $second_payment;
    }

    local $IO::Socket::SSL::VERSION = undef;

    # do the first payment
    my $return = $ENV{'HTTP_REFERER'} || 'http://www.hvh.com/';
    my $cancel = 'http://www.hvh.com/';


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

	
    #warn( "pay args: " . Dumper( \%pay_args ) );

    my %pay_res = $Paypal->DoDirectPayment( %pay_args );

    if ( $pay_res{ACK} eq 'Failure' ) {

        warn( "express checkout failed: " . Dumper( \%pay_res ) );

        $results->{invalid}->{payment_errors} = 1;

        my $url = _gen_redirect( $results, $q,
"&bktcc=1&first_payment=$first_payment&second_payment=$second_payment&booking_id=$booking_id&num_nights=$num_nights&local_taxes=$local_taxes&cleaning_fee=$cleaning_fee&nightly_rate=$nightly_rate&second_charge_date=$second_charge_date&deposit=$deposit&rental_subtotal=$rental_subtotal&total_rental_amount=$total_rental_amount"
        );

        return $self->redirect($url);
    }

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
                Credit_Card_Last_4__c  => ' ' . substr( $card, length($card) - 4 ),
                Credit_Card_Exp_Date__c   => $exp,
                X1st_Payment__c           => $first_payment,
                First_Payment_Received__c => _dbdate($date),
                Date__c                   => _dbdate($date),
                Second_Payment_Due_Date__c => _dbdate($second_charge_date),
                
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

    # look for a contact first
    my %contact_args = (
        Email           => $q->param('email'),
        FirstName       => $q->param('first_name'),
        LastName        => $q->param('last_name'),
        Phone           => $q->param('phone'),
        Contact_Type__c => 'Renter',
    );

    my $contact_id = _find_or_create_contact( $sf, \%contact_args );

    my $date = DateTime->now->mdy('/');
    # now make a booking
    my %sf_args = (

            type                   => 'Booking__c',
            Name                   => $name,
            Date__c                => _dbdate($date),
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

    my $r;
    eval {$r = $sf->create(%sf_args);};
    die $@ if $@;

    my $result = $r->envelope->{Body}->{createResponse}->{result};

    die "error creating booking: \n" . Dumper($result)
      unless ( ( $result->{success} eq 'true' ) && ( defined $result->{id} ) );

    my $booking_id = $result->{id};

    ######################
    # get the booking details
    my $query =
"Select Id, Security_Deposit_Amount__c, First_Payment_Amount__c, Second_Payment_Amount__c, Number_of_Nights__c, Tax_Rate__c, Cleaning_Fee__c, Nightly_List_Price__c from Booking__c where Id = '$booking_id'";

    my $res = $sf->query( query => $query );
    $result = $res->envelope->{Body}->{queryResponse}->{result};

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

    $total_rental_amount = Number::Format::round($total_rental_amount, 2);

    # recalc second payment
    $second_payment = $total_rental_amount + $deposit - $first_payment;

    # redirect to cc page
    my $url = _gen_redirect( $results, $q,
"&bktcc=1&first_payment=$first_payment&second_payment=$second_payment&booking_id=$booking_id&num_nights=$num_nights&local_taxes=$local_taxes&cleaning_fee=$cleaning_fee&nightly_rate=$nightly_rate&second_charge_date=$second_charge_date&deposit=$deposit&rental_subtotal=$rental_subtotal&total_rental_amount=$total_rental_amount"
    );

    return $self->redirect($url);
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
