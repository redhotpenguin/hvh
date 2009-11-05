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
      var Hawaiimap_marker_3 = new GMarker(new GLatLng(20.7580556, -155.9902778) , icon_palm);
      GEvent.addListener(Hawaiimap_marker_3, "click", function () {  Hawaiimap_marker_3.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000001OhF9AAK"><span style="font-size: 12px">Hana Maui Hotel</span></a><br /><span style="font-size: 12px">Hana, Maui</span><br /><span style="font-size: 12px">Signature Hotel</span></div>'); });
      Hawaiimap.addOverlay(Hawaiimap_marker_3);
      var Hawaiimap_marker_4 = new GMarker(new GLatLng(20.0230556, -155.6716667) , icon_palm);
      GEvent.addListener(Hawaiimap_marker_4, "click", function () {  Hawaiimap_marker_4.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a06500000021f6MAAQ"><span style="font-size: 12px">Sleeping Turtle Sanctuary</span></a><br /><span style="font-size: 12px">Kamuela, Big Island</span><br /><span style="font-size: 12px">Premier Home</span></div>'); });
      Hawaiimap.addOverlay(Hawaiimap_marker_4);
      var Hawaiimap_marker_5 = new GMarker(new GLatLng(22.2236111, -159.4852778) , icon_palm);
      GEvent.addListener(Hawaiimap_marker_5, "click", function () {  Hawaiimap_marker_5.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000002wSRPAA2"><span style="font-size: 12px">Rainbow Terrace</span></a><br /><span style="font-size: 12px">Princeville, Kauai</span><br /><span style="font-size: 12px">Signature Home</span></div>'); });
      Hawaiimap.addOverlay(Hawaiimap_marker_5);
      var Hawaiimap_marker_6 = new GMarker(new GLatLng(21.8763888, -159.4538889) , icon_palm);
      GEvent.addListener(Hawaiimap_marker_6, "click", function () {  Hawaiimap_marker_6.openInfoWindowHtml('<div style="width:180px;height:40px;"><a href="/xdev/listing.php?prop_id=a0650000002G0hGAAS"><span style="font-size: 12px">Bird of Paradise</span></a><br /><span style="font-size: 12px">Poipu, Kauai</span><br /><span style="font-size: 12px">Premier Home</span></div>'); });
      Hawaiimap.addOverlay(Hawaiimap_marker_6);
    }

    //]]>
    </script>