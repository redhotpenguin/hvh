<?php

include("./phpdev/util/bin_connect.inc");
$query = "SELECT Id, Name, Property_Address__c, Property_Type__c from Property__c limit 4";

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


// $sig_homes = mysql_query("select * from property where prop_cat='$prop_cat' order by home_pos asc limit $limit");
$count_it = 1;
foreach ($sig_homes AS $sig_home) {
	 echo "making new home object\n";

	$sObject = new SObject($sig_home);
	 echo "printing home\n";
	var_dump($sObject);

	$key = "signature|$count_it";
	$memcache->set($key, $sig_home, MEMCACHE_COMPRESSED, 0) or die ("Failed to save data at the server");

	echo "Store data in the cache (data will expire in 10 seconds)<br/>\n";

	$get_result = $memcache->get($key);
	echo "\n\n\n\nData from the cache:<br/>\n";

	var_dump($get_result);
	echo "end Data from the cache:<br/>\n\n\n\n\n";

	$count_it++;
}

?>    

