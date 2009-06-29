<?php

chdir('/var/www/hvh2.hvh.com');
include("./phpdev/util/bin_connect.inc");

// DATA CACHE FOR INDIVIDUAL PROPERTY LISTINGS // -------------------------------------------------------------------

$prop_array_query = "SELECT Id from Property__c";
$prop_array_results = $mySforceConnection->query($prop_array_query);
$prop_array = $prop_array_results->records;

$memcache = new Memcache;
$memcache->connect('localhost', 11211) or die ("Could not connect");

$count = 1;

foreach ($prop_array as $prop) {

	$key = "id|$count";
	$memcache->set($key, $prop, MEMCACHE_COMPRESSED, 0) or die ("Failed to save data at the server");
		
	$get_result = $memcache->get($key);
	var_dump($get_result);
	$prop_obj = new SObject($get_result);
	error_log("\nTHE FREAKING PROP LOOP\n\n\n".$prop_obj->Id."\n\n\n\n\n");

	// PUTTING EACH PROPERTY OBJ IN STATE WITH KEY EQUAL TO SFORCE ID //

    $amenities_array = array("Wireless_Internet__c", "Private_Hot_Tub__c", 
	"Swimming_Pool__c", "High_Definition_TV_DVR__c",
	"Stereo_System__c", "CD_Player__c", "Music_Library__c", "VCR__c",
	"DVD_Player__c",
	"Video_Library__c", "Bath_Towels__c", "Bed_Linens__c", "Washer_Dryer__c",
	"Refrigerator__c", "Dishwasher__c", "Oven__c",
	"Microwave__c", "Air_Conditioning__c",
	"Full_Kitchen__c", "Cooking_Utensils__c", "Barbecue__c", "Hair_Dryer__c" );


	$q_fields = "";
	foreach ($amenities_array as $amenity) {
	    $q_fields = $q_fields.", ".$amenity;
        }
#	error_log("\nQ Fields is $q_fields");

	$single_query = "SELECT Id, Name, Property_Calendar_Code__c, Property_Address__c, Category__c, Teaser__c, Description__c, Location__c, Image_URL_1__c, Image_URL_2__c, Image_URL_3__c, Image_URL_4__c, Image_URL_5__c, Image_URL_6__c, Image_URL_7__c, Image_URL_8__c, City__c $q_fields, Special_Amenities__c, Solutions_Customer__c, Check_in_Time__c, Check_out_Time__c, Nightly_Rate_List_Price__c, Local_Tax_Rate__c, Security_Deposit__c, Housekeeping_Fee__c from Property__c where Id='$prop_obj->Id' limit 1";
	$single_results = $mySforceConnection->query($single_query);
	$single = $single_results->records;

	$memcache = new Memcache;
	$memcache->connect('localhost', 11211) or die ("Could not connect");
		

	foreach ($single as $one) {
		$key = "id|$prop_obj->Id";
		$memcache->set($key, $one, MEMCACHE_COMPRESSED, 0) or die ("Failed to save data at the server");			

		$get_result = $memcache->get($key);
		echo "\n\n\nCREATING THE DAMN OBJECTS\n\n\n";
		var_dump($get_result);
		$single_obj = new SObject($get_result);
		echo "\n\n\nNOW WEEZ LOOKING AT CACHED DATA OBJECTS\n\n\n\n";
		var_dump($single_obj);

	}

	$count++;

}

?>    

