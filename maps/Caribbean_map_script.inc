    <script type="text/javascript" />
    //<![CDATA[

    if (GBrowserIsCompatible()) {
      var Caribbeanmap = new GMap2(document.getElementById("Caribbean"));
      Caribbeanmap.setCenter(new GLatLng(18.338096, -64.894095));
      Caribbeanmap.setZoom(9);
      Caribbeanmap.setMapType(G_NORMAL_MAP);
      Caribbeanmap.addControl(new GSmallMapControl());
      Caribbeanmap.addControl(new GMapTypeControl());
      var icon_palm = new GIcon();
      icon_palm.shadow = "http://www.hvh.com/img/clear.gif"
      icon_palm.shadowSize = new GSize(0, 0);
      icon_palm.iconAnchor = new GPoint(0, 30);
      icon_palm.infoWindowAnchor = new GPoint(0, 30);
      icon_palm.image = "http://www.hvh.com/img/lonepalm.outlinr.png";

      var Caribbeanmap_marker_1 = new GMarker(new GLatLng(18.3436, -64.9314) , icon_palm);
      GEvent.addListener(Caribbeanmap_marker_1, "click", function () {  Caribbeanmap_marker_1.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/phpdev/listing.php?prop_id=a0650000001w5BXAAY"><span style="font-size: 12px">Blue Horizons Villa</span></a><br /><span style="font-size: 12px">St. Thomas, Virgin Islands</span><br /><span style="font-size: 12px">Premier Home</span></div>'); });
      Caribbeanmap.addOverlay(Caribbeanmap_marker_1);
    }

    //]]>
    </script>