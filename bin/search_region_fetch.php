<?php

chdir('/var/www/hvh2.hvh.com');
include("./phpdev/util/bin_connect.inc");

// DATA CACHE FOR THE REGIONAL SEARCH // ------------------------------------------


	$query = "SELECT Id, Name, Property_Address__c, Category__c, Teaser__c, Description__c, Location__c, City__c, Image_URL_1__c, Region__c  from Property__c where  Available_to_the_Public__c=true order by Region__c, Name ASC";
	echo "running query\n";

	$query_results = $mySforceConnection->query($query);

	echo "getting records\n";

	$props = $query_results->records;
	
	$memcache = new Memcache;
	$memcache->connect('localhost', 11211) or die ("Could not connect");

	$count_it = 1;


	foreach ($props AS $prop) {

		$prop_obj = new SObject($prop);
		$prop_obj_region = $prop_obj->fields->Region__c;

	        if ("$prop_obj_region" != "$prop_obj_region_check") {

    			$count_key = "count|region|$prop_obj_region_check";
    			$memcache->set($count_key, $count_it, MEMCACHE_COMPRESSED, 0) or die ("Failed to save data at the server");
			$count_check = $memcache->get($count_key);
		
		        $count_it = 1;
        	}

		$key = "region|$prop_obj_region|$count_it";
		
		error_log("$key\n");

		$memcache->set($key, $prop, MEMCACHE_COMPRESSED, 0) or die ("Failed to save data at the server");

		$get_result = $memcache->get($key);
		$sObject = new SObject($get_result);

		$count_it++;
		$prop_obj_region_check = $prop_obj_region;

	}	
?>    

