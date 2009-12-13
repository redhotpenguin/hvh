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

    }

    //]]>
    </script>