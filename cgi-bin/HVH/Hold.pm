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

    warn("checkin $checkin_date, checkout $checkout_date, prop $prop_id") if DEBUG;

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
"Select Id from Booking__c where (Booking_Stage__c != 'Dead' and Booking_Stage__c != 'Working' and Booking_Stage__c != 'Canceled' and Booking_Stage__c != 'Lost' and Booking_Stage__c != 'Unqualified')  and Property_name__c = '$prop_id' and ( ";

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
#	warn("sql is $sql");
    my $res = $sf->query( query => $sql );

    if ( $res->valueof('//queryResponse/result')->{size} != 0 )
    {    # found a conflicting booking

    	#my $result = $res->envelope->{Body}->{queryResponse}->{result};
        #warn("booking conflict! " . Dumper($result)) if DEBUG;

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

sub held {
    my ($self) = @_;

    my $prop_id = $self->query->param('prop_id');
    my $prop = $memd->get("property|$prop_id");
    unless ($prop) { # we need to fetch it

	warn("hitting salesforce cache for $prop_id");
	$prop = $self->retrieve_property($prop_id);
        $memd->set("property|$prop_id" => $prop);
    }


    my $output = $self->tt_process('held.tmpl', {query => $self->query, prop => $prop});
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
    unless ($prop) { # we need to fetch it

	warn("hitting salesforce cache for $prop_id");
	$prop = $self->retrieve_property($prop_id);
        $memd->set("property|$prop_id" => $prop);
    }

    $tmpl{'prop'} = $prop;
    $tmpl{'query'} = $self->query;
    $tmpl{'prop_id'} = $self->query->param('prop_id');
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
        "Extremely_Private__c", "Large_Yard__c", "Outdoor_Shower__c",
	"Hammock__c",
        "Patio_Lanai__c", "Tennis_Courts__c", 
	"Basketball_Hoop__c", "Volleyball_Court__c",);


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
Teaser__c Description__c Location__c
 State__c City__c Special_Amenities__c
Solutions_Customer__c Check_in_Time__c Check_out_Time__c
Nightly_Rate_List_Price__c Local_Tax_Rate__c Security_Deposit__c 
Housekeeping_Fee__c Website__c Sleeps__c Bedrooms__c Bathrooms__c
Bathtubs__c Showers__c );

my @images = qw( Image_URL_1__c Image_URL_2__c
Image_URL_3__c Image_URL_4__c Image_URL_5__c Image_URL_6__c
Image_URL_7__c Image_URL_8__c );

    my $base_fields = join(',', @bases, @images);

    my $sql = <<"SQL";
SELECT $base_fields, $q_fields
FROM Property__c where Id='$prop_id' and Available_to_the_Public__c=true
SQL

    my $result = $self->run_select($sql);

    foreach my $am ( @amenities ) {
	if ($result->{$am} eq 'true') {
        push @{$result->{amenities}}, $self->convert($am);
	}
    }


    foreach my $am ( @outdoors ) {
	if ($result->{$am} eq 'true') {
	        push @{$result->{outdoors}}, $self->convert($am);
	}
    }

    foreach my $am ( @features ) {
	if ($result->{$am} eq 'true') {
        push @{$result->{features}}, $self->convert($am);
	}
    }

    foreach my $am ( @media ) {
	if ($result->{$am} eq 'true') {
        push @{$result->{media}}, $self->convert($am);
	}
    }

    foreach my $am ( @bed ) {
	if ($result->{$am} eq 'true') {
        push @{$result->{beds}}, $self->convert($am);
	}
    }

    foreach my $am ( @kitchen ) {
	if ($result->{$am} eq 'true') {
        push @{$result->{kitchens}}, $self->convert($am);
	}
    }

    foreach my $am ( @images ) {
	if (defined $result->{$am}) {
        	push @{$result->{images}}, $result->{$am};
	}
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
    my @required = qw( prop_id first_name last_name email guests
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
        $q->param('checkout_date'),
        $q->param('prop_id'),
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

    if ( $q->param('zip') =~ m/^\d+$/ ) {
        $contact_args{MailingPostalCode} = $q->param('zip') . '-0000';
    }
    else {
        $contact_args{MailingPostalCode} = $q->param('zip');
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

    my $sql = <<"SQL";
SELECT Booking_Number__c
FROM Booking__c where Id='$booking_id'
SQL

    my $res = $self->run_select($sql);
    my $bn = $res->{'Booking_Number__c'};

    # ok the booking was made ok
    # warn("booking created id $booking_id, sf api call to get payment amounts")
    #  if DEBUG;

    return $self->redirect("/cgi-bin/hold.cgi?rm=held&booking_id=$bn&prop_id=" . $q->param('prop_id'));
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
