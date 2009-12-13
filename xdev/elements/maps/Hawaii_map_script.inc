    <script type="text/javascript" />
    //<![CDATA[

    if (GBrowserIsCompatible()) {
      var Hawaiimap = new GMap2(document.getElementById("Hawaii"));
      Hawaiimap.setCenter(new GLatLng(21.3069444, -157.8583333));
      Hawaiimap.setZoom(6);
      Hawaiimap.setMapType(G_NORMAL_MAP);
      Hawaiimap.addControl(new GSmallMapControl());
      Hawaiimap.addControl(new GMapTypeControl());
      var icon_palm = new GIcon();
      icon_palm.shadow = "http://www.hvh.com/img/clear.gif"
      icon_palm.shadowSize = new GSize(0, 0);
      icon_palm.iconAnchor = new GPoint(0, 30);
      icon_palm.infoWindowAnchor = new GPoint(0, 30);
      icon_palm.image = "http://www.hvh.com/img/lonepalm.outlinr.png";

      var Hawaiimap_marker_1 = new GMarker(new GLatLng(22.2119444, -159.4122222) , icon_palm);
      GEvent.addListener(Hawaiimap_marker_1, "click", function () {  Hawaiimap_marker_1.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000000sarbAAA"><span style="font-size: 12px">Plumeria Moon</span></a><br /><span style="font-size: 12px">Kilauea, Kauai</span><br /><span style="font-size: 12px">Signature Home</span></div>'); });
      Hawaiimap.addOverlay(Hawaiimap_marker_1);
      var Hawaiimap_marker_2 = new GMarker(new GLatLng(22.2119444, -159.4122222) , icon_palm);
      GEvent.addListener(Hawaiimap_marker_2, "click", function () {  Hawaiimap_marker_2.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000000sarXAAQ"><span style="font-size: 12px">Hideaway Bay</span></a><br /><span style="font-size: 12px">Kilauea, Kauai</span><br /><span style="font-size: 12px">Signature Home</span></div>'); });
      Hawaiimap.addOverlay(Hawaiimap_marker_2);
    }

    //]]>
    </script>