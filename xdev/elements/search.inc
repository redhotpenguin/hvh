<?php
$memcache = new Memcache;
$memcache->connect('localhost', 11211) or die ("Could not connect");

// ADDED ../ TO REQUIRE ONCE CALL FOR THIS DEV DIRECTORY - NEEDS TO GO WHEN WE MOVE IT //
require_once ('../soapclient/SforcePartnerClient.php');
#$mySforceConnection = new SforcePartnerClient();

?>




<!-- BEGIN SEARCH -->
<img src="img/clear.gif" width=1 height=3><bR>
<table border=0 cellpadding=0 cellspacing=0>
<tr><td valign=top>
    <table border0 cellpadding=0 cellspacing=0 width="100%">
    <tr>
        <Td valign=top>
			<table border=0 cellpadding=0 cellspacing=0 width="100%">
			<tr>
			<td valign=top>
	        <table border=0 cellspacing=0 cellpadding=0 width="100%">
	        <tr><Td><span class=solutions_box>
				<form method=post name=search action="list.php">
				<table border=0 cellpadding=0 cellspacing=0 width="100%">
				<tr><td width=10></td>
					<Td valign=top>
				<select name=city class=search_select onChange="this.form.submit()">
                <option value="">By City</option>


                <?php
				$count = 1;
				$distinct_vals = array();
                 while ($count < 100) {

					$key = "cities|$count";
					$city = $memcache->get($key);
					$city_obj = new SObject($city);
					if (!$city_obj) {
						next;
					}
					$city_name = $city_obj->fields->City__c;
					
					// SALES FORCE HACK FOR LACK OF ALLOWING DISTINCT IN SQL //

					if (in_array("$city_name", $distinct_vals)) {} else {
						
						array_push($distinct_vals, "$city_name");
					
						if ($city_name != "") {
                    		echo "<option value=\"".$city_name."\">".$city_name."</option>";
						}
					}
					$count++;
                }
                ?>


				</select>
					</td>
				</tr>
                <tr><td colspan=2><img src="img/clear.gif" width=1 height=4></td></tr>

				<tr><td width=16></td>
					<Td valign=top>
				<select name=region class=search_select onChange="this.form.submit()">
				<option value="">By Region</option>
                <?php
				$count = 1;
				$distinct_vals = array();
                 while ($count < 100) {

					$key = "regions|$count";
					$region = $memcache->get($key);
					$region_obj = new SObject($region);
					$region_name = $region_obj->fields->Region__c;
					
					// SALES FORCE HACK FOR LACK OF ALLOWING DISTINCT IN SQL //

					if (in_array("$region_name", $distinct_vals)) {} else {
						
						array_push($distinct_vals, "$region_name");
					
						if ($region_name != "") {
                    		echo "<option value=\"".$region_name."\">".$region_name."</option>";
						}
					}
					$count++;
                }
                ?>
				</select>
					</td>
				</tr>
				</table>
				<table border=0 cellspacing=0 cellpadding=0 width="100%">
				<tr><td colspan=2><img src="img/clear.gif" width=1 height=8></td></tr>
				<Tr><td width=16></td><td valign=top class=search><font size=4><b>Or</b></font>, click the map icon below to search our properties using google maps.</td></tr>
				<tr><td valign=top colspan=2><a href="map.php?map=na"><img src="img/map_blue.gif" hspace=16 border=0 vspace=10></td></tr>

				</table>
				</span>
				</form>
			</td></tr>
	        </table>
			</td>
			</tr>
			</table>
        </td>
    </tr>
    </table>
</td></tr>
</table>
<!-- END SEARCH -->
