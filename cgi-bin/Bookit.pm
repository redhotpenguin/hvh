package Bookit;

use strict;
use warnings;

use base qw( CGI::Application );

use Mail::Mailer        ();
use Data::FormValidator ();
use Data::FormValidator::Constraints qw(:closures);
use Business::PayPal::API   ();
use WWW::Salesforce::Simple ();
use DateTime                ();
use CGI::Application::Plugin::Redirect;
use URI::Escape ();
use Data::Dumper;

use constant DEBUG => 1;    #$ENV{HVH_DEBUG} || 1;

our $Paypal = Business::PayPal::API->new(
    Username  => 'mike_api1.hvh.com',
    Password  => '5Q2XGE9DZA27EFYL',
    Signature => 'AFcWxV21C7fd0v3bYYYRCpSSRl31AEOrqYMCSxLRpjsqiednmuLG7h7t',
    sandbox   => 1,
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

sub _gen_redirect {
    my ( $results, $q, $extra ) = @_;

    # set new url;
    my @fields =
      ( keys %{ $results->{invalid} }, keys %{ $results->{missing} } );

    my $url = '&invalid=' . join( '|', @fields );

    # add the current field values
    foreach my $invalid ( keys %{ $results->{invalid} } ) {
        $url .=
          '&' . $invalid . '=' . URI::Escape::uri_escape( $q->param($invalid) );
    }

    my %params = $q->Vars;
    foreach my $param ( keys %params ) {
        $url .= '&' . $param . '=' . URI::Escape::uri_escape( $params{$param} );
    }

    my ($lead) =
      $ENV{'HTTP_REFERER'} =~ m/^(.*?prop_id=\w+\&(?:bkt|fhh|cto)=1)/;

    $url = $lead . $url;

    $url .= $extra if $extra;

    return $url;
}

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
        }
    );

    my $q = $self->query;
    my $results = Data::FormValidator->check( $q, \%profile );

    if ( $results->has_missing or $results->has_invalid ) {

# 	warn("results, " . join(',', keys %{$results->{invalid}}) . ' missing;' . join(',', keys %{$results->{missing} } ));
        my $url = _gen_redirect( $results, $q );

        return $self->redirect($url);
    }

    # create salesforce inquiry
    my $r;
    eval {
        my $sf = _sf_login();

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

        $r = $sf->create(%sf_args);
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

    };

    die $@ if $@;

    #open(FH, '>/tmp/bar') or die $!
    #
    #;
    #print FH Dumper($r);
    #close(FH);
    #
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
    my ( $sf, $checkin_date, $checkout_date ) = @_;

    # sanity check, make sure it is at least 24 hours ahead in time
    my $dt_ci = _dtdate($checkin_date);
    my $dt_co = _dtdate($checkout_date);

    my $tomorrow = DateTime->now->add( days => 1 );

    if (   ( $dt_ci->epoch < $tomorrow->epoch )
        or ( $dt_co->epoch < $tomorrow->epoch ) )
    {

        warn("trying to book too early!");
        return;

    }

    #warn("in is " . DateTime->now->mdy('/'));
    #warn("in " . $dt_ci->epoch . ", tomrrow epoch " . $tomorrow->epoch);
    $checkin_date  = _dbdate($checkin_date);
    $checkout_date = _dbdate($checkout_date);

    #warn("checkin date $checkin_date, co $checkout_date");

    my $sql = "Select Id from Booking__c where ";

    $sql .= "( ( Check_in_Date__c < $checkin_date ) and ( Check_out_Date__c > $checkin_date ) ) ";
    # (booked_checkin) (new_checkin) (new_checkout) (booked_checkout)

    $sql .= " or ( ( Check_out_Date__c < $checkout_date ) and ( Check_in_Date__c < $checkout_date ) and ( Check_in_Date__c > $checkin_date ) ) ";
    # (new_checkin) (booked_checkin) (new_checkout) (booked_checkout)

    $sql .= " or ( ( Check_in_Date__c < $checkin_date ) and ( ( Check_out_Date__c < $checkout_date ) and ( Check_out_Date__c > $checkin_date ) ) ) ";
    # (booked_checkin) (new_checkin) (booked_checkout) (new_checkout)

    $sql .= " or ( ( Check_in_Date__c > $checkin_date )  and ( Check_out_date__c < $checkout_date ) ) ";
    # (new_checkin) (booked_checkin) (booked_checkout) (new_checkout)

    warn("checking for booking between in $checkin_date and out $checkout_date")
      if DEBUG;
    my $res = $sf->query( query => $sql );

    if ( $res->valueof('//queryResponse/result')->{size} != 0 )
    {    # found a conflicting booking

        #		open(FH, '>', '/tmp/foo') or die $!;
        #		print FH Dumper($res);
        #		print FH Dumper($res->valueof('//queryResponse/result')->{size});
        #		close(FH) or die $!;
        warn("booking conflict! ") if DEBUG;

        #		warn("res: " . Dumper($res)) if DEBUG;
        return;
    }

    warn("booking range open") if DEBUG;

    return ( 1, $checkin_date, $checkout_date );
}

