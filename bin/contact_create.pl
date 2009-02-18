#!/usr/bin/perl

use strict;
use warnings;

use WWW::Salesforce::Simple;

warn("connecting...\n");

my $sforce = WWW::Salesforce->login(
    username => 'api@hvh.com',
    password => 'SaaS69dBfUy0GkDQB7oAdOxu77DJBFt'
) or die $!;

my $email = 'bluesmetal@yahoo.com';
my $name  = 'Foo Monkey7';

my $sql = <<SQL;
SELECT Id from Account where Name = '$name' and Type = 'Rental Customer'
SQL

warn("running query\n");
my $res = $sforce->query( query => $sql, limit => '1' );

use Data::Dumper;
warn("dumping result\n");

#print Dumper( $res );

print "\n\n\n";

my $result = $res->envelope->{Body}->{queryResponse}->{result};
print "Result is " . Dumper($result);

my $size = $result->{size};
if ( defined $size && ( $size == 1 ) ) {

    print "Found some records\n";

    my $records = $result->{records};
    print "Result is " . Dumper($records);
    print "Result type is " . $records->{Id}->[0] . "\n";

}
else {

    print "no records found, creating one\n";
    my $query = <<QUERY;
INSERT into Account (Name, Type) values ('$name', 'Rental Customer')
QUERY

    #  my $r = $sforce->query( query => $query );

    my $r = $sforce->create(
        Name => $name,
        Type => 'Rental Customer',
        type => 'Account'
    );
    my $result = $res->envelope->{Body}->{queryResponse}->{result};

    warn( Dumper($result) );
    if ( $result->{done} eq 'true' ) {
        warn("YEAAAH BOOOY!");
    }

    # grab the id
    my $res = $sforce->query( query => $sql, limit => '1' );
    $result = $res->envelope->{Body}->{queryResponse}->{result};
    print "Result is " . Dumper($result);

    my $size = $result->{size};
    if ( defined $size && ( $size == 1 ) ) {

        print "Found some records\n";

        my $records = $result->{records};
        print "Result is " . Dumper($records);
        print "Result type is " . $records->{Id}->[0] . "\n";
    }
}

