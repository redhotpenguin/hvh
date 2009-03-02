#!/usr/bin/perl

use strict;
use warnings;

use lib '../cgi-bin';

use Bookit;

my $sf = Bookit::_sf_login();

    my %contact_args = (
        Email             => 'foo@foo.com',
        FirstName         => 'Foo',
        LastName          => 'Meister',
        MailingStreet     => '1234 high street',
        MailingCity       => 'San Francisco',
        MailingCountry    => 'United States',
        MailingState      => 'CA',
        Phone             => '415.720.2103',
        Contact_Type__c   => 'Renter',
    );


my $contact_id = Bookit::_find_or_create_contact( $sf, \%contact_args );

__END__


1;
