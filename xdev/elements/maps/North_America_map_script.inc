    <script type="text/javascript" />
    //<![CDATA[

    if (GBrowserIsCompatible()) {
      var North_Americamap = new GMap2(document.getElementById("North_America"));
      North_Americamap.setCenter(new GLatLng(39.1066667, -94.6763889));
      North_Americamap.setZoom(3);
      North_Americamap.setMapType(G_NORMAL_MAP);
      North_Americamap.addControl(new GSmallMapControl());
      North_Americamap.addControl(new GMapTypeControl());
      var icon_palm = new GIcon();
      icon_palm.shadow = "http://www.hvh.com/img/clear.gif"
      icon_palm.shadowSize = new GSize(0, 0);
      icon_palm.iconAnchor = new GPoint(0, 30);
      icon_palm.infoWindowAnchor = new GPoint(0, 30);
      icon_palm.image = "http://www.hvh.com/img/lonepalm.outlinr.png";

      var North_Americamap_marker_1 = new GMarker(new GLatLng(41.2834563, -70.0994605) , icon_palm);
      GEvent.addListener(North_Americamap_marker_1, "click", function () {  North_Americamap_marker_1.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000002KX41AAG"><span style="font-size: 12px">Whales Watch II</span></a><br /><span style="font-size: 12px">Nantucket, Nantucket Island</span><br /><span style="font-size: 12px">Premier Home</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_1);
      var North_Americamap_marker_2 = new GMarker(new GLatLng(22.2119444, -159.4122222) , icon_palm);
      GEvent.addListener(North_Americamap_marker_2, "click", function () {  North_Americamap_marker_2.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000003DhL8AAK"><span style="font-size: 12px">Kamala</span></a><br /><span style="font-size: 12px">Kilauea, Kauai</span><br /><span style="font-size: 12px">Signature Home</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_2);
      var North_Americamap_marker_3 = new GMarker(new GLatLng(39.0204508, -123.4159263) , icon_palm);
      GEvent.addListener(North_Americamap_marker_3, "click", function () {  North_Americamap_marker_3.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000004y7BKAAY"><span style="font-size: 12px">High Rock Ranch</span></a><br /><span style="font-size: 12px">Boonville, Anderson Valley / Napa</span><br /><span style="font-size: 12px">Signature Home</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_3);
      var North_Americamap_marker_4 = new GMarker(new GLatLng(43.75, -111.034) , icon_palm);
      GEvent.addListener(North_Americamap_marker_4, "click", function () {  North_Americamap_marker_4.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000001LJNrAAO"><span style="font-size: 12px">Tablerock</span></a><br /><span style="font-size: 12px">Alta, Wyoming</span><br /><span style="font-size: 12px">Signature Home</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_4);
      var North_Americamap_marker_5 = new GMarker(new GLatLng(39.327962, -120.1832533) , icon_palm);
      GEvent.addListener(North_Americamap_marker_5, "click", function () {  North_Americamap_marker_5.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000001OhF4AAK"><span style="font-size: 12px">River Street Inn</span></a><br /><span style="font-size: 12px">Truckee, North Lake Tahoe</span><br /><span style="font-size: 12px">Signature Hotel</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_5);
      var North_Americamap_marker_6 = new GMarker(new GLatLng(32.2306364, -80.7325287) , icon_palm);
      GEvent.addListener(North_Americamap_marker_6, "click", function () {  North_Americamap_marker_6.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000001OhFEAA0"><span style="font-size: 12px">Hilton Head Getaway</span></a><br /><span style="font-size: 12px">Hilton Head, Hilton Head Island</span><br /><span style="font-size: 12px">Premier Home</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_6);
      var North_Americamap_marker_7 = new GMarker(new GLatLng(30.4367302, -98.1120116) , icon_palm);
      GEvent.addListener(North_Americamap_marker_7, "click", function () {  North_Americamap_marker_7.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000002KyvZAAS"><span style="font-size: 12px">Waterstone Lodge</span></a><br /><span style="font-size: 12px">Spicewood, Lake Travis</span><br /><span style="font-size: 12px">Premier Home</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_7);
      var North_Americamap_marker_8 = new GMarker(new GLatLng(33.8302961, -116.5452921) , icon_palm);
      GEvent.addListener(North_Americamap_marker_8, "click", function () {  North_Americamap_marker_8.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000002C9ScAAK"><span style="font-size: 12px">Palm Oasis at Alta</span></a><br /><span style="font-size: 12px">South Palm Springs, Alta</span><br /><span style="font-size: 12px">Premier Home</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_8);
      var North_Americamap_marker_9 = new GMarker(new GLatLng(39.26721, -119.963988) , icon_palm);
      GEvent.addListener(North_Americamap_marker_9, "click", function () {  North_Americamap_marker_9.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000005zwEQAAY"><span style="font-size: 12px">Tahoe Fun House</span></a><br /><span style="font-size: 12px">Incline Village, Lake Tahoe</span><br /><span style="font-size: 12px">Signature Home</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_9);
      var North_Americamap_marker_10 = new GMarker(new GLatLng(30.2522245, -88.1169354) , icon_palm);
      GEvent.addListener(North_Americamap_marker_10, "click", function () {  North_Americamap_marker_10.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000002ExpLAAS"><span style="font-size: 12px">Purple Parrot</span></a><br /><span style="font-size: 12px">Dauphin Island, Dauphin Island</span><br /><span style="font-size: 12px">Premier Home</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_10);
      var North_Americamap_marker_11 = new GMarker(new GLatLng(22.8905327, -109.9167371) , icon_palm);
      GEvent.addListener(North_Americamap_marker_11, "click", function () {  North_Americamap_marker_11.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000002G0qJAAS"><span style="font-size: 12px">Casa de la Jolla</span></a><br /><span style="font-size: 12px">Cabo San Lucas, Cabo</span><br /><span style="font-size: 12px">Premier Home</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_11);
      var North_Americamap_marker_12 = new GMarker(new GLatLng(37.648546, -118.972079) , icon_palm);
      GEvent.addListener(North_Americamap_marker_12, "click", function () {  North_Americamap_marker_12.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000002Iis4AAC"><span style="font-size: 12px">Mammoth Ski House</span></a><br /><span style="font-size: 12px">Mammoth Lakes, Mammoth Mountain</span><br /><span style="font-size: 12px">Premier Home</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_12);
      var North_Americamap_marker_13 = new GMarker(new GLatLng(44.0581728, -121.3153096) , icon_palm);
      GEvent.addListener(North_Americamap_marker_13, "click", function () {  North_Americamap_marker_13.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000002IismAAC"><span style="font-size: 12px">Mt. Bachelor Executive</span></a><br /><span style="font-size: 12px">Bend, Mt. Bachelor</span><br /><span style="font-size: 12px">Premier Home</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_13);
      var North_Americamap_marker_14 = new GMarker(new GLatLng(17.7802778, -101.7225) , icon_palm);
      GEvent.addListener(North_Americamap_marker_14, "click", function () {  North_Americamap_marker_14.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000005WKOoAAO"><span style="font-size: 12px">Casa Majahua</span></a><br /><span style="font-size: 12px">Troncones, Mexico</span><br /><span style="font-size: 12px">Premier Home</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_14);
      var North_Americamap_marker_15 = new GMarker(new GLatLng(30.267153, -97.7430608) , icon_palm);
      GEvent.addListener(North_Americamap_marker_15, "click", function () {  North_Americamap_marker_15.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000007NmPRAA0"><span style="font-size: 12px">Lake Austin Waterfront</span></a><br /><span style="font-size: 12px">Austin, Westlake</span><br /><span style="font-size: 12px">Signature Home</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_15);
    }

    //]]>
    </script>