sub _find_or_create_contact {
    my ( $sf, $q, $account_id ) = @_;

    my $name = join( ' ', $q->param('first_name'), $q->param('last_name') );
    my $contact_id = _find_contact( $sf, $name, $account_id );

    my %contact_args = (
        Email             => $q->param('email'),
        FirstName         => $q->param('first_name'),
        LastName          => $q->param('last_name'),
        MailingStreet     => $q->param('billing_street'),
        MailingCity       => $q->param('billing_city'),
        MailingPostalCode => $q->param('billing_zip'),
        MailingCountry    => $q->param('billing_country'),
        MailingState      => $q->param('billing_state'),
        Phone             => $q->param('phone'),
    );

    if ($contact_id) {

        # update the contact
        my $res = $sf->update(
            type      => 'Contact',
            ContactId => $contact_id,
            Name      => $name,
            Type      => 'Rental Customer',
            %contact_args,
        );

        my $result = $res->envelope->{Body}->{queryResponse}->{result};
        die "error updating contact id $contact_id\n"
          unless ( $result->{done} eq 'true' );

        return $contact_id;
    }

    # otherwise create a new contact
    my $r = $sf->create(
        type => 'Contact',
        Name => $name,
        Type => 'Rental Customer',
        %contact_args,
    );
    my $result = $r->envelope->{Body}->{queryResponse}->{result};
    die "error creating contact name $name\n"
      unless ( $result->{done} eq 'true' );

    # now grab the id of the new account
    $account_id = _find_account( $sf, $name );

    return $account_id if $account_id;

    # no contact id after creating one?
    die "Error creating account $name\n";
}

sub _find_contact {
    my ( $sf, $name, $account_id ) = @_;

    my $sql = <<SQL;
SELECT Id from Contact where Name = '$name' and AccountId = '$account_id'
SQL

    warn("running query\n") if DEBUG;
    my $r = $sf->query( query => $sql, limit => '1' )
      or die "SF query failed!: $sql";

    # things get ugly here
    my $result = $r->envelope->{Body}->{queryResponse}->{result};
    warn( "Result is " . Dumper($result) ) if DEBUG;

    # size > 0 indicates records returned
    my $size = $result->{size};
    my $contact_id;
    if ( defined $size && ( $size == 1 ) ) {

        warn("Found some records") if DEBUG;

        # uh huh, just get the first id
        $contact_id = $result->{records}->{Id}->[0];
        return $contact_id;
    }
    else {
        warn("No records found") if DEBUG;
        return;
    }
}

