<?php
$memcache = new Memcache;
$memcache->connect('localhost', 11211) or die ("Could not connect");

$Debug = false;

require_once ('soapclient/SforcePartnerClient.php');
#$mySforceConnection = new SforcePartnerClient();
while ($count_it <= $limit) {

	error_log("making new home object\n", 0);

	$key = "$cat|$count_it";
	$get_result = $memcache->get($key);
	$sObject = new SObject($get_result);

	if (!$sObject) {
		next;
	}

	if ($Debug == true) {
		error_log("printing home object\n", 0);
	}

    echo "<table border=0 cellpadding=0 cellspacing=0 width=148>";
    echo "<tr><td align=center class=entry>";
	$sub_name_max = 19;
	$sub_name = substr($sObject->fields->Name,0,$sub_name_max);
	$sub_name_len = strlen($sub_name);
	if ($sub_name_len >= $sub_name_max) {
		$sub_name = $sub_name . '...';
	} 
	$sub_loc_max = 22;

	$sub_loc = $sObject->fields->City__c . ", " . $sObject->fields->Location__c;
	$sub_loc_print = substr($sub_loc,0,$sub_loc_max);
	$sub_loc_print_len = strlen($sub_loc_print);

	if ($sub_loc_print_len >= $sub_loc_max) {
		$sub_loc_print = $sub_loc_print . '...';
	}
	$prop_teaser = $sObject->fields->Teaser__c;	
	$prop_teaser = str_replace("'",'"', $prop_teaser);
	$prop_teaser = str_replace('"',"\'", $prop_teaser);
//	$teaser_parts = explode(' ', $prop_teaser);

//	$fixed_teaser = "";
//	$counter = 0;
//	foreach ($teaser_parts AS $part) {

//		$part_len = strlen($part);
		
//		$counter = ($counter + $part_len);
//		$fixed_teaser .= $part . ' ';
//		if ($counter >= 30 ){
//			$fixed_teaser .= '<br>';
//			$counter = 0;	
//		}
//	}
	







		echo "<a href=\"listing.php?prop_id=$sObject->Id\" onmouseover=\"Tip('$prop_teaser', BALLOON, true, ABOVE, true, OFFSETX, -17, PADDING, 0)\" onmouseout=\"UnTip()\"><img width=\"148\" height=\"121\" src=\"".$sObject->fields->Image_URL_1__c."\" border=0 vspace=4></a><br>";
    echo "<span class=entry_title><a href=\"listing.php?prop_id=$sObject->Id\" class=home_title>".$sub_name."</a></span><br>";
        echo "<span class=entry_loc><a href=\"listing.php?prop_id=$sObject->Id\" class=home_row>".$sub_loc_print."</a></span><Br>";


//        echo "<span class=entry_desc>".$sObject->fields->Teaser__c."</span><br>";
//        echo "<a href=\"listing.php?prop_id=$sObject->Id\" class=ulink>More...</a>";


        echo "</td></tr>";
    echo "</table>";
    $count_it++;
    if ($count_it < $limit) {
    }
}
?>    

