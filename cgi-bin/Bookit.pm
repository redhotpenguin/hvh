package Bookit;

use strict;
use warnings;

use base qw( CGI::Application );

use Mail::Mailer        ();
use Data::FormValidator ();
use Data::FormValidator::Constraints qw(:closures);
use Business::PayPal::API        qw( DirectPayments);
use WWW::Salesforce::Simple                  ();
use DateTime                                 ();
use CGI::Application::Plugin::Redirect;
use URI::Escape ();
use Data::Dumper;

use constant DEBUG => 1;    #$ENV{HVH_DEBUG} || 1;

our %Paypal = (
    Username  => 'mike_api1.hvh.com',
    Password  => '5Q2XGE9DZA27EFYL',
    Signature => 'AFcWxV21C7fd0v3bYYYRCpSSRl31AEOrqYMCSxLRpjsqiednmuLG7h7t',
);

=cut

our %Paypal = (
    Username  => 'gunthe_1236035242_biz_api1.yahoo.com',
    Password  => '1236035264',
    Signature => 'AOkez-Qt58iwz5J-Ge-o4XsPgbKKA3zrI4VO4HHiPGu3RXI0TB7343YC',
    sandbox   => 1,
);

=cut

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
	no warnings;
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

    $checkin_date  = _dbdate($checkin_date);
    $checkout_date = _dbdate($checkout_date);

    # warn("checkin date $checkin_date, co $checkout_date");

    my $sql =
      "Select Id from Booking__c where Property_name__c = '$prop_id' and ( ";

    $sql .=
"( ( Check_in_Date__c < $checkin_date ) and ( Check_out_Date__c > $checkin_date ) and ( Check_in_Date__c < $checkout_date ) and ( Check_out_Date__c > $checkout_date) ) ";

    # (booked_checkin) (new_checkin) (new_checkout) (booked_checkout)

    $sql .=
" or ( ( Check_in_Date__c < $checkin_date ) and (  Check_out_Date__c > $checkin_date ) and ( Check_in_Date__c < $checkout_date ) and ( Check_out_Date__c < $checkout_date ) ) ";

    # (booked_checkin) (new_checkin) (booked_checkout) (new_checkout)

    $sql .=
" or ( ( Check_in_Date__c > $checkin_date ) and ( Check_out_Date__c > $checkin_date )  and ( Check_in_Date__c < $checkout_date ) and ( Check_out_Date__c > $checkout_date ) )";

    # (new_checkin) (booked_checkin)  (new_checkout) (booked_checkout)

    $sql .=
" or ( ( Check_in_Date__c > $checkin_date ) and ( Check_out_Date__c > $checkin_date ) and ( Check_in_Date__c < $checkout_date ) and ( Check_out_Date__c < $checkout_date ) ) )";

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
            type      => 'Contact',
            { id        => $contact_id,
            %{$contact_args}, },
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

=cut

    if (DEBUG) {
        open( FH, '>/tmp/errors' ) or die $!;
        print FH Dumper($results);
        close(FH) or die $!;
    }
=cut
 

=cut
        warn(   "results:  invalid: "
              . join( ',', keys %{ $results->{invalid} } )
              . ', missing;'
              . join( ',', keys %{ $results->{missing} } ) );
=cut

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
        MailingStreet   => $q->param('billing_address'),
        MailingCity     => $q->param('billing_city'),
        MailingCountry  => $q->param('billing_country'),
        MailingState    => $q->param('billing_state'),
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
"Select Id, First_Payment_Amount__c, Second_Payment_Amount__c from Booking__c where Id = '$booking_id'";

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

    ###########################################
    # make the paypal payment
    my $payment =
      $result->{records}->{First_Payment_Amount__c};
      #$result->{records}->{Second_Payment_Amount__c};

    warn("making paypal call for booking id $booking_id") if DEBUG;
    my %pay_res;
    my $billto_name =
      join( ' ', $q->param('first_name'), $q->param('last_name') );

    my ( $year, $month, $day ) = split( /-/, $checkin_date );
    $checkin_date =
      DateTime->new( month => $month, year => $year, day => $day );

    my $Paypal = Business::PayPal::API->new(%Paypal);

	my %paypal_args = (
        PaymentAction         => 'Sale',
        OrderTotal            => $payment,
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
        CityName              => $q->param('billing_city'),
        StateOrProvince       => $q->param('billing_state'),
        PostalCode            => $q->param('billing_zip'),
        Country               => $q->param('billing_country'),
        Payer                 => $q->param('email'),
        CityName        => $q->param('billing_city'),
        StateOrProvince => $q->param('billing_state'),
        Country         => $q->param('billing_country'),
        CurrencyID            => 'USD',
        IPAddress             => $ENV{'REMOTE_ADDR'},
        MerchantSessionID     => int( rand(100_000) ),
    );

    if (DEBUG) {
        open( FH, '>/tmp/payment_args' ) or die $!;
        print FH Dumper( \%paypal_args);
        close(FH) or die $!;
    }


    # do one payment
    %pay_res = $Paypal->DoDirectPaymentRequest( %paypal_args );

    if (DEBUG) {
        open( FH, '>/tmp/payment' ) or die $!;
        print FH Dumper( \%pay_res );
        close(FH) or die $!;
    }

    unless ( $pay_res{Ack} eq 'Success' ) {

	$results->{invalid}->{payment_errors} = 1;
 
	my $url = _gen_redirect( $results, $q );
        return $self->redirect($url);
    }

    warn "Successful payment" if DEBUG;
    ################################################

    ############################
    # update salesforce booking
    eval {
        $sf->update(
            type => 'Booking__c',
            {
                Id               => $booking_id,
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

1;