sub _find_or_create_account {
    my ( $sf, $q ) = @_;

    my $name = join( ' ', $q->param('first_name'), $q->param('last_name') );

    my $account_id = _find_account( $sf, $name );

    # return it if it exists
    return $account_id if $account_id;

    # otherwise create a new account
    my $r = $sf->create(
        Name => $name,
        Type => 'Rental Customer',
        type => 'Account'
    );
    my $result = $r->envelope->{Body}->{queryResponse}->{result};
    die "error creating account name $name\n"
      unless ( $result->{done} eq 'true' );

    # now grab the id of the new account
    $account_id = _find_account( $sf, $name );

    return $account_id if $account_id;

    # no account id after creating one?
    die "Error creating account $name\n";
}

sub _find_account {

    my ( $sforce, $name ) = @_;
    my $sql = <<SQL;
SELECT Id from Account where Name = '$name' and Type = 'Rental Customer'
SQL

    warn("running query\n") if DEBUG;
    my $r = $sforce->query( query => $sql, limit => '1' )
      or die "SF query failed!: $sql";

    # things get ugly here
    my $result = $r->envelope->{Body}->{queryResponse}->{result};
    warn( "Result is " . Dumper($result) ) if DEBUG;

    # size > 0 indicates records returned
    my $size = $result->{size};
    my $account_id;
    if ( defined $size && ( $size == 1 ) ) {

        warn("Found some records") if DEBUG;

        # uh huh, just get the first id
        $account_id = $result->{records}->{Id}->[0];
        return $account_id;
    }
    else {
        warn("No records found") if DEBUG;
        return;
    }

}

sub bookit {
    my $self = shift;

    my $q = $self->query;

    my @required = qw( prop_name first_name last_name
      email guests
      phone checkin_date checkout_date exp_month exp_year
      cvc card_type card_number billing_address billing_city
      billing_state billing_zip billing_country );

    my %profile = (
        required           => \@required,
        optional           => [qw( guests )],
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
            card_number     => cc_number( { fields => ['card_type'] } ),
        }
    );
    my $results = Data::FormValidator->check( $q, \%profile );

    if ( $results->has_missing or $results->has_invalid ) {

        warn(   "results:  invalid: "
              . join( ',', keys %{ $results->{invalid} } )
              . ', missing;'
              . join( ',', keys %{ $results->{missing} } ) );

        my $url = _gen_redirect( $results, $q );

        return $self->redirect($url);
    }

    # create salesforcebooking
    # the required args
    my $name = join( ' ',
        $q->param('first_name'),
        $q->param('last_name'),
        int( rand(100_000) ),
    );

    my $sf = eval { _sf_login() };
    die $@ if $@;

    my ( $is_available, $checkin_date, $checkout_date ) = check_booking(
        $sf,
        $q->param('checkin_date'),
        $q->param('checkout_date')
    );

    unless ($is_available) {
        my $url = _gen_redirect( $results, $q, '&booked=1' );
        return $self->redirect($url);
    }

    warn("booking date available, look for an existing account") if DEBUG;
    my $account_id = _find_or_create_account( $sf, $q );

    warn("now create a contact");
    my $contact_id = _find_or_create_contact( $sf, $q, $account_id );

    my ( $r, %sf_args );
    eval {
        %sf_args = (
            type                          => 'Booking__c',
            Name                          => $name,
            Booking_Contact_First_Name__c => $q->param('first_name'),
            Booking_Contact_Last_Name__c  => $q->param('last_name'),
            Booking_Contact_Email__c      => $q->param('email'),
            Property__c                   => $q->param('prop_name'),
            Check_in_Date__c  => _dbdate( $q->param('checkin_date') ),
            Check_out_Date__c => _dbdate( $q->param('checkout_date') ),
            Booking_Stage__c  => 'Pending',
            Booking_Contact_Mailing_Address__c => $q->param('billing_address'),
            Booking_Contact_Phone__c           => $q->param('phone'),
            Booking_Contact_State__c           => $q->param('billing_state'),
            Booking_Contact_Postal_Code__c     => $q->param('billing_zip'),
            Booking_Contact_Country__c         => $q->param('billing_country'),
            Booking_Description__c             => $q->param('comments'),
            Payment_Method__c                  => 'PayPal',
        );

        if ( $q->param('comments') ) {
            $sf_args{Booking_Comments__c} = $q->param('comments');
        }

        if ( $q->param('billing_zip') =~ m/^\d+$/ ) {
            $sf_args{Booking_Contact_Postal_Code__c} =
              $q->param('billing_zip') . '-0000';
        }

        # hack for salesforce bug
        if ( length( $q->param('guests') ) == 1 ) {
            $sf_args{Number_of_Guests__c} = '0' . $q->param('guests');
        }

        $r = $sf->create(%sf_args);
    };
    die $@ if $@ or !$r;

    my $result = $r->envelope->{Body}->{createResponse}->{result};
    open( FH, '>/tmp/bar' ) or die $!;
    print FH Dumper($result);
    close(FH) or die $!;

    # warn('result is ' . $result->{success});
    if ( $result->{success} eq 'false' ) {
        die( "Salesforce failed to create booking: " . Dumper($result) )
          ;    # . ", args: " . Dumper(\%sf_args));
    }

    warn("booking created, sf api call to get payment amounts") if DEBUG;
    my $query =
