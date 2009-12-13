#!perl

use strict;
use warnings FATAL => 'all';

use Test::More tests => 2;                      # last test to print

use WWW::Salesforce::Simple;

warn("connecting...\n");
my $Sf = WWW::Salesforce::Simple->new( username => 'api@hvh.com',
	 password => 'SaaS69dBfUy0GkDQB7oAdOxu77DJBFt') or die $!;


BEGIN {
 use_ok('Bookit');
}

use DateTime;
my $yesterday = DateTime->now->subtract( days => 1 )->add(months => 2)->mdy('/');

my $today = DateTime->now->add(months => 2)->mdy('/');


ok( Bookit::check_booking( $Sf, '07/04/2010', '07/07/2010', 'a0650000003DhL8'));

# checkout data == checkin_date
ok( Bookit::check_booking( $Sf, '07/08/2010', '07/15/2010', 'a0650000003DhL8'));

# checkin_date == checkout_date
ok( Bookit::check_booking( $Sf, '07/16/2010', '07/22/2010', 'a0650000003DhL8'));


__END__

FIXME FIXME FIXME

my $prop_id = 'a0650000000sarX'; 
my $prop_name = 'Hideaway Bay';

my $ci = DateTime->new( year => '2010', day => '01', month => '01')->mdy('/');
my $co = DateTime->new( year => '2010', day => '07', month => '01')->mdy('/');

ok(Bookit::check_booking( $Sf, $ci, $co, '2015 should be available'));



$ci = DateTime->new( year => '2009', day => '21', month => '11')->mdy('/');
$co = DateTime->new( year => '2009', day => '28', month => '11')->mdy('/');

ok(! Bookit::check_booking( $Sf, $ci, $co, '11/21/09-11/28/09 should be booked'));


$ci = DateTime->new( year => '2009', day => '22', month => '11')->mdy('/');
$co = DateTime->new( year => '2009', day => '28', month => '11')->mdy('/');

ok(! Bookit::check_booking( $Sf, $ci, $co, '11/22/09-11/28/09 should be booked'));


$ci = DateTime->new( year => '2009', day => '22', month => '11')->mdy('/');
$co = DateTime->new( year => '2009', day => '27', month => '11')->mdy('/');

ok(! Bookit::check_booking( $Sf, $ci, $co, 'should be booked'));


$ci = DateTime->new( year => '2009', day => '20', month => '11')->mdy('/');
$co = DateTime->new( year => '2009', day => '30', month => '11')->mdy('/');

ok(! Bookit::check_booking( $Sf, $ci, $co, 'should be booked'));





