<?php
$memcache = new Memcache;
$memcache->connect('localhost', 11211) or die ("Could not connect");

require_once ('soapclient/SforcePartnerClient.php');
#$mySforceConnection = new SforcePartnerClient();

$search_key = "search|$search_cat";
$search_key_val = $memcache->get($search_key);

$total_key = "count|$search_key_val";
$total_objs = $memcache->get($total_key);


$param = $_GET['param'];
$value = $_GET['value'];

if ($param) {
    $param = $param;
    $value = $value;
} else {
    if ($_POST['region']) {
        $param = 'region';
        $value = $_POST['region'];
        $show_region = $value;



		$search_cat = "region|$value";
		$total_key = "count|region|$value";
		$total_objs = $memcache->get($total_key);


    } 
    if ($_POST['city']) {
        $param = 'city';
        $value = $_POST['city'];
        $show_city = $value;

        $search_cat = "city|$value";
        $total_key = "count|city|$value";
        $total_objs = $memcache->get($total_key);
		
    }
}





$count_it = 1;

while ($count_it < $total_objs) {

    $key = "$search_cat|$count_it";
    $get_result = $memcache->get($key);



    $list_obj = new SObject($get_result);

    $start_type = $list_obj->fields->Category__c;
 
	echo "<table border=0 cellpadding=0 cellspacing=0 width=\"100%\">";
    if ("$start_type" != "$end_type") {
        echo "<tr class=list_sh>";
        echo "<td class=list_sh>$start_type";
        if ($show_region) {
            echo " in $value";
        }
        if ($show_city) {
            echo " in $value";
        }
        echo "</td>";
        echo "<td class=list_sh><img src=\"img/clear.gif\" width=1 height=1></td>";
        echo "<td class=list_sh align=right><a href=\"index.php\" class=cat_header>Return to Home Page</a></td>";
        echo "</tr>";
        echo "<tr><td colspan=3 height=1><img src=\"img/clear.gif\" width=1 height=1></td></tr>";
    }
    
    echo "<tr><td colspan=3>";
    echo "<table border=0 cellpadding=0 cellspacing=0 width=\"100%\">";
    echo "<tr>";
    
    echo "<td bgcolor=\"#f2f2f2\" valign=top>";
    echo "<table border=0 cellpadding=8 cellspacing=0 width=\"100%\">";
    echo "<tr>";
    echo "<td class=entry valign=top>";
    echo "<span class=entry_title><a href=\"listing.php?prop_id=".$list_obj->Id."\" class=home_row>".$list_obj->fields->Name."</a></span> - ";
    echo "<span class=entry_loc><a href=\"listing.php?prop_id=".$list_obj->Id."\" class=home_row>".$list_obj->fields->Location__c."</span></a><Br>";
    echo "<span class=entry_desc>".$list_obj->fields->Teaser__c."</span><br>";
    echo "<a href=\"listing.php?prop_id=".$list_obj->Id."\" class=ulink>More Details</a>";
    echo "</td>";
    echo "<td valign=top><a href=\"listing.php?prop_id=".$list_obj->Id."&param=$param&value=$value&search_cat=".$search_cat."\" class=home_row><img src=\"img/".$list_obj->fields->Image_URL_1__c."\" border=0 vspace=4></a></td>";
    echo "</tr>";
    echo "</table>";
    echo "<td>";
    $count_it++;
    echo "</tr>";
    echo "</table>";
    echo "<tr><td colspan=3 height=1 bgcolor=\"#cccccc\"><img src=\"img/clear.gif\" width=1 height=1></td></tr>";
    
    $end_type = $list_obj->fields->Category__c; 
    
    echo "</td></tr>";
    echo "</table>";
}    
    
    
    ?>    