"Select Id, First_Payment_Amount__c, Second_Payment_Amount__c from Booking__c where Name = '"
      . $name . "'";

    # get the booking
    my $res = $sf->query( query => $query );
    my ( $id, $one_payment, $two_payment ) = @{$res};

    unless ( $id && $one_payment && $two_payment ) {
        die(
"query to created booking fail, id $id, one pay $one_payment, two pay $two_payment"
        );
    }

    warn("making paypal call") if DEBUG;
    my %pay_res;
    my $billto_name =
      join( ' ', $q->param('first_name'), $q->param('last_name') );
    if ( $checkin_date->subtract( days => 30 ) < DateTime->now ) {

        warn("paypal single payment") if DEBUG;

        # do one payment
        %pay_res = $Paypal->DoDirectPaymentRequest(
            PaymentAction         => 'Sale',
            OrderTotal            => $one_payment + $two_payment,
            TaxTotal              => 0.0,
            ShippingTotal         => 0.0,
            ItemTotal             => 0.0,
            HandlingTotal         => 0.0,
            CreditCardType        => ucfirst( $q->param('card_type') ),
            CreditCardNumber      => $q->param('card_number'),
            ExpMonth              => $q->param('exp_month'),
            ExpYear               => $q->param('exp_year'),
            CVV2                  => $q->param('cvc'),
            FirstName             => $q->param('first_name'),
            LastName              => $q->param('last_name'),
            Street1               => $q->param('billing_address'),
            Street2               => '',
            CityName              => $q->param('billing_city'),
            StateOrProvince       => $q->param('billing_state'),
            PostalCode            => $q->param('billing_zip'),
            Country               => $q->param('billing_country'),
            Payer                 => $q->param('email'),
            ShipToName            => $billto_name,
            ShipToStreet1         => $q->param('billing_address'),
            ShipToStreet2         => '',
            ShipToCityName        => $q->param('billing_city'),
            ShipToStateOrProvince => $q->param('billing_state'),
            ShipToCountry         => $q->param('billing_country'),
            CurrencyID            => 'USD',
            IPAddress             => $q->param('ip'),
            MerchantSessionID     => int( rand(100_000) ),
        );

    }
    else {

        # do two payments

        warn("paypal double payment") if DEBUG;

        %pay_res = $Paypal->CreateRecurringPaymentsProfile(
            SubscriberName   => $billto_name,
            BillingStartDate => DateTime->now->mdy('-'),
            ProfileReference => $q->param('first_name')
              . $q->param('last_name'),
            MaxFailedPayments         => 0,
            AutoBillOutstandingAmount => 'NoAutoBill',
            PaymentBillingPeriod      => 'day',
            PaymentBillingFrequency   => 30,
            PaymentTotalBillingCycles => 2,
            PaymentAmount             => $two_payment,
            PaymentShippingAmount     => 0.0,
            PaymentTaxAmount          => 0.0,
            ProfileReference          => $id,
            InitialAmount             => $one_payment,
            CCPayerName               => $billto_name,
            CCPayer                   => $q->param('email'),
            CCPayerStreet1            => $q->param('billing_address'),
            CCPayerStreet2            => '',
            CCPayerCityName           => $q->param('billing_city'),
            CCPayerStateOrProvince    => $q->param('billing_state'),
            CCPayerCountry            => $q->param('billing_country'),
            CCPayerPostalCode         => $q->param('billing_zip'),
            CCPayerPhone              => $q->param('phone'),
            CreditCardType            => $q->param('card_type'),
            CreditCardNumber          => $q->param('card_number'),
            ExpMonth                  => $q->param('exp_month'),
            ExpYear                   => $q->param('exp_year'),
            CVV2                      => $q->param('cvc'),
        );

    }

    warn( "response: " . Dumper( \%pay_res ) ) if DEBUG;

    unless ( $pay_res{Ack} eq 'Success' ) {
        warn( "errors: " . Dumper( $pay_res{Errors} ) );
        return $self->redirect('http://www.hvh.com/booking_errors.html');
    }

    warn "Successful payment";

    # update salesforce
    eval {
        $sf->update(
            type => 'Booking__c',
            {
                Id               => $id,
                Booking_Stage__c => 'Booked - First Payment',
            },
        );
    };
    die $@ if $@;

    my $uri = $ENV{'HTTP_REFERER'};
    $uri =~ s/bkt\=1/bkt\=success/;
    return $self->redirect($uri);
}

