package Bookit;

use strict;
use warnings;

use base qw( CGI::Application );

use Mail::Mailer ();
use Data::FormValidator ();
use Data::FormValidator::Constraints qw(:closures);
use Business::PayPal::API ();
use WWW::Salesforce::Simple ();
use DateTime ();

use CGI::Application::Plugin::Redirect;

our $Paypal = Business::PayPal::API->new(
	Username => 'mike_api1.hvh.com',
	Password => '5Q2XGE9DZA27EFYL',
	Signature => 'AFcWxV21C7fd0v3bYYYRCpSSRl31AEOrqYMCSxLRpjsqiednmuLG7h7t',
	sandbox => 1,
);

sub setup {
	my $self = shift;
	$self->start_mode('contact');
	$self->run_modes(
	[ qw( bookit contact hold ) ] );
}

our %Inquiry = ( address => 'Inquiry_Address_1__c',
		 city    => 'Inquiry_City__c',
	      	 state   => 'Inquiry_State__c',
		 zip     => 'Inquiry_Zip__c',
		 country => 'Inquiry_Country__c',
		 phone   => 'Inquiry_Phone__c',
		 guests  => 'Number_of_Guests__c',
		 comments => 'Inquiry_Comments__c', );


	
sub contact {
	my ( $self) = @_;

	my @required = qw( prop_name first_name last_name email
		checkin_date checkout_date  );


        my %profile = (
            required => \@required,
            optional => [ keys %Inquiry ],
            constraint_methods => {
                email       => email(),
                first_name  => valid_first(),
                last_name   => valid_last(),
		checkin_date => valid_date(),
		checkout_date => valid_date(),
            }
        );

	my $q = $self->query;

        my $results = Data::FormValidator->check( $q, \%profile );

	if ( $results->has_missing or $results->has_invalid ) {
		# set new url;
		return $self->redirect( 'http://www.hvh.com/missing_elements.html' );
	}

	# create salesforce inquiry
	eval {
		my $sf = _sf_login();

		# the required args
		my %sf_args = (
			Name          => join(' ', $q->param('first_name'),
						   $q->param('last_name'), rand(10), ),

			Inquiry_First_Name__c => $q->param('first_name'),
			Inquiry_Last_Name__c  => $q->param('last_name'),
			Inquiry_Email__c      => $q->param('email'),
			Property__c           => $q->param('prop_name'),
			Check_in_Time__c      => $q->param('checkin_date'),
          		Check_out_Time__c     => $q->param('checkout_date'),
			Inquiry_Stage__c      => 'Open',
		);

		# add the optional args
		foreach my $opt ( keys %Inquiry) {
			if ($q->param($opt)) {
				$sf_args{$Inquiry{$opt}} = $q->param($opt);
			}
		}

		$sf->upsert( type => 'Inquiry__c', ,\%sf_args );
	};

	die $@ if $@;
	
	return $self->redirect( 'http://www.hvh.com/contact_made_ok.html' );
}	

sub _sf_login {

	my $Sf = WWW::Salesforce->login(
	    		username => 'api@hvh.com',
	    		password => 'SaaS69dBfUy0GkDQB7oAdOxu77DJBFt',
		) or die $!;
	return $Sf;
}

