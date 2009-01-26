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
	echo "<td align=right><a href=\"listing.php?prop_id=$get_prop_id&bkt=1\"><img src=\"img/bkt_off.gif\" border=0></a></td>";
	
	echo "</tr>";
	 echo "<tr><td colspan=3 bgcolor=\"#ffffff\"><img src=\"img/clear.gif\" width=1 height=3></td></tr>";
	if ($cto == 1) {
		echo "<tr><td colspan=3 bgcolor=\"#2c74c8\"><img src=\"img/clear.gif\" width=1 height=10></td></tr>";
	}

	
	if ($fhh == 1) {
		echo "<tr><td colspan=3 bgcolor=\"#db1f00\"><img src=\"img/clear.gif\" width=1 height=10></td></tr>";
	}
		
	if ($bkt == 1) {
		echo "<tr><td colspan=3 bgcolor=\"#2cb532\"><img src=\"img/clear.gif\" width=1 height=10></td></tr>";
	}
	
	echo "<tR><td colspan=3><img src=\"img/clear.gif\" width=1 height=12></td></tr>";
	echo "</table>";
	if ($cto == 1) {
		echo "<script>setTimeout(\"document.cto.fname.focus()\",10);</script>";
        echo "<span class=detail_header>".$listing_obj->fields->Name."</span>";
        echo "<span class=entry_loc> - ".$listing_obj->fields->City__c.", ".$listing_obj->fields->Location__c."</span></a>";
		echo "<table border=0 cellpadding=1 cellspacing=0 width=\"100%\">";
		echo "<form name=cto action='http://www.hvh.com/cgi-bin/bookit.cgi' method=post>";
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
	
	if ($fhh == 1) {
		echo "<script>setTimeout(\"document.fhh.fname.focus()\",10);</script>";
                echo "<span class=detail_header>".$listing_obj->fields->Name."</span>";
                echo "<span class=entry_loc> - ".$listing_obj->fields->City__c.", ".$listing_obj->fields->Location__c."</span></a>";
		echo "<table border=0 cellpadding=1 cellspacing=0 width=\"100%\">";
		echo "<form name=fhh action='http://www.hvh.com/cgi-bin/bookit.cgi' method=post>";
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
	}
	
	if ($bkt == 1) {
		echo "<span class=detail_header>".$listing_obj->fields->Name."</span>";
		echo "<span class=entry_loc> - ".$listing_obj->fields->City__c.", ".$listing_obj->fields->Location__c."</span></a>";
		echo "<table border=0 cellpadding=1 cellspacing=0 width=\"100%\">";
		echo "<form name=bkt action='http://www.hvh.com/cgi-bin/bookit.cgi' method=post>";
		echo "<input type='hidden' name='rm' value='bookit'>";
		echo "<tr><Td colspan=3><hr noshade size=1 color=\"#e2e2e1\"></td></tr>";
		echo "<tr><td copy colspan=3 class=entry_desc>To <b><i>book your vacation</i></b> at  ";
		echo $listing_obj->fields->Name;
		echo ", please fill out the form below and click the 'Book it!' button at the bottom of the page.</td></tr>";
		echo "<tr><Td colspan=3><hr noshade size=1 color=\"#e2e2e1\"></td></tr>";

		echo "<tr><td colspan=3>";
		include "../phpdev/content/xdev_content_listing_detail_cto.inc";

		echo "</td></tr>";
		echo "<tr><td colspan=3 class=reg_copy><input type=image src=\"img/bkt_off.gif\" vspace=4></td></tr>";
		echo "</form>";
		echo "</table><br>";
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
                if (strlen($listing_obj->fields->$img) > 3) {
                        echo "<img width=\"216\" height=\"152\" src=\"".$listing_obj->fields->$img."\"><br><img src=\"img/clear.gif\" width=1 height=6><br>";
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
   	   	if ($listing_obj->fields->$amenity) {
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

