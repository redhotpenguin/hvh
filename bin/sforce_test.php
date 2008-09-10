<?php
require_once ('soapclient/SforcePartnerClient.php');

$mySforceConnection = new SforcePartnerClient();

echo "opening connection\n";
$mySoapClient = $mySforceConnection->createConnection("partner.wsdl.xml");

echo "logging in\n";
$mylogin = $mySforceConnection->login("fred@redhotpenguin.com", "yomaingJN9fVMtleBighIslxY3EZxuE");

echo "logged in ok, running query\n";

$query = "SELECT Id, FirstName, LastName from Contact";
$queryResult = $mySforceConnection->query($query);

echo "query finished\n";
$records = $queryResult->records;

echo "records retrieved\n";
foreach ($records as $record) {
      $sObject = new SObject($record);
      echo "\n";
      echo "Id = ".$sObject->Id;
      echo "\n";
      echo "First Name = ".$sObject->fields->FirstName;
      echo "\n";
      echo "Last Name = ".$sObject->fields->LastName;
      echo "\n";
}


?>
