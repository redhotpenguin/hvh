#!/usr/bin/perl

use strict;
use warnings;
    $ENV{HTTPS_CERT_FILE} = '/etc/pki/tls/cert.pem';

use WWW::Salesforce;
BEGIN {
    $WWW::Salesforce::Constants::TYPES{booking__c}->{x1st_payment__c} = 'xsd:double';
}
use DateTime;
my $sf = eval { WWW::Salesforce->login(
        username => 'api@hvh.com',
        password => 'SaaS69dBfUy0GkDQB7oAdOxu77DJBFt',
    )  };

die $@ if $@;

my $date = DateTime->now->mdy('/');

# update salesforce booking
my $r;
eval {
        $r = $sf->update(
            type => 'Booking__c',
            {
                id                        => 'a0850000003MIje',
                Booking_Stage__c          => 'Booked - First Payment',
                Credit_Card_Last_4__c  => ' ' . '1234',
                Credit_Card_Exp_Date__c   => '06/12',
                X1st_Payment__c           => '12.22',
                First_Payment_Received__c => _dbdate($date),
                Date__c                   => _dbdate($date),
                Second_Payment_Due_Date__c => _dbdate($date),
		OwnerId => '00550000000zVJY',
                
            },
        );
};
die $@ if $@;

sleep 1;
sub _dbdate {
    my $date = shift;

    #   warn("Date is $date");
    my ( $month, $day, $year ) = split( /\//, $date );
    if ( length($year) == 2 ) {
        $year = '20' . $year;
    }

    $date = DateTime->new(
        year  => $year,
        month => $month,
        day   => $day,
	);

    #   $date->set_time_zone( 'local' );
    $date = $date->ymd('-');

    return $date;
}
