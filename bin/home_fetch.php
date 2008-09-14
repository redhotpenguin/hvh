<?php

include("./phpdev/util/bin_connect.inc");

// DATA CACHE FOR THE TWELVE PROPERTIES TO BE FEATURED ON THE HOME PAGE // ------------------------------------------


$cats = array("signature_home","signature_inn","premier_home","premier_inn");


foreach ($cats as $cat) {

	if ($cat == 'signature_home') { $friendly_cat = 'Signature Home'; }
	if ($cat == 'signature_inn') { $friendly_cat = 'Signature Inn'; }
	if ($cat == 'premier_home') { $friendly_cat = 'Premier Home'; }
	if ($cat == 'premier_inn') { $friendly_cat = 'Premier Inn'; }


	$query = "SELECT Id, Name, Property_Address__c, Category__c, Teaser__c, Description__c, Location__c, Region__c, City__c, Image_URL_1__c  from Property__c where Category__c='$friendly_cat' order by Name ASC limit 3";

	echo "running query\n";

	$query_results = $mySforceConnection->query($query);

	echo "getting records\n";

	$sig_homes = $query_results->records;
	
	$memcache = new Memcache;
	$memcache->connect('localhost', 11211) or die ("Could not connect");

	$version = $memcache->getVersion();
	echo "\n\nServer's version: ".$version."<br/>\n";

	$status = $memcache->getServerStatus('localhost', 11211);
	echo "\n\nServer's status: ".$status."<br/>\n";

	$count_it = 1;

	foreach ($sig_homes AS $sig_home) {

		 echo "making new home object\n";

		$key = "$cat|$count_it";
		$memcache->set($key, $sig_home, MEMCACHE_COMPRESSED, 0) or die ("Failed to save data at the server");

		echo "Store data in the cache (data will expire in 10 seconds)<br/>\n";

		$get_result = $memcache->get($key);
		echo "\n\n\n\nData from the cache:<br/>\n";

		var_dump($get_result);
		echo "end Data from the cache:<br/>\n\n\n\n\n";

		$sObject = new SObject($get_result);
		var_dump($sObject);
		echo "end Data from the cache:<br/>\n\n\n\n\n";

		$count_it++;
	}

}

?>    

