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
require_once ('../soapclient/SforcePartnerClient.php');
include ('header.inc');
$errors = null;
session_start();

function login($username, $password) {
  $wsdl = 'partner.wsdl.xml';
  $loginResult = null;
  try {
    $mySforceConnection = new SforcePartnerClient();
    $mySforceConnection->createConnection($wsdl);
    $loginResult = $mySforceConnection->login($username, $password);

    $_SESSION['location'] = $mySforceConnection->getLocation();
    $_SESSION['sessionId'] = $mySforceConnection->getSessionId();
    $_SESSION['wsdl'] = $wsdl;

  } catch (Exception $e) {
	echo $mySforceConnection->getLastRequest();
    echo $mySforceConnection->getLastRequestHeaders();
    global $errors;
    $errors = $e->faultstring;

  }
  return $loginResult;
}

/**
 * Checks to see if the user has submitted his
 * username and password through the login form,
 */
if (isset ($_POST['loginClick'])) {
  /* Check that all fields were typed in */
  if (!$_POST['user'] || !$_POST['pass']) {
    global $errors;
    $errors = ('Please fill in both username and password.');
  } else {
    /* Spruce up username, check length */
    $_POST['user'] = trim($_POST['user']);

    try {
      /* Checks that username and password are correct */
      $result = login($_POST['user'], $_POST['pass']);

      if (isset($result)) {
        session_write_close();
        header('Location: welcome.php');
        exit();
      }
    } catch (Exception $e) {
      print_r($e);
    }
  }
}

?>

<br><br>
<div style="font-family: verdana; font-size: 14px; font-weight: bold; color: rgb(102, 102, 102);">Login</div><br>
  <div style="color: rgb(102, 102, 102);">
    If you are already a member of the AppExchange developer community, please login.
  </div><br>

<?php
global $errors;
if (isset($errors)) {
  echo '<p><span style=\"color:#FF0000\">$errors</span></p>';
}
?>

<form action="<?php echo $_SERVER['SCRIPT_NAME']?>" method="post">
<table align="left" border="0" cellspacing="0" cellpadding="3">
  <tr><td><strong>User Name:</strong></td><td><input type="text" name="user" maxlength="30"></td></tr>
  <tr><td><strong>Password:</strong></td><td><input type="password" name="pass" maxlength="30"></td></tr>
  <tr>
    <td colspan="2" align="right">
      <input type="submit" name="loginClick" value="Login">
    </td>
  </tr>

</table>
</form>

<?php
  include ('footer.inc');
?>