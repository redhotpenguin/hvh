<?php

chdir('/var/www/hvh2.hvh.com');

include("./phpdev/util/bin_connect.inc");

// DATA CACHE FOR THE TWELVE PROPERTIES TO BE FEATURED ON THE HOME PAGE // ------------------------------------------


$cats = array("all_signature_home","all_signature_hotel","all_premier_home","all_premier_hotel");


foreach ($cats as $cat) {

	if ($cat == 'all_signature_home') { $friendly_cat = 'Signature Home'; }
	if ($cat == 'all_signature_inn') { $friendly_cat = 'Signature Hotel'; }
	if ($cat == 'all_premier_home') { $friendly_cat = 'Premier Home'; }
	if ($cat == 'all_premier_inn') { $friendly_cat = 'Premier Hotel'; }


	$query = "SELECT Id, Name, Property_Address__c, Category__c, Teaser__c, Description__c, Location__c, City__c, Image_URL_1__c  from Property__c where Category__c='$friendly_cat' and Available_to_the_Public__c=true order by Name ASC";
	echo "running query\n";

	$query_results = $mySforceConnection->query($query);

	echo "getting records\n";

	$props = $query_results->records;
	
	$memcache = new Memcache;
	$memcache->connect('localhost', 11211) or die ("Could not connect");

	$count_it = 1;


	foreach ($props AS $prop) {

		 echo "making new home object\n";

		$key = "$cat|$count_it";
		$memcache->set($key, $prop, MEMCACHE_COMPRESSED, 0) or die ("Failed to save data at the server");


		$get_result = $memcache->get($key);
		echo "\n\n\n\nData from the cache:<br/>\n";

		var_dump($get_result);
		echo "end Data from the cache:<br/>\n\n\n\n\n";
		$sObject = new SObject($get_result);
		var_dump($sObject);
		echo "end Data from the cache:<br/>\n\n\n\n\n";

		$count_it++;
	}

	$count_key = "count|$cat";
	$memcache->set($count_key, $count_it, MEMCACHE_COMPRESSED, 0) or die ("Failed to save data at the server");

	$search_key = "search|$cat";
	$memcache->set($search_key, $cat, MEMCACHE_COMPRESSED, 0) or die ("Failed to save data at the server");
	

	$get_count = $memcache->get($set_key);
}

?>    

