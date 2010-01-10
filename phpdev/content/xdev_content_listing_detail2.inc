<?php
$param = $_GET['param'];
$value = $_GET['value'];
$search_cat = $_GET['search_cat'];

if ($param) {
    $param = $param;
    $value = $value;
} else {
    if ($_POST['region']) {
        $param = 'region';
        $value = $_POST['region'];
        $show_region = $value;
    }
    if ($_POST['city']) {
        $param = 'city';
        $value = $_POST['city'];
        $show_city = $value;
    }
}

$prop_id = $_GET['prop_id'];

$memcache = new Memcache;
$memcache->connect('localhost', 11211) or die ("Could not connect");

require_once ('../soapclient/SforcePartnerClient.php');
#$mySforceConnection = new SforcePartnerClient();

$key = "id|$prop_id";
$get_result = $memcache->get($key);
$listing_obj = new SObject($get_result);
$cto = $_GET['cto'];
$fhh = $_GET['fhh'];
$bkt = $_GET['bkt'];
$bktcc = $_GET['bktcc'];
$customer = $listing_obj->fields->Solutions_Customer__c;
$get_booking_id = $_GET['booking_id'];
$get_prop_id = $_GET['prop_id'];

include "../phpdev/content/features_data.inc";
// $props = mysql_query("select * from property where id='$prop_id' limit 1");


//    $images = mysql_query("select * from property_img where property_id='$home[id]'");        
    echo "<table border=0 cellpadding=0 align=center cellspacing=0 width=\"100%\">";

//        echo "<tr class=class_detail_bar_new>";
//        echo "<td class=detail_bar_new>".$listing_obj->fields->Category__c."";
//        if ($show_region) {
//            echo " in $value";
//        }
//        if ($show_city) {
//            echo " in $value";
//        }
//        echo "</td>";
//        echo "<td class=detail_bar_new><img src=\"img/clear.gif\" width=1 height=1></td>";
//        if ($param && $value) {
//            echo "<td class=detail_return_new align=right><a href=\"javascript:history.back()\" class=cat_header>Return to Previous  Page</a></td>";
//        } else {
//            echo "<td class=detail_return_new align=right><a href=\"index.php\" class=cat_header>Return to Home Page</a></td>";
//        }
//        echo "</tr>";
  
 
    echo "<tr><td colspan=3>";
	echo "<img src=\"img/clear.gif\" width=1 height=15><br>";
	echo "<table border=0 cellpadding=0 cellspacing=0 width=\"100%\">";
	echo "<tr><td width=8><img src=\"img/clear.gif\" width=18 height=1></td>";
	echo "<td>";

    echo "<span class=detail_header>".$listing_obj->fields->Name."</span> - ";
    echo "<span class=entry_loc>".$listing_obj->fields->City__c.", ".$listing_obj->fields->Location__c."</span>";
	echo "</td>";

	echo "<td>";
	echo "<table border=0 cellpadding=0 cellspacing=0 width=\"100%\">";

	echo "<tr><Td class=entry_desc align=center><a href=\"$PHP_SELF?prop_id=$get_prop_id&cto=1\"><img src=\"img/lil_guy_white.gif\" border=0></a><br>Contact the Owner</td>";
	echo "<td class=entry_desc align=center><a href=\"$PHP_SELF?prop_id=$get_prop_id&fhh=1\"><img src=\"img/red_house_white.gif\" border=0 hspace=3></a><br>Place a 48 hour Hold</td>";
    if ($customer == 'true') {
    echo "<td class=entry_desc align=center><a href=\"$PHP_SELF?prop_id=$get_prop_id&bkt=1\"><img src=\"img/scroll_white.gif\" border=0></a><br>Book This Property!</td>";
    } else {
    echo "<a href=\"listing.php?prop_id=$get_prop_id&cto=1&nobkt=1\"><img src=\"img/scroll_white.gif\" border=0></a>";
    }
	echo "</tr></table>";


	echo "</td>";

	echo "</tr>";

	echo "</td></tr>";
	echo "<tr><td colspan=3 valign=top>";
    echo "<table border=0 cellpadding=0 cellspacing=0 width=\"100%\">";
    echo "<tr>";
      


	// put amen here //

