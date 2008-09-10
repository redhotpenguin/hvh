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
require_once ('../soapclient/SforceHeaderOptions.php');
require_once ('AccountsAction.php');

session_start();

if (!isset($_SESSION['sessionId'])) {
  header('Location: login.php');
  exit;
}

$mySforceConnection;
$myUserInfo;

function displayWelcome() {
  $location = $_SESSION['location'];
  $sessionId = $_SESSION['sessionId'];
  $wsdl = $_SESSION['wsdl'];

  global $myUserInfo;
  global $mySforceConnection;

  try {
    $mySforceConnection = new SforcePartnerClient();
    $sforceSoapClient = $mySforceConnection->createConnection($wsdl);
    $mySforceConnection->setSessionHeader($sessionId);
    $mySforceConnection->setEndpoint($location);
    $servertime = $mySforceConnection->getServerTimestamp();
    $myUserInfo = $mySforceConnection->getUserInfo();
  } catch (exception $e) {
    print ('There was a problem with your login: ' . $e->faultstring . '<br>');
    print_r($mySforceConnection->getLastRequest());
    print_r('<br>');
    print_r($mySforceConnection->getLastRequestHeaders());
    print_r('<br>');
    print_r($mySforceConnection->getLastResponse());
    exit ();
  }

  echo 'The server time (GMT) is ' . $servertime->timestamp;
  echo '<br>';
  echo '<br>';
  echo 'Welcome, ' . $myUserInfo->userFullName . '.';
}

/**
  * Print out a list of the existing accounts. Note that we have limited the batch
  * size to 25 so your list will be limited to 25 Accounts. You could increase the batch size
  * or implement a paging mechanism to handle additional accounts *
 */
function displayTable() {
  global $mySforceConnection;
  $accts = getAccounts($mySforceConnection);

  if ($accts) {
    print ('<p>There are currently ' . count($accts) . ' accounts:</p>');

    print ('<hr><table border="0" padding="8">');
    print ('<td></td><td></td><td>Name</td><td></td><td>City</td><td>State</td><td>Phone</td><td>Fax</td>');
    try {
      foreach ($accts as $r) {
        $r = new SObject($r);
        printf('<tr>' .
        '<td><a href="edit.php?action=Edit&Id=%s">Edit</a></td>' .
        '<td><a href="delete.php?action=Delete&Id=%s">Delete</a></td>' .
        '<td>%s</td><td> </td><td>%s, %s</td><td>%s</td><td>%s</td>' .
        '</tr>'. "\r\n", $r->Id, $r->Id, $r->fields->Name, $r->fields->BillingCity, $r->fields->BillingState, $r->fields->Phone, $r->fields->Fax);
      }
    } catch (Exception $e) {
      // Ignore Notices???
    }

    print ('</table>');
    print ('<br>');
  }
}

displayWelcome();
displayTable();
include ('footer.inc');
?>
