    <script type="text/javascript" />
    //<![CDATA[

    if (GBrowserIsCompatible()) {
      var North_Americamap = new GMap2(document.getElementById("North_America"));
      North_Americamap.setCenter(new GLatLng(39.102746, -94.626202));
      North_Americamap.setZoom(3);
      North_Americamap.setMapType(G_NORMAL_MAP);
      North_Americamap.addControl(new GSmallMapControl());
      North_Americamap.addControl(new GMapTypeControl());
      var icon_palm = new GIcon();
      icon_palm.shadow = "http://hvh2.hvh.com/img/clear.gif"
      icon_palm.shadowSize = new GSize(0, 0);
      icon_palm.iconAnchor = new GPoint(0, 30);
      icon_palm.infoWindowAnchor = new GPoint(0, 30);
      icon_palm.image = "http://hvh2.hvh.com/img/lonepalm.outlinr.png";

      var North_Americamap_marker_1 = new GMarker(new GLatLng(43.756026, -110.946409) , icon_palm);
      GEvent.addListener(North_Americamap_marker_1, "click", function () {  North_Americamap_marker_1.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/phpdev/listing.php?prop_id=a0650000001LJNrAAO"><span style="font-size: 12px">Tablerock</span></a><br /><span style="font-size: 12px">Alta, Wyoming</span><br /><span style="font-size: 12px">Signature Home</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_1);
      var North_Americamap_marker_2 = new GMarker(new GLatLng(22.205314, -159.411288) , icon_palm);
      GEvent.addListener(North_Americamap_marker_2, "click", function () {  North_Americamap_marker_2.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/phpdev/listing.php?prop_id=a0650000000sarXAAQ"><span style="font-size: 12px">Hideaway Bay</span></a><br /><span style="font-size: 12px">Kilauea, Kauai</span><br /><span style="font-size: 12px">Signature Home</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_2);
      var North_Americamap_marker_3 = new GMarker(new GLatLng(39.345294, -120.173003) , icon_palm);
      GEvent.addListener(North_Americamap_marker_3, "click", function () {  North_Americamap_marker_3.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/phpdev/listing.php?prop_id=a0650000001OhF4AAK"><span style="font-size: 12px">River Street Inn</span></a><br /><span style="font-size: 12px">Truckee, North Lake Tahoe</span><br /><span style="font-size: 12px">Signature Inn</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_3);
      var North_Americamap_marker_4 = new GMarker(new GLatLng(37.938746, -107.813425) , icon_palm);
      GEvent.addListener(North_Americamap_marker_4, "click", function () {  North_Americamap_marker_4.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/phpdev/listing.php?prop_id=a0650000001OhFJAA0"><span style="font-size: 12px">Mountainside Inn</span></a><br /><span style="font-size: 12px">Telluride, Colorado</span><br /><span style="font-size: 12px">Premier Inn</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_4);
      var North_Americamap_marker_5 = new GMarker(new GLatLng(36.269973, -121.807748) , icon_palm);
      GEvent.addListener(North_Americamap_marker_5, "click", function () {  North_Americamap_marker_5.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/phpdev/listing.php?prop_id=a0650000001OhFAAA0"><span style="font-size: 12px">Post Ranch Inn</span></a><br /><span style="font-size: 12px">Big Sur, California</span><br /><span style="font-size: 12px">Signature Inn</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_5);
      var North_Americamap_marker_6 = new GMarker(new GLatLng(32.230636, -80.732529) , icon_palm);
      GEvent.addListener(North_Americamap_marker_6, "click", function () {  North_Americamap_marker_6.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/phpdev/listing.php?prop_id=a0650000001OhFEAA0"><span style="font-size: 12px">Hilton Head Getaway</span></a><br /><span style="font-size: 12px">Hilton Head, Palmetto</span><br /><span style="font-size: 12px">Premier Home</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_6);
      var North_Americamap_marker_7 = new GMarker(new GLatLng(39.643596, -106.37841) , icon_palm);
      GEvent.addListener(North_Americamap_marker_7, "click", function () {  North_Americamap_marker_7.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/phpdev/listing.php?prop_id=a0650000001wXsLAAU"><span style="font-size: 12px">Sonnenalp Resort</span></a><br /><span style="font-size: 12px">Vail, Colorado</span><br /><span style="font-size: 12px">Premier Inn</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_7);
      var North_Americamap_marker_8 = new GMarker(new GLatLng(39.345294, -120.173003) , icon_palm);
      GEvent.addListener(North_Americamap_marker_8, "click", function () {  North_Americamap_marker_8.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/phpdev/listing.php?prop_id=a0650000001wXsGAAU"><span style="font-size: 12px">Truckee Ski Home</span></a><br /><span style="font-size: 12px">Truckee, North Lake Tahoe</span><br /><span style="font-size: 12px">Premier Home</span></div>'); });
      North_Americamap.addOverlay(North_Americamap_marker_8);
    }

    //]]>
    </script>