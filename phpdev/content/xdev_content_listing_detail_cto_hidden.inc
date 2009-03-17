<?php

$first_name = $_GET['first_name'];
$last_name = $_GET['last_name'];
$address = $_GET['address'];
$city = $_GET['city'];
$state = $_GET['state'];
$zip = $_GET['zip'];
$country = $_GET['country'];
$email = $_GET['email'];
$phone = $_GET['phone'];
$guests = $_GET['guests'];
$checkin_date = $_GET['checkin_date'];
$checkout_date = $_GET['checkout_date'];
$comments = $_GET['comments'];


?>
<input type=hidden name=last_name value="<?php echo "$last_name"; ?>">
<input type=hidden name=first_name value="<?php echo "$first_name"; ?>">
<input type=hidden name=email value="<?php echo "$email"; ?>">
<input type=hidden name=phone value="<?php echo "$phone"; ?>">
<input type=hidden name=guests value="<?php echo "$guests"; ?>">
<input type=hidden name=checkin_date value="<?php echo "$checkin_date"; ?>">
<input type=hidden name=checkout_date value="<?php echo "$checkout_date"; ?>">
<input type=hidden name=comments value="<?php echo "$comments"; ?>">
