#!perl

use strict;
use warnings;

use WWW::Salesforce::Simple;

my $username = shift;
my $token = shift or warn "using default token\n";

warn("connecting...\n");
my $Sf = WWW::Salesforce::Simple->new(
    username => $username || 'api@hvh.com',
    password => $token    || 'SaaS69dBfUy0GkDQB7oAdOxu77DJBFt',
);
use Data::Dumper;

warn("grabbing tables...\n");
my $tables_ref;# = $Sf->get_tables();
print Dumper($tables_ref);

my $table = 'Property__c';
my $tables_ref = [ $table ];

warn("grabbing fields...\n");


foreach my $table (@{ $tables_ref}) {

	warn("processing table $table\n");
	my $raw_fields = $Sf->get_field_list($table);
	print Dumper($raw_fields) . "\n\n";
	my @fields = map { $_->{name} } @{$raw_fields};
	print  "Table $table has fields:\n" . Dumper(\@fields) . "\n\n";
}

my @a_fields = (
          'Id',
          'IsDeleted',
          'ParentId',
          'Name',
          'IsPrivate',
          'ContentType',
          'BodyLength',
#          'Body',
          'OwnerId',
          'CreatedDate',
          'CreatedById',
          'LastModifiedDate',
          'LastModifiedById',
          'SystemModstamp' );

my $foo = join(", ", @a_fields);
my $q = "select $foo from Attachment";
my $res = $Sf->do_query($q);

print "\n" x 8;

print Dumper( $res );

__END__
#print Dumper( \@fields );

my $qp = join( ", ", @fields );

my $q = 'select ' . $qp . ' from Property__c';

my $res = $Sf->do_query($q);

print "\n" x 8;

print Dumper( $res->[0] );

use Geo::Coder::Google;
my $geo =
  Geo::Coder::Google->new( apikey =>
'ABQIAAAAyhXzbW_tBTVZ2gviL0TQQxRl5tXefiK1-ZeuozlcWNgF3wNt9BSaAm_sI_TNkiqf_bzFgxHIfD1lpw'
  );

use HTML::GoogleMaps;

my $map =
  HTML::GoogleMaps->new(height => '600', width => '900', key =>
"ABQIAAAAyhXzbW_tBTVZ2gviL0TQQxRl5tXefiK1-ZeuozlcWNgF3wNt9BSaAm_sI_TNkiqf_bzFgxHIfD1lpw",
  );

$map->v2_zoom(5);
$map->info_window(1);
$map->controls( 'large_map_control', 'map_type_control');
$map->add_icon(shadow => 'http://www.hvh.com/images/pot.png', shadow_size => [50,    50], icon_anchor => [0,0], info_window_anchor => [0,0], name => 'jah', image => 'http://www.hvh.com/images/pot.png', image_size => [ 50,50] );
my @markers;
foreach my $row ( @{$res} ) {
    next unless defined $row->{Property_Address__c};
    next unless defined $row->{Property_Address__c};

#    $map->center( point => $row->{Property_Address__c} );
#    $map->add_marker( point => $row->{Property_Address__c} );
sleep 1;
warn("sleep");
    #next;
    my $location = $geo->geocode( location => $row->{Property_Address__c} );
    unless ($location) {
        warn("couldn't get location for " . $row->{Property_Address__c});
        next;
    }
    $map->add_marker( point => $row->{Property_Address__c}, html => '<p>JAH!</p>', icon => 'jah' );
    $row->{location} = $location;
    push @markers,
      {
        lat => $location->{Point}->{coordinates}->[0],
        lon => $location->{Point}->{coordinates}->[1],
      };

}
my ( $head, $map_div, $map_script ) = $map->render;

open(FH, '>', './foo.html') or die $!;

print FH << "END";
<html>
<head>
$head
</head>
<body>
hi
$map_div
$map_script
</body>
</html>
END

close(FH);
print 1;

__END__
use Geo::Google::StaticMaps;

my $url = Geo::Google::StaticMaps->url(
    size    => [ 400, 300 ],
    center  => $markers[0],
    zoom    => 13,
    markers => \@markers,
);

print 1;
sleep 1;

1;
