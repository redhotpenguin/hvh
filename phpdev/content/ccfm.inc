<?php 
$card_type = $_GET['card_type'];
$card_number = $_GET['card_number'];
$cvc = $_GET['cvc'];
$exp_month = $_GET['exp_month'];
$exp_year = $_GET['exp_year'];
$billing_address = $_GET['billing_address'];
$billing_state = $_GET['billing_state'];
$billing_city = $_GET['billing_city'];
$billing_zip = $_GET['billing_zip'];
$billing_country = $_GET['billing_country'];





?>
<?php if (in_array('card_type', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
<tr><Td class=<?php echo "$check_class"; ?>>*Card Type</td>
	<td class=entry_desc>
	<table border=0 cellpadding=0 cellspacing=0 width="100%">
	<tr><Td><select class="left" name="card_type">
			<option value="cardtype">Select a card type</option>
			<option value="visa" <?php if ($card_type == 'visa') { echo ' SELECTED'; } ?>>Visa</option>
			<option value="mastercard" <?php if ($card_type == 'mastercard') { echo ' SELECTED'; } ?>>MasterCard</option>
			<option value="amex" <?php if ($card_type == 'amex') { echo ' SELECTED'; } ?>>American Express</option>
		</select></td>
		<td></td>
	</tr>
	</table>
		
	</td>
</tr>
<?php if (in_array('card_number', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
<tr><td class=<?php echo "$check_class"; ?> valign=top>*Card Number</td>
	<td class=entry_desc>

		<table border=0 cellpadding=0 cellspacing=0 width="100%">
		<Tr><td><input class=full maxlength="16" name="card_number" type="text" value="<?php echo "$card_number"; ?>"/></td>
<?php if (in_array('cvc', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
		<td class="<?php echo "$check_class"; ?>" width=1>&nbsp;&nbsp;*CVC&nbsp;</td><td width=1><input maxlength="4" type="text" name="cvc" value="<?php echo "$cvc"; ?>" size=4/></td></tr>
		<Tr><Td class=entry_desc colspan=3><i>Numbers Only, No Spaces</i></td></tr>
		</table>

	

	</td>
</tr>
<?php if (in_array('exp_month', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
<tr><td class=<?php echo "$check_class"; ?>>*Expiration</td>
	<Td class=entry_desc><select name="exp_month">
			<option value="">Select Month</option>
			<option value="01" <?php if ($exp_month == '01') { echo ' SELECTED';} ?>>01</option>
			<option value="02" <?php if ($exp_month == '02') { echo ' SELECTED';} ?>>02</option>
			<option value="03" <?php if ($exp_month == '03') { echo ' SELECTED';} ?>>03</option>

			<option value="04" <?php if ($exp_month == '04') { echo ' SELECTED';} ?>>04</option>
			<option value="05" <?php if ($exp_month == '05') { echo ' SELECTED';} ?>>05</option>
			<option value="06" <?php if ($exp_month == '06') { echo ' SELECTED';} ?>>06</option>
			<option value="07" <?php if ($exp_month == '07') { echo ' SELECTED';} ?>>07</option>
			<option value="08" <?php if ($exp_month == '08') { echo ' SELECTED';} ?>>08</option>
			<option value="09" <?php if ($exp_month == '09') { echo ' SELECTED';} ?>>09</option>

			<option value="10" <?php if ($exp_month == '10') { echo ' SELECTED';} ?>>10</option>
			<option value="11" <?php if ($exp_month == '11') { echo ' SELECTED';} ?>>11</option>
			<option value="12" <?php if ($exp_month == '12') { echo ' SELECTED';} ?>>12</option>
		</select>
		<select name="exp_year">
		<option value="">Select Year</option>
		<?php foreach (range(2009, 2040) as $number) {

			echo "<option value=$number";
				if ($number == $exp_year) {
					echo " SELECTED";
				}
			echo ">$number</option>";	

		} ?>
		</select>
	</td>
</tr>
<?php if (in_array('billing_address', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
<tr><Td class=<?php echo "$check_class"; ?>>*Billing Address</td>
	<td><input class=full type="text" value="<?php echo "$billing_address"; ?>" name="billing_address"></td>
</tr>
<?php if (in_array('billing_city', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
<tr><Td class=<?php echo "$check_class"; ?>>*Billing City</td>
	<Td class=entry_desc><input class=full type="text" value="<?php echo "$billing_city"; ?>" name="billing_city"></td>
</tr>
<?php if (in_array('billing_state', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
 <tr>
                <td class="<?php echo "$check_class"; ?>">*Billing State:</td><td class="entry_desc">
                    <select name="billing_state">
                    <option value="">Select One</option>

                    <?php
                    foreach ($states_array AS $state_val) {
                        echo "<option value=\"$state_val\"";
                        if ($state_val == $billing_state) {
                            echo " SELECTED";
                        }
                        echo ">$state_val</option>"; 
                        }
                    ?>


                    </select>

                </td>
            </tr>
<?php if (in_array('billing_zip', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
<Tr><td class=<?php echo "$check_class"; ?> size=1>*Billing Zip</td><td size=1><input type="text" name="billing_zip" size=7 maxlength=5 value="<?php echo "$billing_zip"; ?>"></td></tr>

<?php if (in_array('billing_country', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
            <tr>
                <td class="<?php echo "$check_class"; ?>">*Billing Country:</td><td class="entry_desc">

                        <select name="billing_country">
                        <option value="">Select a Country</option>

                        <?php
							if ($billing_country) { $billing_country = $billing_country; } else { $billing_country = 'US'; }
							$CC = getCountryCodeArray();
							reset($CC);
							while ($Country = current($CC)) // (single "=" sign is on purpose)
						    {
							    echo "<option value=\"" . key($CC) . "\"";
								if ($billing_country == key($CC)) { echo "SELECTED"; }
								echo ">" . $Country . "</option>";
							    next($CC);
						    }	


                        ?>


                        </select>
                </td>
            </tr>

	<input type=hidden name=bktcc_next value=1>
	<input type=hidden name=nightly_rate value="<?php echo "$nightly_rate"; ?>">
	<input type=hidden name=num_nights value="<?php echo "$num_nights"; ?>">
	<input type=hidden name=rental_subtotal value="<?php echo "$rental_subtotal"; ?>">
<input type=hidden name=local_taxes value="<?php echo "$local_tax"; ?>">
<input type=hidden name=rental_total value="<?php echo "$rental_total"; ?>">
<input type=hidden name=deposit value="<?php echo "$deposit"; ?>">
<input type=hidden name=first_payment value="<?php echo "$first_payment"; ?>">
<input type=hidden name=second_payment value="<?php echo "$second_payment"; ?>">
<input type=hidden name=cleaning_fee value="<?php echo "$cleaning_fee"; ?>">
