<?php
/*
 * Copyright (c) 2007, salesforce.com, inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided
 * that the following conditions are met:
 *
 *    Redistributions of source code must retain the above copyright notice, this list of conditions and the
 *    following disclaimer.
 *
 *    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
 *    the following disclaimer in the documentation and/or other materials provided with the distribution.
 *
 *    Neither the name of salesforce.com, inc. nor the names of its contributors may be used to endorse or
 *    promote products derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
include ('header.inc');
require_once ('../soapclient/SforcePartnerClient.php');

session_start();

if (!isset($_SESSION['sessionId'])) {
  header('Location: login.php');
  exit;
}

$id = $_REQUEST['Id'];
$location = $_SESSION['location'];
$sessionId = $_SESSION['sessionId'];
$wsdl = $_SESSION['wsdl'];
$sObject = null;

try {
  $mySforceConnection = new SforcePartnerClient();
  $sforceSoapClient = $mySforceConnection->createConnection($wsdl);
  $mySforceConnection->setEndpoint($location);
  $mySforceConnection->setSessionHeader($sessionId);


  if (isset($_POST['doUpdate'])) {
    $sfid = $_POST['sfid'];
    $ct = $_POST['City'];
    $st = $_POST['State'];
    $phone = $_POST['Phone'];
    $fax = $_POST['Fax'];
    $name = $_POST['AccountName'];
    $fieldsToUpdate
      = array('Id'=>$sfid,'Name'=>$name,'BillingCity'=>$ct,'BillingState'=>$st,'Phone'=>$phone,'Fax'=>$fax);
    $sObject = new SObject();
    $sObject->fields = $fieldsToUpdate;
    $sObject->type = 'Account';
    $acct = $mySforceConnection->update(array ($sObject));

    header('Location: welcome.php');
  } else {
    $fields = 'Name,BillingCity,BillingState,Phone,Fax';
    $ids = array (
      $id
    );
    $acct = $mySforceConnection->retrieve($fields, 'Account', $ids);
    $sObject = new SObject($acct);
  }
} catch (exception $e) {
  print ('There was a problem with your login: ' . $e->faultstring . '<br>\r\n');
  exit ();
}

$message = '<p>You can update the location of ' . $sObject->fields->Name . ' using the fields below. Click "Update" to post your changes.</p>';
$message .= '<form action='. $_SERVER['SCRIPT_NAME'] .' method="post">';
$message .= '<input type="hidden" name="sfid" value="'.$sObject->Id.'" />';
$message .= '<table border="0" cellpadding="8">';
$message .= '<tr><td>Account Name</td><td><input type="text" name="AccountName" size="20" value="' . $sObject->fields->Name . '"></td></tr>';
$message .= '<tr><td>City</td><td><input type="text" name="City" size="20" value="' . $sObject->fields->BillingCity . '"></td></tr>';
$message .= '<tr><td>State</td><td><input type="text" name="State" size="2" value="' . $sObject->fields->BillingState . '"></td></tr>';
$message .= '<tr><td>Phone</td><td><input type="text" name="Phone" size="20" value="' . $sObject->fields->Phone . '"></td></tr>';
$message .= '<tr><td>Fax</td><td><input type="text" name="Fax" size="20" value="' . $sObject->fields->Fax . '"></td></tr>';
$message .= '</table>';
$message .= '<input type="submit" name="doUpdate" value="Update">&nbsp;';
$message .= '</form>';

print ($message);
include ('footer.inc');
?>
