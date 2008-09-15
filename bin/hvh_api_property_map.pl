
use strict;
use warnings;

use WWW::Salesforce::Simple;
use Data::Dumper;

use constant DEBUG => $ENV{'HVH_DEBUG'} || 0;

chdir('/var/www/hvh2.hvh.com');

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
'ABQIAAAAyhXzbW_tBTVZ2gviL0TQQxS9Wc_wSMS9I-_uq3bV6rDa-qiUhxSx_eykChOiJtvGX7Z5-OemFI5dNQ'
#  www.hvh.com 'ABQIAAAAyhXzbW_tBTVZ2gviL0TQQxRl5tXefiK1-ZeuozlcWNgF3wNt9BSaAm_sI_TNkiqf_bzFgxHIfD1lpw'
  );

use HTML::GoogleMaps;

my %map_zones = ( "North_America" => { height => '270', width => '398', center => 'Kansas City, KS', controls => ['small_map_control', 'map_type_control' ], zoom => 3 },
	 "Hawaii" => { height => '220', width => '398', center => 'Honolulu, Oahu', zoom => 6 , controls => ['small_map_control', 'map_type_control' ]},
	 "Alaska" => { height => '220', width => '398', center => 'Cordova, AK', zoom => 4, controls => ['small_map_control', 'map_type_control'] },
	 "Europe" => { height => '300', width => '199', center => 'Berlin GE', zoom => 5 , controls => ['small_map_control', 'map_type_control']   },
	 "Caribbean" => { height => '200', width => '398', center => 'St Thomas, VI', zoom => 9 , controls => ['small_map_control', 'map_type_control'] }, );

foreach my $display_map ( keys %map_zones ) {

    print "\n******************\nBuilding display map $display_map\n" if DEBUG;
#warn("height is " . $map_zones{$display_map}->{height});
#warn("width is " . $map_zones{$display_map}->{width});
    my $map = HTML::GoogleMaps->new(
        height => $map_zones{$display_map}->{height},
        width  => $map_zones{$display_map}->{width},
        key =>
'ABQIAAAAyhXzbW_tBTVZ2gviL0TQQxS9Wc_wSMS9I-_uq3bV6rDa-qiUhxSx_eykChOiJtvGX7Z5-OemFI5dNQ'
# www.hvh.com "ABQIAAAAyhXzbW_tBTVZ2gviL0TQQxRl5tXefiK1-ZeuozlcWNgF3wNt9BSaAm_sI_TNkiqf_bzFgxHIfD1lpw",
    );

    $map->map_id($display_map);
    $map->map_type('normal');
    $map->v2_zoom($map_zones{$display_map}->{zoom});
#    my $center = $geo->geocode( location => $map_zones{$display_map}->{center} );
   # print "Center is " . Dumper($center->{Point}->{coordinates}) . "\n\n";
    $map->center( $map_zones{$display_map}->{center} );
#[
#	$center->{Point}->{coordinates}->[0],
#	$center->{Point}->{coordinates}->[1], ],
# );
    $map->info_window(1);
    if ($map_zones{$display_map}->{controls}) {
        $map->controls( @{ $map_zones{$display_map}->{controls}} );
    }
    $map->add_icon(
        shadow             => 'http://hvh2.hvh.com/img/clear.gif',
        shadow_size        => [ 0, 0 ],
        icon_anchor        => [ 0, 30 ],
        info_window_anchor => [ 0, 30 ],
        name               => 'palm',
        image              => 'http://hvh2.hvh.com/img/lonepalm.outlinr.png',
        image_size         => [ 25, 30 ]
    );
    my @markers;


    foreach my $row ( @{$res} ) {

	next unless defined $row->{Display_Map__c};
	next unless $row->{Display_Map__c} eq $display_map;

        next unless $row->{City__c} && $row->{State__c} . ' ' . $row->{Zip__c};

        my $address =
          $row->{City__c} . ', ' . $row->{State__c} . ' ' . $row->{Zip__c};

        next unless defined $address;

	# don't overload google api
	sleep 1;

        print "processing address $address\n\n" if DEBUG;

        my $location = $geo->geocode( location => $address );
        unless ($address) {
            warn("couldn't get geocode for addr $address");
            next;
        }
	unless ($location) {
		warn("couldn't get location for addr $address");
		next;
	}
	#print Dumper($row) . "\n\n\n\n";
	print "writing to display map $display_map for addr $address\n";
	my $category = $row->{Category__c};
	$category =~ s/_/ /g;
        $map->add_marker(
            point => $address,
            html  => 
'<a href="/phpdev/listing.php?prop_id=' .
		$row->{Id}->[0] . '"><span style="font-size: 12px">' . $row->{Name} . '</span></a><br />' .
	'<span style="font-size: 12px">' . $row->{City__c} . ', ' . $row->{Location__c} . '</span>' .
	'<br /><span style="font-size: 12px">' . $category .  '</span>',
            icon  => 'palm'
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

      my $filename = "./maps/" . $display_map . "_" . $part . ".inc";
      print "Filename is $filename\n" if DEBUG;
        my $part = $map_hash{$part};
        open( FH, '>', $filename ) or die $!;

        print FH $part;

        close(FH);
    }
}

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