sub _check_booking {
	my ($sf, $checkin_date, $checkout_date) = @_;
	# checkin date
	my ($month, $day, $year) = split(/\//, $checkin_date);
	$checkin_date = DateTime->new( year => $year,
					  month => $month,
					  day => $day,);

	$checkin_date->set_time_zone( 'local' );
	$checkin_date = $checkin_date->ymd('-');

	# checkout date
	($month, $day, $year) = split(/\//, $checkout_date);
	$checkout_date = DateTime->new( year => $year,
					  month => $month,
					  day => $day,);

	$checkout_date->set_time_zone( 'local' );
	$checkout_date = $checkout_date->ymd('-');

	# check to see if these dates conflict with an existing booking
	my $sql = "Select Id from Booking__c where ( ( Check_in_Date__c < $checkin_date ) and ( Check_out_Date > $checkin_date ) ) or ( ( Check_out_Date__c < $checkout_date ) and ( Check_in_date__c > $checkin_date ) ) or  ( ( Check_in_Date__c > $checkin_date ) and ( Check_in_Date__c < $checkout_date ) and ( Check_out_date__c > $checkout_date ) )";

	my $res = $sf->do_query($sql);
	if (defined $res->[0]) { # found a conflicting booking
		return (1, $checkin_date, $checkout_date);
	}

	return;
}


sub bookit {
	my $self = shift;

	my $q = $self->query;

	my @required = qw( prop_name first_name last_name
		address city state country email
		phone checkin_date checkout_date
		cvv2 card_type card_number );

        my %profile = (
            required => \@required,
            optional => [qw( guests )],
            constraint_methods => {
                email       => email(),
                zip         => zip(),
 		phone       => phone(),
                first_name  => valid_first(),
                last_name   => valid_last(),
                month       => valid_month(),
                year        => valid_year(),
                cvv2        => valid_cvv(),
                city        => valid_city(),
		checkin_date => valid_date(),
		checkout_date => valid_date(),
                street      => valid_street(),
                card_type   => cc_type(),
                card_number => cc_number( { fields => ['card_type'] } ),
            }
        );
        my $results = Data::FormValidator->check( $q, \%profile );
	
	# create salesforcebooking
	# the required args
	my $name =  join(' ', $q->param('first_name'),
			      $q->param('last_name'), int(rand(100_000)),);

	my $sf = eval { _sf_login() };
	die $@ if $@;


	my ($is_available, $checkin_date, $checkout_date) = _check_booking(
		 $sf,
		 $q->param('checkin_date'), 
		 $q->param('checkout_date'));

	unless ($is_available) {
		return $self->redirect("https://www.hvh.com/double_booked.html");
	}

	eval {
		my %sf_args = (
			Name => $name,
			Booking_Contact_First_Name__c => $q->param('first_name'),
			Booking_Contact_Last_Name__c  => $q->param('last_name'),
			Booking_Contact_Email__c      => $q->param('email'),
			Property__c           => $q->param('prop_name'),
			Check_in_Date__c      => $q->param('checkin_date'),
          		Check_out_Date__c     => $q->param('checkout_date'),
			Booking_Stage__c      => 'Pending',
			Booking_Contact_Mailing_Address__c => $q->param('address'),
			Booking_Contact_Phone__c => $q->param('phone'),
			Booking_Contact_State__c => $q->param('state'),
			Booking_Contact_Postal_Code__c => $q->param('zip'),
			Booking_Contact_Country__c  => $q->param('country'),
			Booking_Description__c      => $q->param('comments'),
			Payment_Method__c           => 'PayPal',
		);

		$sf->upsert( type => 'Booking__c', ,\%sf_args );
	};
	die $@ if $@;

	my $query = "Select Id, First_Payment_Amount__c, Second_Payment_Amount__c from Booking__c where Name = '" . $name . "'";
	# get the booking
	my $res = $sf->do_query($q);
	my ($id, $one_payment, $two_payment) = @{$res};

	my %pay_res;
	my $billto_name = join(' ', $q->param('first_name'), $q->param('last_name') );
	if ($checkin_date->subtract( days => 30 ) < DateTime->now) {
		# do one payment
		%pay_res = $Paypal->DoDirectPaymentRequest(
			PaymentAction => 'Sale',
			OrderTotal => $one_payment + $two_payment,
			TaxTotal   => 0.0,
			ShippingTotal => 0.0,
			ItemTotal => 0.0,
			HandlingTotal => 0.0,
			CreditCardType => ucfirst($q->param('card_type')),
			CreditCardNumber => $q->param('card_number'),
			ExpMonth         => $q->param('month'),
			ExpYear          => $q->param('year'),
			CVV2             => $q->param('cvv2'),
			FirstName        => $q->param('first_name'),
			LastName         => $q->param('last_name'),
			Street1          => $q->param('address'),
			Street2          => '',
			CityName         => $q->param('city'),
			StateOrProvince  => $q->param('state'),
			PostalCode       => $q->param('zip'),
			Country          => $q->param('country'),
			Payer            => $q->param('email'),
			ShipToName       => $billto_name,
			ShipToStreet1    => $q->param('address'),
			ShipToStreet2    => '',
			ShipToCityName   => $q->param('city'),
			ShipToStateOrProvince => $q->param('state'),
			ShipToCountry    => $q->param('country'),
			CurrencyID       => 'USD',
			IPAddress        => $q->param('ip'),
			MerchantSessionID => int(rand(100_000)),
		);


	} else {
		# do two payments
	
	    %pay_res = $Paypal->CreateRecurringPaymentsProfile(
	  SubscriberName => $billto_name,
	  BillingStartDate => DateTime->now->mdy('-'),
	  ProfileReference => $q->param('first_name') . $q->param('last_name'),
	  MaxFailedPayments => 0,
	  AutoBillOutstandingAmount => 'NoAutoBill',
	  PaymentBillingPeriod => 'day',
	  PaymentBillingFrequency     => 30,
	  PaymentTotalBillingCycles => 2,
	  PaymentAmount => $two_payment,
	  PaymentShippingAmount => 0.0,
	  PaymentTaxAmount      => 0.0,
	  ProfileReference =>  $id,
	  InitialAmount => $one_payment,
	  CCPayerName => $billto_name,
	  CCPayer     => $q->param('email'),
	  CCPayerStreet1 => $q->param('address'),
	  CCPayerStreet2 => '',
	  CCPayerCityName => $q->param('city'),
	  CCPayerStateOrProvince => $q->param('state'),
	  CCPayerCountry => $q->param('country'),
	  CCPayerPostalCode => $q->param('zip'),
	  CCPayerPhone => $q->param('phone'),
	  CreditCardType => $q->param('card_type'),
	  CreditCardNumber => $q->param('card_numer'),
	  ExpMonth => $q->param('exp_month'),
	  ExpYear   => $q->param('exp_year'),
	  CVV2      => $q->param('cvv2'),
		  );


		
	}


		use Data::Dumper;
		warn("response: " . Dumper(\%pay_res));

		unless ( $pay_res{Ack} eq 'Success' ) {
			warn("errors: " . Dumper($pay_res{Errors}));
			return $self->redirect('http://www.hvh.com/booking_errors.html');
		}

		warn "Successful payment";

		# update salesforce
		eval { $sf->update( type => 'Booking__c',
				{ Id => $id,
	   			  Booking_Stage__c => 'Booked - First Payment', },
		 ) };
		die $@ if $@;


		return $self->redirect('http://www.hvh.com/booking_success.html');	
}



sub hold {
	my $self = shift;

	my $q = $self->query;

	my @required = qw( prop_name first_name last_name email
		phone checkin_date checkout_date address city state country zip );

        my %profile = (
            required => \@required,
            optional => [ qw( comments guests ) ],
            constraint_methods => {
                email       => email(),
                first_name  => valid_first(),
                last_name   => valid_last(),
		checkin_date => checkin_date(),
		checkout_date => checkout_date(),
            }
        );
        my $results = Data::FormValidator->check( $q, \%profile );
	
	if ( $results->has_missing or $results->has_invalid ) {
		# set new url;
		my $redir_url;
		$self->redirect( $redir_url );
	}

	my $sf = _sf_login();
	my ($is_available, $checkin_date, $checkout_date) = _check_booking(
		 $sf,
		 $q->param('checkin_date'), 
		 $q->param('checkout_date'));

	unless ($is_available) {
		return $self->redirect("https://www.hvh.com/double_booked.html");
	}

	
	# create salesforce inquiry
	eval {

		# the required args
		my %sf_args = (
			Name                  => join(' ', $q->param('first_name'),
							   $q->param('last_name'), ),

			Inquiry_First_Name__c => $q->param('first_name'),
			Inquiry_Last_Name__c  => $q->param('last_name'),
			Inquiry_Email__c      => $q->param('email'),
			Property__c           => $q->param('prop_name'),
			Check_in_Time__c      => $q->param('checkin_date'),
          		Check_out_Time__c     => $q->param('checkout_date'),
			Inquiry_Stage__c      => '48 Hour Hold',
		);

		# add the optional args
		foreach my $opt (keys %Inquiry) {
			if ($q->param($opt)) {
				$sf_args{$Inquiry{$opt}} = $q->param($opt);
			}
		}

		$sf->upsert( 'Inquiry__c', ,\%sf_args );
	};

	die $@ if $@;
	
	$self->redirect( 'http://www.hvh.com/hold_created.html' );
}	

sub valid_date {

    return sub {
        my $dfv = shift;
        my $val = $dfv->get_current_constraint_value;

	return unless $val =~ m/^\d{1,2}\/\d{1,2}\/20\d{2}$/;

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



