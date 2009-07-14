#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use Test::More tests => 2;

BEGIN {
    use_ok('Bookit');
    can_ok('Bookit', qw( _payment ));
}

my %param = (
    prop_name       => 'Kamala',
    first_name      => 'Foo',
    last_name       => 'McGoo',
    phone           => '415.720.2103',
    checkin_date    => '07/15/2009',
    checkout_date   => '07/16/2009',
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
    first_payment   => 1,
    second_payment  => 1,
    booking_id      => 1234,
    bktcc_next      => 1,
    num_nights      => 4,
    local_taxes     => '10%',
    cleaning_fee    => 1,
    nightly_rate    => 1,
    deposit         => 1,
);

use CGI;

my $cgi = CGI->new( \%param );

my $payment = Bookit->_payment($cgi);

sleep 1;
