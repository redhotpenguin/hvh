    <script type="text/javascript" />
    //<![CDATA[

    if (GBrowserIsCompatible()) {
      var map = new GMap2(document.getElementById("North_America"));
      map.setCenter(new GLatLng(39.102746, -94.626202));
      map.setZoom(3);
      map.setMapType(G_NORMAL_MAP);
      map.addControl(new GSmallMapControl());
      var icon_palm = new GIcon();
      icon_palm.shadow = "http://hvh2.hvh.com/img/solopalm.png"
      icon_palm.shadowSize = new GSize(0, 0);
      icon_palm.iconAnchor = new GPoint(0, 0);
      icon_palm.infoWindowAnchor = new GPoint(0, 0);
      icon_palm.image = "http://hvh2.hvh.com/img/solopalm.png";

      var marker_1 = new GMarker(new GLatLng(43.756026, -110.946409) , icon_palm);
      GEvent.addListener(marker_1, "click", function () {  marker_1.openInfoWindowHtml('<div style="width:175px;height:100px;"><a href="/phpdev/listing.php?prop_id=a0650000001LJNrAAO"><font size="small">Tablerock</font></a><br /><font size="small">Alta, Wyoming</font></div>'); });
      map.addOverlay(marker_1);
      var marker_2 = new GMarker(new GLatLng(22.210839, -159.400986) , icon_palm);
      GEvent.addListener(marker_2, "click", function () {  marker_2.openInfoWindowHtml('<div style="width:175px;height:100px;"><a href="/phpdev/listing.php?prop_id=a0650000000sarXAAQ"><font size="small">Hideaway Bay</font></a><br /><font size="small">Kauai, Hawaii</font></div>'); });
      map.addOverlay(marker_2);
      var marker_3 = new GMarker(new GLatLng(39.345294, -120.173003) , icon_palm);
      GEvent.addListener(marker_3, "click", function () {  marker_3.openInfoWindowHtml('<div style="width:175px;height:100px;"><a href="/phpdev/listing.php?prop_id=a0650000001OhF4AAK"><font size="small">River Street Inn</font></a><br /><font size="small">Truckee, North Lake Tahoe</font></div>'); });
      map.addOverlay(marker_3);
      var marker_4 = new GMarker(new GLatLng(37.938746, -107.813425) , icon_palm);
      GEvent.addListener(marker_4, "click", function () {  marker_4.openInfoWindowHtml('<div style="width:175px;height:100px;"><a href="/phpdev/listing.php?prop_id=a0650000001OhFJAA0"><font size="small">Mountainside Inn</font></a><br /><font size="small">Telluride, Colorado</font></div>'); });
      map.addOverlay(marker_4);
      var marker_5 = new GMarker(new GLatLng(36.269973, -121.807748) , icon_palm);
      GEvent.addListener(marker_5, "click", function () {  marker_5.openInfoWindowHtml('<div style="width:175px;height:100px;"><a href="/phpdev/listing.php?prop_id=a0650000001OhFAAA0"><font size="small">Post Ranch Inn</font></a><br /><font size="small">Big Sur, California</font></div>'); });
      map.addOverlay(marker_5);
      var marker_6 = new GMarker(new GLatLng(32.230636, -80.732529) , icon_palm);
      GEvent.addListener(marker_6, "click", function () {  marker_6.openInfoWindowHtml('<div style="width:175px;height:100px;"><a href="/phpdev/listing.php?prop_id=a0650000001OhFEAA0"><font size="small">Hilton Head Getaway</font></a><br /><font size="small">Hilton Head Is., Palmetto Dunes</font></div>'); });
      map.addOverlay(marker_6);
    }

    //]]>
    </script>