echo "<td valign=top width=216 align=right class=amen_wrapper>";

	echo "<table border=0 cellpadding=0 cellspacing=0 class=left_patch width=\"100%\">";
	echo "<tr><td class=left_patch>";
    echo "<b><u>Bedrooms, Baths & Sleeping</u></b>";
	echo "</td></tr>";
	echo "<tr><td class=left_patch>";
	echo "<li>Sleeps: " . $listing_obj->fields->Sleeps__c . "<Br>";
	echo "<li>Bedrooms: " . $listing_obj->fields->Bedrooms__c . "<Br>";
	echo "<li>Bathrooms: " . $listing_obj->fields->Bathrooms__c . "<Br>";
	echo "<li>Showers: " . $listing_obj->fields->Showers__c . "<Br>";
	echo "<li>Bathtubs: " . $listing_obj->fields->Bathtubs__c . "<Br>";
    foreach ($bed_array as $bed) {
      if ($listing_obj->fields->$bed == 'true') {
            echo "<li>" . $bed_hash[$bed]."<br>";
            }
    }
	echo "</td></tr>";
	echo "</table>";
	echo "<img src=\"img/clear.gif\" width=1 height=7><br>";
	echo "<table border=0 cellpadding=0 cellspacing=0 class=left_patch width=\"100%\">";
	echo "<tr><td class=left_patch>";
    echo "<b><u>Special Amenities</u></b>";
	echo "</td></tr>";
	echo "<tr><td class=left_patch>";
	foreach ($amenities_array as $amenity) {
   	   	if ($listing_obj->fields->$amenity == 'true') {
        	echo "<li>" . $amenities_hash[$amenity]."<br>";
    		}
   	}
	echo "</td></tr>";
	echo "</table>";


	echo "<img src=\"img/clear.gif\" width=1 height=7><br>";
	echo "<table border=0 cellpadding=0 cellspacing=0 class=left_patch width=\"100%\">";
	echo "<tr><td class=left_patch>";
    echo "<b><u>Features</u></b>";
	echo "</td></tr>";
	echo "<tr><td class=left_patch>";
	foreach ($features_array as $feature) {
   	   	if ($listing_obj->fields->$feature == 'true') {
        	echo "<li>" . $features_hash[$feature]."<br>";
    		}
   	}
	echo "</td></tr></table>";

	echo "<img src=\"img/clear.gif\" width=1 height=7><br>";
	echo "<table border=0 cellpadding=0 cellspacing=0 class=left_patch width=\"100%\">";
	echo "<tr><td class=left_patch>";
    echo "<b><u>Outdoors</u></b>";
	echo "</td></tr>";
	echo "<tr><td class=left_patch>";
	foreach ($outdoors_array as $outdoor) {
   	   	if ($listing_obj->fields->$outdoor == 'true') {
        	echo "<li>" . $outdoors_hash[$outdoor]."<br>";
    		}
   	}
	echo "</td></tr></table>";

	echo "<img src=\"img/clear.gif\" width=1 height=7><br>";
	echo "<table border=0 cellpadding=0 cellspacing=0 class=left_patch width=\"100%\">";
	echo "<tr><td class=left_patch>";
    echo "<b><u>Communications & Multimedia</u></b>";
	echo "</td></tr>";
	echo "<tr><td class=left_patch>";
    foreach ($comm_array as $comm) {
        if ($listing_obj->fields->$comm == 'true') {
            echo "<li>" . $comm_hash[$comm]."<br>";
        }
    }
	echo "</td></tr></table>";

	echo "<img src=\"img/clear.gif\" width=1 height=7><br>";
	echo "<table border=0 cellpadding=0 cellspacing=0 class=left_patch width=\"100%\">";
	echo "<tr><td class=left_patch>";
    echo "<b><u>Kitchen</u></b>";
	echo "</td></tr>";
	echo "<tr><td class=left_patch>";
    foreach ($kitchen_array as $kitchen) {
        if ($listing_obj->fields->$kitchen == 'true') {
            echo "<li>" . $kitchen_hash[$kitchen]."<br>";
        }
    }
	echo "</td></tr></table>";



	echo "</td>";
    echo "<td bgcolor=\"#ffffff\" valign=top>";
    echo "<table border=0 cellpadding=10 cellspacing=0 width=\"100%\">";
    echo "<tr>";
    echo "<td class=entry valign=top bgcolor=\"#ffffff\">";

	// prop name //	


	$get_prop_id = $_GET['prop_id'];
	if ($cto == 1) {
		$nobkt = $_GET['nobkt'];

		if ($nobkt == 1) {

echo "Thank you for your interest in " . $listing_obj->fields->Name  .".  HVH is currently working with this location to complete the automated booking    s process.  For now, please populate the \"Contact the Owner\" form below.  In the comments section, please note your request to place a 48 hour hold on the proper    ty for the selected dates.  Someone will respond to your request as soon as possible.  Thanks for using HVH!<br><br>";

		}
		echo "<script>setTimeout(\"document.cto.fname.focus()\",10);</script>";
        echo "<table border=0 cellpadding=1 cellspacing=0 width=\"100%\">";
		echo "<form name='cto' action='https://www.hvh.com/cgi-bin/bookit.cgi' method=post>";
		echo "<tr><Td colspan=3>";
		echo "<input type='hidden' name='rm' value='contact'>";
		echo "<tr><Td colspan=3><hr noshade size=1 color=\"#e2e2e1\"></td></tr>";
		echo "<tr><td copy colspan=3 class=entry_desc>To <b><i>contact the owner</i></b> at ";
		echo $listing_obj->fields->Name;
		echo ", please fill out the form below and click the 'Contact Owner' button at the bottom of the page.</td></tr>";

		echo "<tr><Td colspan=3><hr noshade size=1 color=\"#e2e2e1\"></td></tr>";

		echo "<tr><td colspan=3>";
		include "../phpdev/content/xdev_content_listing_detail_cto.inc";
		echo "</td></tr>";
		echo "<tr><td colspan=3 class=reg_copy><input type=image src=\"img/cto_off.gif\" vspace=4></td></tr>";
		echo "</form>";
		echo "</table><br>";
	}
	if ($cto == 'success') {
		echo "<div class=success>Your message and contact information has been sent to the owner or property manager at ".$listing_obj->fields->Name.".</div><br>";
	}
	
	if ($fhh == 1) {
		if ($customer == 'true') {
		echo "<script>setTimeout(\"document.fhh.fname.focus()\",10);</script>";
		echo "<table border=0 cellpadding=1 cellspacing=0 width=\"100%\">";
		echo "<form name='fhh' action='https://www.hvh.com/cgi-bin/bookit.cgi' method=post>";
		echo "<input type='hidden' name='rm' value='hold'>";
		echo "<tr><Td colspan=3><hr noshade size=1 color=\"#e2e2e1\"></td></tr>";
		echo "<tr><td copy colspan=3 class=entry_desc>To place a <b><i>48-hour hold</i></b> at ";
		echo $listing_obj->fields->Name;
		echo ", please fill out the form below and click the '48-Hour Hold' button at the bottom of the page.</td></tr>";
		echo "<tr><Td colspan=3><hr noshade size=1 color=\"#e2e2e1\"></td></tr>";
		echo "<tr><td colspan=3>";
		include "../phpdev/content/xdev_content_listing_detail_cto.inc";
		echo "</td></tr>";
		echo "<tr><td colspan=3 class=reg_copy><input type=image src=\"img/hold_off.gif\" vspace=4></td></tr>";
		echo "</form>";
		echo "</table><br>";
		} else {

			echo "Thank you for your interest in " . $listing_obj->fields->Name  .".  HVH is currently working with this location to complete the automated bookings process.  For now, please populate the \"Contact the Owner\" form below.  In the comments section, please note your request to place a 48 hour hold on the property for the selected dates.  Someone will respond to your request as soon as possible.  Thanks for using HVH!<br><br>";
			
		echo "<table border=0 cellpadding=1 cellspacing=0 width=\"100%\">";
		echo "<form name='cto' action='https://www.hvh.com/cgi-bin/bookit.cgi' method=post>";
		echo "<input type='hidden' name='rm' value='contact'>";
		echo "<tr><Td colspan=3><hr noshade size=1 color=\"#e2e2e1\"></td></tr>";
		echo "<tr><td copy colspan=3 class=entry_desc>To <b><i>contact the owner</i></b> at ";
		echo $listing_obj->fields->Name;
		echo ", please fill out the form below and click the 'Contact Owner' button at the bottom of the page.</td></tr>";

		echo "<tr><Td colspan=3><hr noshade size=1 color=\"#e2e2e1\"></td></tr>";

		echo "<tr><td colspan=3>";
		include "../phpdev/content/xdev_content_listing_detail_cto.inc";
		echo "</td></tr>";
		echo "<tr><td colspan=3 class=reg_copy><input type=image src=\"img/cto_off.gif\" vspace=4></td></tr>";
		echo "</form>";
		echo "</table><br>";
		}
	}
	if ($fhh == 'success') {
		echo "<div class=success>Congratulations! Your accommodations at ".$listing_obj->fields->Name." have been put on hold for 48-hours. To finalize your booking, please return to HVH.com and submit your credit card information, or please contact us directly within the 48 hour time period.  Thanks for choosing HVH!</div><br>";
	}	
	if ($bkt == 1) {
		if ($customer == 'true') {	
		echo "<table border=0 cellpadding=1 cellspacing=0 width=\"100%\">";
		echo "<form name=bkt action='https://www.hvh.com/cgi-bin/bookit.cgi' method=post>";
		echo "<input type='hidden' name='rm' value='bookit'>";
		echo "<input type=hidden name=booking_id value=\"$get_booking_id\">";
	
		echo "<tr><Td colspan=3><hr noshade size=1 color=\"#e2e2e1\"></td></tr>";
		echo "<tr><td copy colspan=3 class=entry_desc>";
		if ($bktcc == 1) {

			$nightly_rate = $_GET['nightly_rate'];
			$num_nights = $_GET['num_nights'];
			$rental_subtotal = $_GET['rental_subtotal'];
			$local_tax = $_GET['local_taxes'];
			$rental_total = $_GET['total_rental_amount'];
			$deposit = $_GET['deposit'];
			$cleaning_fee = $_GET['cleaning_fee'];
			$first_payment = $_GET['first_payment'];
			$second_payment = $_GET['second_payment'];
			$second_charge_date = $_GET['second_charge_date'];

			$num_nights = number_format($num_nights, 0, '.', '');
			$nightly_rate = number_format($nightly_rate, 2, '.', '');
			$rental_subtotal = number_format($rental_subtotal, 2, '.', '');
			$rental_total = number_format($rental_total, 2, '.', '');
			$deposit = number_format($deposit, 2, '.', '');
            $second_payment = number_format($second_payment, 2, '.', '');
            $first_payment = number_format($first_payment, 2, '.', '');
			$cleaning_fee = number_format($cleaning_fee, 2, '.', '');
			$tax_fix = ($local_tax / 100);
			$total_tax = ($rental_subtotal * $tax_fix);
			$total_tax = number_format($total_tax, 2, '.', '');	
			echo "To complete your booking at " .$listing_obj->fields->Name.", please provide your credit card and billing information below. Your card will be charged immediately for half the total rental amount plus the full deposit. For your stay, those fees are as follows:";
			echo "<br><Br>";
			echo "<input type=hidden name=first_payment value=\"$first_payment\">";
			echo "<table border=0 cellpadding=0 cellspacing=2 width=\"86%\" align=center>";
			echo "<tr><Td  bgcolor=\"#e2e2e1\" class=entry_desc>Fee Summary</td><td bgcolor=\"#999999\" class=entry_desc align=center><font color=white>Amount</font></td>";	
			echo "<tr><td class=entry_desc>Nightly Rate:</td><td class=entry_desc align=right><b>\$$nightly_rate</b></td></tr>";
			echo "<tr><td colspan=3 height=1 bgcolor=\"#cccccc\"><img src=\"img/clear.gif\" width=1 height=1></td></tr>";
			echo "<tr><td class=entry_desc>Number of Nights:</td><td class=entry_desc align=right><b>$num_nights</b></td></tr>";
			echo "<tr><td colspan=3 height=1 bgcolor=\"#cccccc\"><img src=\"img/clear.gif\" width=1 height=1></td></tr>";
			echo "<tr><td class=entry_desc>Rental Subtotal:</td><td class=entry_desc align=right><b>\$$rental_subtotal</b></td></tr>";
			echo "<tr><td colspan=3 height=1 bgcolor=\"#cccccc\"><img src=\"img/clear.gif\" width=1 height=1></td></tr>";
			echo "<tr><td class=entry_desc>Accommodations Tax (<b>$local_tax%</b>):</td><td class=entry_desc align=right><b>$$total_tax</b></td></tr>";
			echo "<tr><td colspan=3 height=1 bgcolor=\"#cccccc\"><img src=\"img/clear.gif\" width=1 height=1></td></tr>";
			echo "<tr><td class=entry_desc>Total Rental Amount:</td><td class=entry_desc align=right><b><font color=red>$$rental_total</font></b></td></tr>";
			echo "<tr><td colspan=3 height=1 bgcolor=\"#cccccc\"><img src=\"img/clear.gif\" width=1 height=1></td></tr>";
			echo "<tr><td class=entry_desc>Deposit Amount:</td><td class=entry_desc align=right><B>\$$deposit</b></td></tr>";
			echo "<tr><td colspan=3 height=1 bgcolor=\"#cccccc\"><img src=\"img/clear.gif\" width=1 height=1></td></tr>";
			echo "<tr><td class=entry_desc>Cleaning Fee:</td><td class=entry_desc align=right><B>\$$cleaning_fee</b></td></tr>";
			echo "<tr><td colspan=3 height=1 bgcolor=\"#cccccc\"><img src=\"img/cler.gif\" width=1 height=1></td></tr>";
			echo "<tr><td class=entry_desc>First Payment Charged Immediately:</td><td class=entry_desc align=right><b>$$first_payment</b>";
			echo "<tr><td colspan=3 height=1 bgcolor=\"#cccccc\"><img src=\"img/clear.gif\" width=1 height=1></td></tr>";
			echo "<tr><td class=entry_desc>Second Payment Charged on $second_charge_date:</td><td class=entry_desc align=right><b>$$second_payment</b></td></tr>";
			echo "</table>";

		} else {
			echo "To <b><i>book your vacation</i></b> at  ";
			echo $listing_obj->fields->Name;
			echo ", please fill out the form below and click the 'Book it!' button at the bottom of the page.";
		}
		echo "</td></tr>";
		echo "<tr><Td colspan=3><hr noshade size=1 color=\"#e2e2e1\"></td></tr>";
		if ($bktcc == 1) {
			echo "<tr><td colspan=3>";
			include "../xdev/elements/paypal_logo_code.inc";
			echo "</td></tr>";
		}
		echo "<tr><td colspan=3>";
		include "../phpdev/content/xdev_content_listing_detail_cto.inc";

		echo "</td></tr>";
		echo "<tr><td colspan=3 class=reg_copy><input type=image src=\"img/bkt_off.gif\" vspace=4></td></tr>";
		echo "</form>";
		echo "</table><br>";
		} else {
			echo "Thank you for your interest in ".$listing_obj->fields->Name.".  HVH is currently working with this location to complete the automated bookings process.  For now, please populate the \"Contact the Owner\" form below.  In the comments section, please note your request to book the property for the selected dates.  Someone will contact you as soon as possible to complete the booking.  Thanks for using HVH and enjoy your vacation!<br><br>";
			
		echo "<table border=0 cellpadding=1 cellspacing=0 width=\"100%\">";
		echo "<form name='cto' action='https://www.hvh.com/cgi-bin/bookit.cgi' method=post>";
		echo "<input type='hidden' name='rm' value='contact'>";
		echo "<tr><Td colspan=3><hr noshade size=1 color=\"#e2e2e1\"></td></tr>";
		echo "<tr><td copy colspan=3 class=entry_desc>To <b><i>contact the owner</i></b> at ";
		echo $listing_obj->fields->Name;
		echo ", please fill out the form below and click the 'Contact Owner' button at the bottom of the page.</td></tr>";

		echo "<tr><Td colspan=3><hr noshade size=1 color=\"#e2e2e1\"></td></tr>";

		echo "<tr><td colspan=3>";
		include "../phpdev/content/xdev_content_listing_detail_cto.inc";
		echo "</td></tr>";
		echo "<tr><td colspan=3 class=reg_copy><input type=image src=\"img/cto_off.gif\" vspace=4 onclick=\"this.disabled='disabled'\"></td></tr>";
		echo "</form>";
		echo "</table><br>";
		}
	}
	if ($bkt == 'success') {
		echo "<div class=success>An email confirmation will be sent to the email address provided.  If you have any questions or need anything whatsoever, please don't hesitate to call HVH at 888-858-6562. <br><Br>Enjoy your vacation!!</div><br>";
	}
	
