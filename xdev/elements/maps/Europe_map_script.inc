    <script type="text/javascript" />
    //<![CDATA[

    if (GBrowserIsCompatible()) {
      var Europemap = new GMap2(document.getElementById("Europe"));
      Europemap.setCenter(new GLatLng(52.5234051, 13.4113999));
      Europemap.setZoom(5);
      Europemap.setMapType(G_NORMAL_MAP);
      Europemap.addControl(new GSmallMapControl());
      Europemap.addControl(new GMapTypeControl());
      var icon_palm = new GIcon();
      icon_palm.shadow = "http://www.hvh.com/img/clear.gif"
      icon_palm.shadowSize = new GSize(0, 0);
      icon_palm.iconAnchor = new GPoint(0, 30);
      icon_palm.infoWindowAnchor = new GPoint(0, 30);
      icon_palm.image = "http://www.hvh.com/img/lonepalm.outlinr.png";

      var Europemap_marker_1 = new GMarker(new GLatLng(53.344104, -6.2674937) , icon_palm);
      GEvent.addListener(Europemap_marker_1, "click", function () {  Europemap_marker_1.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000002bIekAAE"><span style="font-size: 12px">dylan Dublin</span></a><br /><span style="font-size: 12px">Dublin, Ireland</span><br /><span style="font-size: 12px">Premier Hotel</span></div>'); });
      Europemap.addOverlay(Europemap_marker_1);
      var Europemap_marker_2 = new GMarker(new GLatLng(51.4971789, -0.1460208) , icon_palm);
      GEvent.addListener(Europemap_marker_2, "click", function () {  Europemap_marker_2.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000002bIepAAE"><span style="font-size: 12px">41</span></a><br /><span style="font-size: 12px">London, London City</span><br /><span style="font-size: 12px">Premier Hotel</span></div>'); });
      Europemap.addOverlay(Europemap_marker_2);
    }

    //]]>
    </script>