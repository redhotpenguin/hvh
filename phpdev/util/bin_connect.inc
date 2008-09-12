<?php
require_once ('sforce_toolkit/soapclient/SforcePartnerClient.php');

$mySforceConnection = new SforcePartnerClient();

error_log("opening connection\n");
$mySoapClient = $mySforceConnection->createConnection("partner.wsdl.xml");

error_log("logging in\n");
$mylogin = $mySforceConnection->login("fred@redhotpenguin.com", "yomaingJN9fVMtleBighIslxY3EZxuE");




?>
