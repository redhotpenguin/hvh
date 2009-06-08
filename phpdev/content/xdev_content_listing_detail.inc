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
// $props = mysql_query("select * from property where id='$prop_id' limit 1");


//    $images = mysql_query("select * from property_img where property_id='$home[id]'");        
    echo "<table border=0 cellpadding=0 align=center cellspacing=0 width=\"100%\">";

        echo "<tr class=class_detail_bar>";
        echo "<td class=detail_bar>".$listing_obj->fields->Category__c."";
        if ($show_region) {
            echo " in $value";
        }
        if ($show_city) {
            echo " in $value";
        }
        echo "</td>";
        echo "<td class=detail_bar><img src=\"img/clear.gif\" width=1 height=1></td>";
        if ($param && $value) {
            echo "<td class=detail_return align=right><a href=\"javascript:history.back()\" class=cat_header>Return to Previous  Page</a></td>";
        } else {
            echo "<td class=detail_return align=right><a href=\"index.php\" class=cat_header>Return to Home Page</a></td>";
        }
        echo "</tr>";
  
 
    echo "<tr><td colspan=3>";
    echo "<table border=0 cellpadding=0 cellspacing=0 width=\"100%\">";
    echo "<tr>";
      
    echo "<td bgcolor=\"#f2f2f2\" valign=top>";
    echo "<table border=0 cellpadding=14 cellspacing=0 width=\"100%\">";

    echo "<tr>";

    echo "<td class=entry valign=top bgcolor=\"#ffffff\">";

	$get_prop_id = $_GET['prop_id'];

	echo "<table border=0 cellpadding=0 cellspacing=0 width=\"100%\">";
	echo "<tr><td><a href=\"listing.php?prop_id=$get_prop_id&cto=1\"><img src=\"img/cto_off.gif\" border=0></a></td>";
	echo "<td align=center><a href=\"listing.php?prop_id=$get_prop_id&fhh=1\"><img src=\"img/hold_off.gif\" border=0 hspace=3></a></td>";
	if ($customer == 'true') {
	echo "<td align=right><a href=\"listing.php?prop_id=$get_prop_id&bkt=1\"><img src=\"img/bkt_off.gif\" border=0></a></td>";
	} else {
	echo "<td align=right><a href=\"listing.php?prop_id=$get_prop_id&cto=1&nobkt=1\"><img src=\"img/bkt_off.gif\" border=0></a></td>";
	}
	echo "</tr>";
	 echo "<tr><td colspan=3 bgcolor=\"#ffffff\"><img src=\"img/clear.gif\" width=1 height=2></td></tr>";
	if (($cto == 1) || ($cto == 'success')) {
		echo "<tr><td colspan=3 bgcolor=\"#2c74c8\"><img src=\"img/clear.gif\" width=1 height=10></td></tr>";
	}

	
	if (($fhh == 1) || ($fhh == 'success')) {
		echo "<tr><td colspan=3 bgcolor=\"#db1f00\"><img src=\"img/clear.gif\" width=1 height=10></td></tr>";
	}
		
	if ($bkt == 1) {
		echo "<tr><td colspan=3 bgcolor=\"#2cb532\"><img src=\"img/clear.gif\" width=1 height=10></td></tr>";
	}
	
	echo "<tR><td colspan=3><img src=\"img/clear.gif\" width=1 height=12></td></tr>";
	echo "</table>";
	if ($cto == 1) {
		$nobkt = $_GET['nobkt'];

		if ($nobkt == 1) {

echo "Thank you for your interest in " . $listing_obj->fields->Name  .".  HVH is currently working with this location to complete the automated booking    s process.  For now, please populate the \"Contact the Owner\" form below.  In the comments section, please note your request to place a 48 hour hold on the proper    ty for the selected dates.  Someone will respond to your request as soon as possible.  Thanks for using HVH!<br><br>";

		}
		echo "<script>setTimeout(\"document.cto.fname.focus()\",10);</script>";
        echo "<span class=detail_header>".$listing_obj->fields->Name."</span>";
        echo "<span class=entry_loc> - ".$listing_obj->fields->City__c.", ".$listing_obj->fields->Location__c."</span></a>";
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
	if ($cto == 'success') {
		echo "<div class=success>Your message and contact information has been sent to the owner or property manager at ".$listing_obj->fields->Name.".</div><br>";
	}
	
	if ($fhh == 1) {
		if ($customer == 'true') {
		echo "<script>setTimeout(\"document.fhh.fname.focus()\",10);</script>";
                echo "<span class=detail_header>".$listing_obj->fields->Name."</span>";
                echo "<span class=entry_loc> - ".$listing_obj->fields->City__c.", ".$listing_obj->fields->Location__c."</span></a>";
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
		echo "<span class=detail_header>".$listing_obj->fields->Name."</span>";
		echo "<span class=entry_loc> - ".$listing_obj->fields->City__c.", ".$listing_obj->fields->Location__c."</span></a>";
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
			echo "<tr><Td  bgcolor=\"#e2e2e1\" class=entry_desc>Fee Summary</td><td width=1 bgcolor=black><img src=\"img/clear.gif\" width=1 height=1></td><td bgcolor=\"#999999\" class=entry_desc align=center><font color=white>Amount</font></td>";	
			echo "<tr><td class=entry_desc>Nightly Rate:</td><td rowspan=16 width=1 bgcolor=red><img src=\"img/clear.gif\" width=1 height=1></td><td class=entry_desc align=right><b>$$nightly_rate</b></td></tr>";
			echo "<tr><td colspan=3 height=1 bgcolor=\"#cccccc\"><img src=\"img/clear.gif\" width=1 height=1></td></tr>";
			echo "<tr><td class=entry_desc>Number of Nights:</td><td class=entry_desc align=right><b>$num_nights</b></td></tr>";
			echo "<tr><td colspan=3 height=1 bgcolor=\"#cccccc\"><img src=\"img/clear.gif\" width=1 height=1></td></tr>";
			echo "<tr><td class=entry_desc>Rental Subtotal:</td><td class=entry_desc align=right><b>$$rental_subtotal</b></td></tr>";
			echo "<tr><td colspan=3 height=1 bgcolor=\"#cccccc\"><img src=\"img/clear.gif\" width=1 height=1></td></tr>";
			echo "<tr><td class=entry_desc>Local Accommodations Tax (<b>$local_tax%</b>):</td><td class=entry_desc align=right><b>$$total_tax</b></td></tr>";
			echo "<tr><td colspan=3 height=1 bgcolor=\"#cccccc\"><img src=\"img/clear.gif\" width=1 height=1></td></tr>";
			echo "<tr><td class=entry_desc>Total Rental Amount:</td><td class=entry_desc align=right><b><font color=red>$$rental_total</font></b></td></tr>";
			echo "<tr><td colspan=3 height=1 bgcolor=\"#cccccc\"><img src=\"img/clear.gif\" width=1 height=1></td></tr>";
			echo "<tr><td class=entry_desc>Deposit Amount:</td><td class=entry_desc align=right><B>$$deposit</b></td></tr>";
			echo "<tr><td colspan=3 height=1 bgcolor=\"#cccccc\"><img src=\"img/clear.gif\" width=1 height=1></td></tr>";
			echo "<tr><td class=entry_desc>First Payment Charged Immediately:</td><td class=entry_desc align=right><b>$$first_payment</b>";
			echo "<tr><td colspan=3 height=1 bgcolor=\"#cccccc\"><img src=\"img/clear.gif\" width=1 height=1></td></tr>";
			echo "<tr><td class=entry_desc>Second Payment Charged on $second_charge_date:</td><td class=entry_desc align=right><b>$$second_payment</b></td></tr>";
			echo "</table>";
			echo "<br><br>A cleaning fee of <b>$$cleaning_fee</b> will be deducted from the deposit which will be returned 30 days after your stay provided there are no damages or additional fees (i.e. pay-per-view movies).";

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
		echo "<tr><td colspan=3 class=reg_copy><input type=image src=\"img/bkt_off.gif\" vspace=4 onclick=\"this.disabled='disabled'\"></td></tr>";
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
    echo "<span class=detail_header>".$listing_obj->fields->Name."</span> - ";
	echo "<span class=entry_loc>".$listing_obj->fields->City__c.", ".$listing_obj->fields->Location__c."</span></a><Br>";
	echo "<hr noshade size=1 color=\"#e2e2e1\">";
//  echo "<span class=entry_loc>Property Address: ".$listing_obj->fields->Property_Address__c."</span></a><br><Br>";
    echo "<span class=entry_desc>".$listing_obj->fields->Description__c."</span><br>";
}
    echo "</td>";

    echo "<td valign=top class=caption width=216 rowspan=2>";

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
	echo "</tr>";
	echo "<Tr>";	
    echo "<td valign=top class=amen>";

if ($hide_content != 1) {
   
	   	
    if ($listing_obj->fields->Special_Amenities__c != '') {

      echo "<h3>Special Amenities</h3>";
    
      $special_array = explode( ';', $listing_obj->fields->Special_Amenities__c);

      foreach ($special_array as $special) {
	
        echo "<hr noshade size=1 color=\"#e2e2e1\">$special<br />";
      }

        echo "<hr noshade size=1 color=\"#e2e2e1\"><br />";
    }

    echo "<h3>Amenities</h3>";
    $amenities_array =
 array("Wireless_Internet__c", "Private_Hot_Tub__c", 
	"Swimming_Pool__c", "High_Definition_TV_DVR__c",
	"Unlimited_Long_Distance__c",
	"Stereo_System__c", "CD_Player__c", "Music_Library__c", "VCR__c",
	"DVD_Player__c",
	"Video_Library__c", "Bath_Towels__c", "Bed_Linens__c", "Washer_Dryer__c",
	"Refrigerator__c", "Dishwasher__c", "Oven__c",
	"Microwave__c", "Air_Conditioning__c",
	"Full_Kitchen__c", "Cooking_Utensils__c", "Barbecue__c", "Hair_Dryer__c" );


    $amenities_hash =
 array("Wireless_Internet__c" => "Wireless Internet",
	"Private_Hot_Tub__c" => "Private Hot Tub",
	"Swimming_Pool__c" => "Swimming Pool",
	 "High_Definition_TV_DVR__c" => "High Definition TV/DVR",
	"Unlimited_Long_Distance__c" => "Unlimited Long Distance",
	"Stereo_System__c" => "Stereo System",
	 "CD_Player__c" => "CD Player",
	"Music_Library__c" => "Music Library",
	"VCR__c" => "VCR",
	"DVD_Player__c" => "DVD Player",
	"Video_Library__c" => "Video Library",
	 "Bath_Towels__c" => "Bath Towels",
	 "Bed_Linens__c"  => "Bed Linens",
	"Washer_Dryer__c" => "Washer/Dryer",
	"Refrigerator__c" => "Refrigerator",
	 "Dishwasher__c" => "Dishwasher",
	"Oven__c" => "Oven",
	"Microwave__c" => "Microwave",
	 "Air_Conditioning__c" => "Air Conditioning",
	"Full_Kitchen__c" => "Full Kitchen",
	 "Cooking_Utensils__c" => "Cooking Utensils",
	 "Barbecue__c" => "Barbecue",
	 "Hair_Dryer__c" => "Hair Dryer");



	foreach ($amenities_array as $amenity) {
   	   	if ($listing_obj->fields->$amenity =='true') {
        	echo "<hr noshade size=1 color=\"#e2e2e1\">".$amenities_hash[$amenity];
    		}
   	}
}
    echo "</td>";
    echo "</tr>";
    echo "</table>";
    echo "<td>";
    echo "</tr>";
    echo "</table>";
    
    echo "</td></tr>";
    echo "</table>";


    
    
    ?>    