sub hold {
    my $self = shift;

    my $q = $self->query;

    my @required = qw( prop_id first_name last_name email
      phone checkin_date checkout_date address city state country zip guests);

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
    my $results = Data::FormValidator->check( $q, \%profile );

    if ( $results->has_missing or $results->has_invalid ) {
        my $url = _gen_redirect( $results, $q );

        return $self->redirect($url);
    }

    my $sf = _sf_login();
    my ( $is_available, $checkin_date, $checkout_date ) = check_booking(
        $sf,
        $q->param('checkin_date'),
        $q->param('checkout_date')
    );

    unless ($is_available) {
        return $self->redirect("https://www.hvh.com/double_booked.html");
    }

    # create salesforce inquiry
    my $r;
    eval {

        # the required args
        my %sf_args = (
            type => 'Inquiry__c',
            Name =>
              join( ' ', $q->param('first_name'), $q->param('last_name'), ),

            Inquiry_First_Name__c => $q->param('first_name'),
            Inquiry_Last_Name__c  => $q->param('last_name'),
            Inquiry_Email__c      => $q->param('email'),
            Property__c           => $q->param('prop_id'),
            Check_in_Date__c      => _dbdate( $q->param('checkin_date') ),
            Check_out_Date__c     => _dbdate( $q->param('checkout_date') ),
            Inquiry_Stage__c      => '48 Hour Hold'
        );

        _add_optional_args( $q, \%Inquiry, \%sf_args );

        # fixup the request
        _hack_the_soap( $q, \%sf_args );

        $r = $sf->create(%sf_args);
    };

    die $@ if $@;

    my $uri = $ENV{'HTTP_REFERER'};
    $uri =~ s/fhh\=1/fhh\=success/;
    $self->redirect($uri);
}

sub _add_optional_args {
    my ( $q, $Inquiry, $sf_args ) = @_;

    # add the optional args
    foreach my $opt ( keys %{$Inquiry} ) {
        if ( $q->param($opt) ) {
            $sf_args->{ $Inquiry->{$opt} } = $q->param($opt);
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

