    <script type="text/javascript" />
    //<![CDATA[

    if (GBrowserIsCompatible()) {
      var map = new GMap2(document.getElementById("Caribbean"));
      map.setCenter(new GLatLng(18.338096, -64.894095));
      map.setZoom(9);
      map.setMapType(G_NORMAL_MAP);
      map.addControl(new GSmallMapControl());
      var icon_palm = new GIcon();
      icon_palm.shadow = "http://hvh2.hvh.com/img/solopalm.png"
      icon_palm.shadowSize = new GSize(0, 0);
      icon_palm.iconAnchor = new GPoint(0, 0);
      icon_palm.infoWindowAnchor = new GPoint(0, 0);
      icon_palm.image = "http://hvh2.hvh.com/img/solopalm.png";

      var marker_1 = new GMarker(new GLatLng(18.3436, -64.9314) , icon_palm);
      GEvent.addListener(marker_1, "click", function () {  marker_1.openInfoWindowHtml('<div style="width:175px;height:100px;"><a href="/phpdev/listing.php?prop_id=a0650000001w5BXAAY"><font size="small">Blue Horizons Villa</font></a><br /><font size="small">St. Thomas, Virgin Islands</font></div>'); });
      map.addOverlay(marker_1);
    }

    //]]>
    </script>