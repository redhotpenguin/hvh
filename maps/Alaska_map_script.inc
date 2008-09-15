    <script type="text/javascript" />
    //<![CDATA[

    if (GBrowserIsCompatible()) {
      var Alaskamap = new GMap2(document.getElementById("Alaska"));
      Alaskamap.setCenter(new GLatLng(60.547768, -145.758625));
      Alaskamap.setZoom(4);
      Alaskamap.setMapType(G_NORMAL_MAP);
      Alaskamap.addControl(new GSmallMapControl());
      Alaskamap.addControl(new GMapTypeControl());
      var icon_palm = new GIcon();
      icon_palm.shadow = "http://hvh2.hvh.com/img/clear.gif"
      icon_palm.shadowSize = new GSize(0, 0);
      icon_palm.iconAnchor = new GPoint(0, 30);
      icon_palm.infoWindowAnchor = new GPoint(0, 30);
      icon_palm.image = "http://hvh2.hvh.com/img/lonepalm.outlinr.png";

      var Alaskamap_marker_1 = new GMarker(new GLatLng(60.547768, -145.758625) , icon_palm);
      GEvent.addListener(Alaskamap_marker_1, "click", function () {  Alaskamap_marker_1.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/phpdev/listing.php?prop_id=a0650000001OhFBAA0"><span style="font-size: 12px">Orca Adventure Lodge</span></a><br /><span style="font-size: 12px">Cordova, Alaska</span><br /><span style="font-size: 12px">Premier Inn</span></div>'); });
      Alaskamap.addOverlay(Alaskamap_marker_1);
    }

    //]]>
    </script>