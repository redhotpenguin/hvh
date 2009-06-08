#!perl

use strict;
use warnings FATAL => 'all';

use Test::More tests => 7;                      # last test to print

BEGIN {
 use_ok('Bookit');
}

# hideaway bay
my $url = 'https://www.hvh.com/xdev/listing.php?prop_id=a0650000000sarXAAQ&bkt=1';

use Test::WWW::Mechanize;

my $mech = Test::WWW::Mechanize->new;

$mech->get_ok($url);

$mech->submit_form( form_number => 2, fields => {} );

$mech->content_like(qr/missing or invalid/i, 'missing/invalid');

# try correct fields
$mech->submit_form( form_number => 2, fields => {
	first_name => 'Foo',
	last_name  => 'Testmonkey',
	email      => 'fred@redhotpenguin.com',
	phone      => '415.720.2103',
	guests     => '2',
	checkin_date => '1/1/2010',
	checkout_date => '1/10/2010',
	card_type  => 'Visa',
	card_number => '3106547872286615',
	exp_month   => '12',
	exp_year    => '12',
	cvc	    => '331',
	billing_address => '1440 Union Street',
	billing_state   => 'CA',
	billing_country => 'United-States',
	billing_zip     => '94109',
	billing_city    => 'San Francisco',
	comments        => 'how many fools are ready to move?',
}, );

$mech->content_like(qr/payment ok/, 'payment ok');

__END__
use WWW::Salesforce::Simple;

warn("connecting...\n");
my $Sf = WWW::Salesforce::Simple->new( username => 'api@hvh.com',
	 password => 'SaaS69dBfUy0GkDQB7oAdOxu77DJBFt') or die $!;



