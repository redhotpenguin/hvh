<?php

chdir('/var/www/hvh2.hvh.com');
include("./phpdev/util/bin_connect.inc");

// DATA FOR AUTO POPULATING REGION SEARCH // ------------------------------------------------------------------------

$regions_query = "SELECT Region__c from Property__c order by Region__c asc";
$regions_results = $mySforceConnection->query($regions_query);
$regions = $regions_results->records;

$memcache = new Memcache;
$memcache->connect('localhost', 11211) or die ("Could not connect");
$count = 1;

foreach ($regions AS $region) {

	$key = "regions|$count";
	$memcache->set($key, $region, MEMCACHE_COMPRESSED, 0) or die ("Failed to save data at the server");

	$get_result = $memcache->get($key);
	var_dump($get_result);
	$region_obj = new SObject($get_result);
	$count++;
}	

?>    

