<?php
require_once ('soapclient/SforcePartnerClient.php');

$mySforceConnection = new SforcePartnerClient();
$mySoapClient = $mySforceConnection->createConnection("partner.wsdl.xml");
$mylogin = $mySforceConnection->login("fred@redhotpenguin.com", "yomaingJN9fVMtleBighIslxY3EZxuE");

$query = "SELECT Id, FirstName, LastName from Contact";
$queryResult = $mySforceConnection->query($query);
$records = $queryResult->records;
foreach ($records as $record) {
      $sObject = new SObject($record);
        echo "Id = ".$sObject->Id;
        echo "First Name = ".$sObject->fields->FirstName;
          echo "Last Name = ".$sObject->fields->LastName;
}


?>
