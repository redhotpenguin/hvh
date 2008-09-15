    <script type="text/javascript" />
    //<![CDATA[

    if (GBrowserIsCompatible()) {
      var map = new GMap2(document.getElementById("map"));
      map.setCenter(new GLatLng(32.931021, -95.871294));
      map.setZoom(4);
      map.setMapType(G_NORMAL_MAP);
      map.addControl(new GLargeMapControl());
      map.addControl(new GMapTypeControl());
      var icon_jah = new GIcon();
      icon_jah.shadow = "http://hvh2.hvh.com/img/solopalm.png"
      icon_jah.shadowSize = new GSize(0, 0);
      icon_jah.iconAnchor = new GPoint(0, 0);
      icon_jah.infoWindowAnchor = new GPoint(0, 0);
      icon_jah.image = "http://hvh2.hvh.com/img/solopalm.png";

      var marker_1 = new GMarker(new GLatLng(43.756026, -110.946409) , icon_jah);
      GEvent.addListener(marker_1, "click", function () {  marker_1.openInfoWindowHtml('<div style="width:350px;height:200px;"><p>JAH!</p></div>'); });
      map.addOverlay(marker_1);
      var marker_2 = new GMarker(new GLatLng(22.205314, -159.411288) , icon_jah);
      GEvent.addListener(marker_2, "click", function () {  marker_2.openInfoWindowHtml('<div style="width:350px;height:200px;"><p>JAH!</p></div>'); });
      map.addOverlay(marker_2);
      var marker_3 = new GMarker(new GLatLng(22.210839, -159.400986) , icon_jah);
      GEvent.addListener(marker_3, "click", function () {  marker_3.openInfoWindowHtml('<div style="width:350px;height:200px;"><p>JAH!</p></div>'); });
      map.addOverlay(marker_3);
      var marker_4 = new GMarker(new GLatLng(39.345294, -120.173003) , icon_jah);
      GEvent.addListener(marker_4, "click", function () {  marker_4.openInfoWindowHtml('<div style="width:350px;height:200px;"><p>JAH!</p></div>'); });
      map.addOverlay(marker_4);
      var marker_5 = new GMarker(new GLatLng(37.938746, -107.813425) , icon_jah);
      GEvent.addListener(marker_5, "click", function () {  marker_5.openInfoWindowHtml('<div style="width:350px;height:200px;"><p>JAH!</p></div>'); });
      map.addOverlay(marker_5);
      var marker_6 = new GMarker(new GLatLng(20.753799, -155.987262) , icon_jah);
      GEvent.addListener(marker_6, "click", function () {  marker_6.openInfoWindowHtml('<div style="width:350px;height:200px;"><p>JAH!</p></div>'); });
      map.addOverlay(marker_6);
      var marker_7 = new GMarker(new GLatLng(36.269973, -121.807748) , icon_jah);
      GEvent.addListener(marker_7, "click", function () {  marker_7.openInfoWindowHtml('<div style="width:350px;height:200px;"><p>JAH!</p></div>'); });
      map.addOverlay(marker_7);
      var marker_8 = new GMarker(new GLatLng(60.547768, -145.758625) , icon_jah);
      GEvent.addListener(marker_8, "click", function () {  marker_8.openInfoWindowHtml('<div style="width:350px;height:200px;"><p>JAH!</p></div>'); });
      map.addOverlay(marker_8);
      var marker_9 = new GMarker(new GLatLng(35.681622, -105.938067) , icon_jah);
      GEvent.addListener(marker_9, "click", function () {  marker_9.openInfoWindowHtml('<div style="width:350px;height:200px;"><p>JAH!</p></div>'); });
      map.addOverlay(marker_9);
      var marker_10 = new GMarker(new GLatLng(32.230636, -80.732529) , icon_jah);
      GEvent.addListener(marker_10, "click", function () {  marker_10.openInfoWindowHtml('<div style="width:350px;height:200px;"><p>JAH!</p></div>'); });
      map.addOverlay(marker_10);
      var marker_11 = new GMarker(new GLatLng(18.3436, -64.9314) , icon_jah);
      GEvent.addListener(marker_11, "click", function () {  marker_11.openInfoWindowHtml('<div style="width:350px;height:200px;"><p>JAH!</p></div>'); });
      map.addOverlay(marker_11);
    }

    //]]>
    </script>