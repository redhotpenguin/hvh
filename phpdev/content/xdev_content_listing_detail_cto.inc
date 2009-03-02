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

$booked = $_GET['booked'];
$payment_errors = $_GET['payment_errors'];
include "elements/states_array.inc";
include "elements/country_array.inc";

$invalid = $_GET['invalid'];

$reds = explode('|',$invalid);

$get_prop_id = $_GET['prop_id'];
if ($invalid) {
$red_msg = 'You are missing some required information needed to submit this form. Missing or invalid fields that are required have been highlighted in red.';
}
if ($booked == 1) {
$booked_msg = 'The check-in and check-out dates that you have requested have already been booked.';
}

if (in_array('payment_errors', $reds)) { 
$payment_errors_msg = 'There was problem processing your credit card information.';
}

$cto = $_GET['cto'];
// foreach ($reds as $red) {

// echo "$red<br>";
// }
?>
	<p>Required fields are marked with an asterisk (*).</p>
<?php if ($reds) { echo "<p class=error>$red_msg</p>";}  ?>

<?php if ($booked_msg) { echo "<p class=error>$booked_msg</p>"; }?>
<?php if ($payment_errors_msg) { echo "<p class=error>$payment_errors_msg</p>"; }?>
			<table border="0" width="100%">
			<tr>
				<input type=hidden name=prop_id value="<?php echo "$get_prop_id"; ?>">
				<?php if (in_array('first_name', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
                <td class="<?php echo "$check_class"; ?>">*First Name:</td>
                <td class="entry_desc"><input type="text" name="first_name" class=full value="<?php echo "$first_name"; ?>"></td>
			</tr>
			<tr>
				<?php if (in_array('last_name', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
                <td class="<?php echo "$check_class"; ?>">*Last Name:</td>

                <td class="entry_desc"><input type="text" name="last_name"  class=full value="<?php echo "$last_name"; ?>"></td>
			</tr>
           

			<?php

				if ($bkt != 1) {
					include "../phpdev/content/mailing_address.inc";
				}
			?>
 
            <tr>
				<?php if (in_array('email', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
                <td class="<?php echo "$check_class"; ?>">*Email Address:</td>
                <td class="entry_desc"><input type="text" name="email"  class=full  value="<?php echo "$email"; ?>"></td>
			</tr>
            
            <tr><?php if (in_array('phone', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
                <td class="<?php echo "$check_class"; ?>"><?php if (($fhh == 1) || ($bkt == 1)) { echo "*"; }?>Phone:</td>

                <td class="entry_desc"><input type="text" name="phone"  class=full value="<?php echo "$phone"; ?>"></td>
			</tr>
            
            <tr><?php if (in_array('guests', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
                <td class="<?php echo "$check_class"; ?>"><?php if ($bkt == 1) { echo "*"; }?>Number of Guests:</td>
                <td class="entry_desc">

                <input type="text" name="guests" size="2" maxlength="2" value="<?php echo "$guests"; ?>"></td>
            </tr>
                    <tr>
				<?php if (in_array('checkin_date', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
				<?php if ($booked == 1) { $check_class='entry_red'; } ?>
                <td class="<?php echo "$check_class"; ?>">*Check-in Date:<span class="dateInput"></td>
        <td class="entry_desc"><input  id="checkin_date" name="checkin_date" maxlength="10" size="10" type="text" value="<?php echo "$checkin_date"; ?>"/> ( MM/DD/YYYY )</span><br></td>
        </tr>
           <tr>
				<?php if (in_array('checkout_date', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
				<?php if ($booked == 1) { $check_class='entry_red'; } ?> 
               <td class="<?php echo "$check_class"; ?>">*Check-out Date:<span class="dateInput"></td>
        <td class="entry_desc"><input  id="checkout_date" name="checkout_date" maxlength="10" size="10" type="text" value="<?php echo "$checkout_date"; ?>"/> ( MM/DD/YYYY )</span><br></td>

        </tr> 
           
<?php 
if ($bkt == 1)  { 
include "../phpdev/content/ccfm.inc"; 
} 
?>
			<tr>
                <td class="entry_desc" valign="top" colspan="2">
                    <br>Comments:<br>
                    <textarea name="comments" rows="7" class=cto><?php echo "$comments"; ?></textarea>
               <br><span class="footer">(250 characters max, please)</span></td>
			</tr>
            
    </table>
	<?php
	$pname = $listing_obj->fields->Name;
	?>
	<input type=hidden name=prop_name value="<?php echo "$pname"; ?>">
