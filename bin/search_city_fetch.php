<?php

chdir('/var/www/hvh2.hvh.com');
include("./phpdev/util/bin_connect.inc");

// DATA CACHE FOR THE CITY SEARCH // ------------------------------------------


	$query = "SELECT Id, Name, Property_Address__c, Category__c, Teaser__c, Description__c, Location__c, City__c, Image_URL_1__c, Region__c  from Property__c  where Available_to_the_Public__c=true order by Category__c, Name ASC";
	echo "running query\n";

	$query_results = $mySforceConnection->query($query);

	echo "getting records\n";

	$props = $query_results->records;

	$memcache = new Memcache;
	$memcache->connect('localhost', 11211) or die ("Could not connect");

	$count_it = 1;

        // zero out the city list
        foreach ($props as $prop) {
		$prop_obj = new SObject($prop);
		$prop_obj_city = $prop_obj->fields->City__c;

		$count_key = "count|city|$prop_obj_city";

		// echo "flushing cache for $count_key\n";
		$memcache->set($count_key,
			       0,
			       MEMCACHE_COMPRESSED, 0)
		       or die ("Failed to save data at the server");
        }


        // now build the new cache
	foreach ($props AS $prop) {

		$prop_obj = new SObject($prop);
		$prop_obj_city = $prop_obj->fields->City__c;

		$count_key = "count|city|$prop_obj_city";
		$current_count = $memcache->get($count_key);

		// echo "count for city $prop_obj_city is $current_count\n";

		// up the count
		$current_count++;
		$memcache->set($count_key,
			       $current_count,
			       MEMCACHE_COMPRESSED, 0)
		       or die ("Failed to save data at the server");

		// add the object
		$prop_key = "city|$prop_obj_city|$current_count";
		$memcache->set($prop_key, $prop,
			       MEMCACHE_COMPRESSED, 0)
		       or die ("Failed to save data at the server");

	}	
?>    

