    <script type="text/javascript" />
    //<![CDATA[

    if (GBrowserIsCompatible()) {
      var map = new GMap2(document.getElementById("Hawaii"));
      map.setCenter(new GLatLng(20.753799, -155.987262));
      map.setZoom(5);
      map.setMapType(G_NORMAL_MAP);
      map.addControl(new GSmallMapControl());
      var icon_palm = new GIcon();
      icon_palm.shadow = "http://hvh2.hvh.com/img/solopalm.png"
      icon_palm.shadowSize = new GSize(0, 0);
      icon_palm.iconAnchor = new GPoint(0, 0);
      icon_palm.infoWindowAnchor = new GPoint(0, 0);
      icon_palm.image = "http://hvh2.hvh.com/img/solopalm.png";

      var marker_1 = new GMarker(new GLatLng(22.205314, -159.411288) , icon_palm);
      GEvent.addListener(marker_1, "click", function () {  marker_1.openInfoWindowHtml('<div style="width:175px;height:100px;"><a href="/phpdev/listing.php?prop_id=a0650000000sarbAAA"><font size="small">Plumeria Moon</font></a><br /><font size="small">Kilauea, Kauai</font></div>'); });
      map.addOverlay(marker_1);
      var marker_2 = new GMarker(new GLatLng(20.753799, -155.987262) , icon_palm);
      GEvent.addListener(marker_2, "click", function () {  marker_2.openInfoWindowHtml('<div style="width:175px;height:100px;"><a href="/phpdev/listing.php?prop_id=a0650000001OhF9AAK"><font size="small">Hana Mauai Hotel</font></a><br /><font size="small">Hana, Maui</font></div>'); });
      map.addOverlay(marker_2);
    }

    //]]>
    </script>