if (($bkt == 1) || ($fhh == 1) || ($cto == 1)) { $hide_content = 1; }

if ($hide_content != 1) {
	$desc_yo = nl2br($listing_obj->fields->Description__c);
	$teaser_yo = nl2br($listing_obj->fields->Teaser__c);
	echo "<table border=0 cellpadding=0 cellspacing=0 width=\"100%\">";
    echo "<tr><td valign=top>";

	echo "<table border=0 cellpadding=0 cellspacing=0 width=\"100%\" class=content_patch>";
	echo "<tr><Td width=\"100%\" class=content_patch>";
	echo "<span class=entry_desc>".$teaser_yo."<br><Br>".$desc_yo."</span>";
	echo "</td></tr></table>";		

	echo "</td></tr>";
	echo "</table>";


}

	// CALENDAR GOES HERE //
	echo "<table border=0 cellpadding=0 cellspacing=0 width=\"100%\">";
    echo "<tr><td>";
?>
                <?php include "elements/cal.inc"; ?>
<?
	echo "</td></tr>";
	echo "</table>";

?>

<?

    echo "</td>";

	echo "</tr>";


	// used to be amenities //


    echo "</table>";



echo "</td>";

	echo "<td width=8><img src=\"img/clear.gif\" width=8 height=1></td>";
    echo "<td valign=top class=caption width=216>";
	echo "<img src=\"img/clear.gif\" width=1 height=9><br>";
	echo "<table class=patch width=\"100%\">";
	echo "<tr><Td class=patch colspan=2 align=left><B><u>Property Rental Information</u></b></td></tr>";
	echo "<tr><td colspan=2>";

	echo "<table border=0 cellpadding=1 cellspacing=0 width=\"100%\">";
	echo "<tr><Td class=patch><li>Nightly Rate Price:</td><Td class=patch align=right>$".sprintf('%2.2f',$listing_obj->fields->Nightly_Rate_List_Price__c)."</td></tr>";
	echo "<tr><Td class=patch><li>Local Tax Rate:</td><Td class=patch align=right>".$listing_obj->fields->Local_Tax_Rate__c."%</td></tr>";
	echo "<tr><Td class=patch><li>Security Deposit:</td><Td class=patch align=right>$".sprintf('%2.2f',$listing_obj->fields->Security_Deposit__c)."</td></tr>";
	echo "<tr><Td class=patch><li>Housekeeping Fee:</td><Td class=patch align=right>$".sprintf('%2.2f', $listing_obj->fields->Housekeeping_Fee__c)."</td></tr>";
	echo "<tr><Td class=patch><li>Check-in Time:</td><Td class=patch align=right>".$listing_obj->fields->Check_in_Time__c."</td></tr>";
	echo "<tr><Td class=patch><li>Check-out Time:</td><Td class=patch align=right>".$listing_obj->fields->Check_out_Time__c."</td></tr>";
	echo "<tr><Td class=patch><li>Website:</td><td class=patch align=right><a href=\"http://".$listing_obj->fields->Website__c."\" target=_blank>Click Here</a></td></tr>";

	echo "</table>";
	echo "</td></tr></table>";
?>

<?
	echo "<img src=\"img/clear.gif\" width=1 height=6><br>";

        $img_array = array("Image_URL_2__c","Image_URL_3__c","Image_URL_4__c","Image_URL_5__c","Image_URL_6__c","Image_URL_7__c","Image_URL_8__c");
        foreach ($img_array as $img) {
				$img_loc = $listing_obj->fields->$img;
	
                if (strlen($listing_obj->fields->$img) > 3) {
					if (@fclose(@fopen("$img_loc", "r"))) {
                        echo "<img width=\"216\" height=\"152\" src=\"".$listing_obj->fields->$img."\"><br><img src=\"img/clear.gif\" width=1 height=6><br>";
					}
                }
        }

    echo "</td>";

	echo "<td width=8><img src=\"img/clear.gif\" width=8 height=1></td>";



    echo "</tr>";
    echo "</table>";
    
    echo "</td></tr>";
    echo "</table>";


    
    
    ?>    

