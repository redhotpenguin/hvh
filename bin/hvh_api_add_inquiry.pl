#!perl

use strict;
use warnings;

use WWW::Salesforce::Simple;

my $username = shift;
my $token    = shift or die 'no token!';

my $Sf = WWW::Salesforce::Simple->new( username => $username,
                                       password => $token, );


use Data::Dumper;

my $tables_ref = $Sf->get_tables();

#print Dumper($tables_ref);

my $table = 'Inquiry__c';

my $raw_fields = $Sf->get_field_list( $table );

my @fields= map { $_->{name} } @{$raw_fields};

#print Dumper( \@fields );

my $qp = join(", ",  @fields);


my $new = $Sf->create(
'name' => 'Mike T',
'type' =>  'Inquiry__c');


print "\n" x 8;

print Dumper($new);

sleep 1;

1;
