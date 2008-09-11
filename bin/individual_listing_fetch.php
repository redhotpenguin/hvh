<?php

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

	$single_query = "SELECT Id, Name, Property_Address__c, Property_Type__c from Property__c where Id='$prop_obj->Id' limit 1";
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

