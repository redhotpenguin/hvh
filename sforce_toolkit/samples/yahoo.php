<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" >
<head>
  <meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
  <script type="text/javascript" src="http://api.maps.yahoo.com/v2.0/fl/javascript/apiloader.js"></script>
    <script type="text/javascript" src="http://api.maps.yahoo.com/ajaxymap?v=2.0&appid=salesforce.com"></script>
    <style type="text/css">
      #mapContainer {
          height: 768px;
          width: 1024px;
      }
    </style>
</head>
<body>
<div id="mapContainer"></div>
<script type="text/javascript">
  var map = new Map("mapContainer", "YahooDemo", "2000 S. Congress Ave, Austin, TX");
  map.addTool( new PanTool(), true );
  navWidget = new NavigatorWidget();
  map.addWidget(navWidget);
<?php
// Singapore fails with a warning.  Ignore by setting the appropriate error level at runtime.
error_reporting(E_ERROR);
require_once ('../soapclient/SforcePartnerClient.php');
require_once ('../soapclient/SforceHeaderOptions.php');
require_once ('accountsaction.php');

$mySforceConnection = new SforcePartnerClient();
$mySoapClient = $mySforceConnection->createConnection("partner.wsdl.xml");
$mylogin = $mySforceConnection->login("username@sample.com", "changeme");

$recs = getAccounts($mySforceConnection);
$counter = 0;
foreach ($recs as $r) {
  $r = new SObject($r);
  $counter++;
  $data = $r->fields->BillingStreet;
  // Replace \n to br to be javascript-friendly.
  $billingAddress = str_replace("\n", "<br />", $data);
?>
  try {
    mark
      = new CustomPOIMarker(
    <?php echo $counter; ?>,
    <?php echo '\''.$r->fields->Name.'\''; ?>,
    '<?php echo $billingAddress; ?>',
    '0xFF0000',
    '0xFFFFFF');
    map.addMarkerByAddress(mark, <?php echo '\''.$billingAddress.','.$r->fields->BillingCity.','.$r->fields->BillingState.'\''; ?>);
  } catch (e) {
    alert(e);
  }
<?php
}
?>
</script>
</body>
</html>