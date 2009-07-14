#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use Test::More tests => 2;

BEGIN {
    use_ok('Bookit');
    can_ok(qw( _payment ));
}

my %param = (
    prop_name       => 'Hideaway Bay',
    first_name      => 'Foo',
    last_name       => 'McGoo',
    phone           => '415.720.2103',
    checkin_date    => '06/01/12',
    checkout_date   => '06/10/12',
    exp_month       => '05',
    exp_year        => '2012',
    cvc             => '420',
    card_type       => 'Visa',
    card_number     =>  '4217658628469468',
    billing_address => '1440 Union',
    billing_city    => 'San Francisco',
    billing_state   => 'CA',
    billing_zip     => '94109',
    billing_country => 'US',
    email           => 'fred@redhotpenguin.com',
    guests          => 2,
    first_payment   => 120,
    second_payment  => 120,
    booking_id      => 1234,
    bktcc_next      => 1,
    num_nights      => 4,
    local_taxes     => '12%',
    cleaning_fee    => 200,
    nightly_rate    => 100,
    deposit         => 100,
);

use CGI;

my $cgi = CGI->new( \%param );

my $payment = Bookit->_payment($cgi);

sleep 1;
