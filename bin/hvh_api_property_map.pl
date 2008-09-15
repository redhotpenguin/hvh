
use strict;
use warnings;

use WWW::Salesforce::Simple;
use Data::Dumper;

use constant DEBUG => $ENV{'HVH_DEBUG'} || 0;

my $username = shift;
my $token = shift or warn "using default token\n";

print "connecting...\n" if DEBUG;
my $Sf = WWW::Salesforce::Simple->new(
    username => $username || 'fred@redhotpenguin.com',
    password => $token    || 'yomaingJN9fVMtleBighIslxY3EZxuE',
);

my $table = 'Property__c';

print "grabbing fields...\n" if DEBUG;

my $raw_fields = $Sf->get_field_list($table);
my @fields = map { $_->{name} } @{$raw_fields};

#print "Table $table has fields:\n" . Dumper( \@fields ) . "\n\n" if DEBUG;

#print Dumper( \@fields ) if DEBUG;

my $qp = join( ", ", @fields );

my $q = 'select ' . $qp . ' from Property__c';

my $res = $Sf->do_query($q);

print "\n" x 8 if DEBUG;

print Dumper( $res->[0] ) if DEBUG;

use Geo::Coder::Google;
my $geo =
  Geo::Coder::Google->new( apikey =>
'ABQIAAAAyhXzbW_tBTVZ2gviL0TQQxRl5tXefiK1-ZeuozlcWNgF3wNt9BSaAm_sI_TNkiqf_bzFgxHIfD1lpw'
  );

use HTML::GoogleMaps;

my @map_zones = ( "North_America", "Hawaii", "Alaska", "Europe", "Caribbean" );

foreach my $display_map (@map_zones) {

    my $map = HTML::GoogleMaps->new(
        height => '600',
        width  => '900',
        key =>
"ABQIAAAAyhXzbW_tBTVZ2gviL0TQQxRl5tXefiK1-ZeuozlcWNgF3wNt9BSaAm_sI_TNkiqf_bzFgxHIfD1lpw",
    );

    $map->v2_zoom(4);
    $map->info_window(1);
    $map->controls( 'large_map_control', 'map_type_control' );
    $map->add_icon(
        shadow             => 'http://hvh2.hvh.com/img/solopalm.png',
        shadow_size        => [ 0, 0 ],
        icon_anchor        => [ 0, 0 ],
        info_window_anchor => [ 0, 0 ],
        name               => 'jah',
        image              => 'http://hvh2.hvh.com/img/solopalm.png',
        image_size         => [ 30, 30 ]
    );
    my @markers;

    $map->center( point => $res->[0]->{Property_Address__c} );

    foreach my $row ( @{$res} ) {


        next unless $row->{City__c} && $row->{State__c} . ' ' . $row->{Zip__c};
        my $address =
          $row->{City__c} . ', ' . $row->{State__c} . ' ' . $row->{Zip__c};
        warn("address $address");

        next unless defined $address;

        print "processing address $address\n\n" if DEBUG;

        warn("sleep 1") if DEBUG;
        sleep 1;

        my $location = $geo->geocode( location => $address );
        unless ($address) {
            warn("couldn't get geocode for addr $address");
            next;
        }
        $map->add_marker(
            point => $address,
            html  => '<p>JAH!</p>',
            icon  => 'jah'
        );
        $row->{location} = $location;
        push @markers,
          {
            lat => $location->{Point}->{coordinates}->[0],
            lon => $location->{Point}->{coordinates}->[1],
          };

    }
    my ( $head, $map_div, $map_script ) = $map->render;

    my %map_hash =
      ( head => $head, map_div => $map_div, map_script => $map_script );

    foreach my $part ( keys %map_hash ) {

      my $filename = "./" . $display_map . "_" . $part . ".inc";
      print "Filename is $filename\n" if DEBUG;
        my $part = $map_hash{$part};
        open( FH, '>', $filename ) or die $!;

        print FH $part;

        close(FH);
    }
}

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
