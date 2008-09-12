<?php

include("./phpdev/util/bin_connect.inc");

// DATA FOR AUTO POPULATING CITY SEARCH // ------------------------------------------------------------------------

$cities_query = "SELECT City__c from Property__c order by City__c asc";
$cities_results = $mySforceConnection->query($cities_query);
$cities = $cities_results->records;

$memcache = new Memcache;
$memcache->connect('localhost', 11211) or die ("Could not connect");
$count = 1;

foreach ($cities AS $city) {

	$key = "cities|$count";
	$memcache->set($key, $city, MEMCACHE_COMPRESSED, 0) or die ("Failed to save data at the server");

	$get_result = $memcache->get($key);
	var_dump($get_result);
	$city_obj = new SObject($get_result);
	$count++;
}	

?>    

