#!/usr/bin/perl

use strict;
use warnings;

use WWW::Salesforce::Simple;

warn("connecting...\n");
my $Sf = WWW::Salesforce::Simple->new( username => 'api@hvh.com',
	 password => 'SaaS69dBfUy0GkDQB7oAdOxu77DJBFt') or die $!;

use DateTime;
use Data::Dumper;

# test start and stop the same
my $year = '2007';
my $checkin_date = DateTime->new( year => $year,
                                month => '1',
                                day => '3');

$checkin_date = $checkin_date->ymd('-');
warn("checkin date: $checkin_date\n");

my $checkout_date = DateTime->new( year => $year,
                                month => '1',
                                day => '5');

$checkout_date = $checkout_date->ymd('-');
warn("checkout date: $checkout_date\n");

my $sql = "Select Id from Booking__c where ";

$sql .= "( ( Check_in_Date__c < $checkin_date ) and ( Check_out_Date__c > $checkin_date ) ) ";
# (booked_checkin) (new_checkin) (new_checkout) (booked_checkout)

$sql .= " or ( ( Check_out_Date__c < $checkout_date ) and ( Check_in_Date__c < $checkout_date ) and ( Check_in_Date__c > $checkin_date ) ) ";
# (new_checkin) (booked_checkin) (new_checkout) (booked_checkout)

$sql .= " or ( ( Check_in_Date__c < $checkin_date ) and ( ( Check_out_Date__c < $checkout_date ) and ( Check_out_Date__c > $checkin_date ) ) ) ";
# (booked_checkin) (new_checkin) (booked_checkout) (new_checkout)

$sql .= " or ( ( Check_in_Date__c > $checkin_date )  and ( Check_out_date__c < $checkout_date ) ) ";
# (new_checkin) (booked_checkin) (booked_checkout) (new_checkout)


warn("running query...\n");
my $res = $Sf->do_query($sql, []);
warn("query finished...\n");

print "\n" x 8;

print Dumper( $res );



