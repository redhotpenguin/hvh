<?php

include("./phpdev/util/bin_connect.inc");

// DATA CACHE FOR THE CITY SEARCH // ------------------------------------------


	$query = "SELECT Id, Name, Property_Address__c, Category__c, Teaser__c, Description__c, Display_Location__c, City__c, Image_URL_1__c, Region__c  from Property__c order by Category__c, Name ASC";
	echo "running query\n";

	$query_results = $mySforceConnection->query($query);

	echo "getting records\n";

	$props = $query_results->records;
	
	$memcache = new Memcache;
	$memcache->connect('localhost', 11211) or die ("Could not connect");

	$count_it = 1;


	foreach ($props AS $prop) {

		$prop_obj = new SObject($prop);
		$prop_obj_city = $prop_obj->fields->City__c;

        if ("$prop_obj_city" != "$prop_obj_city_check") {

    		$count_key = "count|city|$prop_obj_city_check";
    		$memcache->set($count_key, $count_it, MEMCACHE_COMPRESSED, 0) or die ("Failed to save data at the server");
			$count_check = $memcache->get($count_key);
		
	        $count_it = 1;
        }

		$key = "city|$prop_obj_city|$count_it";
		
		error_log("$key\n");

		$memcache->set($key, $prop, MEMCACHE_COMPRESSED, 0) or die ("Failed to save data at the server");

		$get_result = $memcache->get($key);
		$sObject = new SObject($get_result);

		$count_it++;
		$prop_obj_city_check = $prop_obj_city;

	}	
?>    

