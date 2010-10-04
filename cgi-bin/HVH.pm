package HVH;

use strict;
use warnings;

use WWW::Salesforce ();
use DateTime        ();
use URI::Escape     ();
use Data::Dumper;
use Cache::Memcached;

my $memd = Cache::Memcached->new({ servers => [ 'localhost:11211' ] });

use constant DEBUG => $ENV{HVH_DEBUG} || 0;

sub memd {
    my $class = shift;
    return $memd;
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
    my $Sf = eval { WWW::Salesforce->login(
        username => 'api@hvh.com',
        password => 'SaaS69dBfUy0GkDQB7oAdOxu77DJBFt',
    ); };
    die $@ if $@;
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
"Select Id from Booking__c where (Booking_Stage__c != 'Dead' and Booking_Stage__c != 'Working' and Booking_Stage__c != 'Unqualified'  and Booking_Stage__c != 'Canceled'  and Booking_Stage__c != 'Lost')  and Property_name__c = '$prop_id' and ( ";

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
