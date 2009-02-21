#!/usr/bin/perl

use strict;
use warnings;

use Bookit;

my $checkin = shift or die "$0 1/1/2010 1/10/2010\n";
my $checkout = shift or die "$0 1/1/2010 1/10/2010\n";

my $sf = WWW::Salesforce->login(
    username => 'api@hvh.com',
    password => 'SaaS69dBfUy0GkDQB7oAdOxu77DJBFt'
) or die $!;

my $prop_id = 'a0650000000sarX'; 
my $prop_name = 'Hideaway Bay';

my ($available, $cin, $cout) = Bookit::check_booking( $sf, $checkin, $checkout, $prop_id );

if ($available) {
	print "Available!\n";
} else {
	print "Booked already\n";
} 

