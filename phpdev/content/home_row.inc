<?php
$memcache = new Memcache;
$memcache->connect('localhost', 11211) or die ("Could not connect");

$Debug = false;

require_once ('soapclient/SforcePartnerClient.php');
#$mySforceConnection = new SforcePartnerClient();
while ($count_it <= $limit) {

	error_log("making new home object\n", 0);

	$key = "$cat|$count_it";
	$get_result = $memcache->get($key);
	$sObject = new SObject($get_result);

	if (!$sObject) {
		next;
	}

	if ($Debug) {
	error_log("printing home object\n", 0);
	}

    echo "<td width=175 bgcolor=\"#f2f2f2\" valign=top>";
    echo "<table border=0 cellpadding=8 cellspacing=0 width=175>";
    echo "<tr><td align=center class=entry>";
    echo "<span class=entry_title><a href=\"listing.php?prop_id=$sObject->Id\" class=home_row>".$sObject->fields->Name."</a></span><br>";
        echo "<span class=entry_loc><a href=\"listing.php?prop_id=$sObject->Id\" class=home_row>".$sObject->fields->City__c.", ".$sObject->fields->Location__c."</a></span><Br>";
        echo "<a href=\"listing.php?prop_id=$sObject->Id\"><img width=\"216\" height=\"152\" src=\"".$sObject->fields->Image_URL_1__c."\" border=0 vspace=4></a><br>";
        echo "<span class=entry_desc>".$sObject->fields->Teaser__c."</span><br>";
        echo "<a href=\"listing.php?prop_id=$sObject->Id\" class=ulink>More Details</a>";
        echo "</td></tr>";
    echo "</table>";
    echo "<td>";
    $count_it++;
    if ($count_it < $limit) {
        echo "<td width=3><img src=\"img/clear.gif\" width=3 height=1></td>";
    }
}
?>    

