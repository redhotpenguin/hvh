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

    echo "<td valign=top class=caption width=216>";

	$img_array = array("Image_URL_2__c","Image_URL_3__c","Image_URL_4__c","Image_URL_5__c","Image_URL_6__c","Image_URL_7__c","Image_URL_8__c");
	foreach ($img_array as $img) {	
		if (strlen($listing_obj->fields->$img) > 3) {
			echo "<img src=\"".$listing_obj->fields->$img."\" vspace=4><br>caption<br>";
		}
	}
    echo "</td>";
    echo "<td class=entry valign=top bgcolor=\"#ffffff\">";
    echo "<span class=detail_header>".$listing_obj->fields->Name."</span> - ";
	echo "<span class=entry_loc>".$listing_obj->fields->City__c.", ".$listing_obj->fields->Location__c."</span></a><Br>";
 //   echo "<span class=entry_loc>Property Address: ".$listing_obj->fields->Property_Address__c."</span></a><br><Br>";
    echo "<span class=entry_desc>".$listing_obj->fields->Description__c."</span><br>";
    echo "</td>";
    echo "<td valign=top class=amen width=200>";
    echo "Amenities";
    echo "<hr noshade size=1 color=\"#e2e2e1\">Beach View -<br>Swimming Pool -<br>Swim-Up Bar -<br>Hot Tub -<br>Private Hot Tub - ";
    echo "<hr noshade size=1 color=\"#e2e2e1\">Attractions<hr noshade size=1 color=\"#e2e2e1\">";
    echo "Golf Course -<br>Horse Back Riding -<br>Swimming -<br>Hiking -<br>Bike Trails -<br>Nature Tours -";
    echo "<hr noshade size=1 color=\"#e2e2e1\">Dining<hr noshade size=1 color=\"#e2e2e1\">";
    echo "Some Restaaurant -<br>Some Fine Restaurant -<br>Some Divy Cafe -";
    echo "<hr noshade size=1 color=\"#e2e2e1\">Nightlife<hr noshade size=1 color=\"#e2e2e1\">";
    echo "Disco Dans -<br>The Mayfair Pub -<br>Cafe Rock -";
    echo "</td>";
    echo "</tr>";
    echo "</table>";
    echo "<td>";
    $count_it++;
    echo "</tr>";
    echo "</table>";
    
    $end_type = "$home[prop_cat]"; 
    
    echo "</td></tr>";
    echo "</table>";


    
    
    ?>    

