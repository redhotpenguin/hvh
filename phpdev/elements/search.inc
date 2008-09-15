<?php
$memcache = new Memcache;
$memcache->connect('localhost', 11211) or die ("Could not connect");

require_once ('../soapclient/SforcePartnerClient.php');
#$mySforceConnection = new SforcePartnerClient();


?>




<!-- BEGIN SEARCH -->
<table border=0 cellpadding=0 cellspacing=0>
<tr><Td><img src="img/search_props_box.gif"></td></tr>
<tr><td valign=top>
    <table border0 cellpadding=0 cellspacing=0 width="100%">
    <tr><td width=1 bgcolor="#ff3100"><img src="img/clear.gif" width=1 height=1></td>
        <Td valign=top>
			<table border=0 cellpadding=0 cellspacing=0 width="100%">
			<tr><td width=20><img src="img/clear.gif" width=20 height=1></td>
			<td valign=top>
	        <table border=0 cellspacing=0 cellpadding=4 width="100%">
	        <tr><Td><span class=solutions_box>
				<form method=post name=search action="list.php">
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
				<br/><img src="img/clear.gif" height=4 width=1><br/>
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
				</span>
				</form>
			</td></tr>
	        </table>
			</td>
			</tr>
			</table>
        </td>
        <td width=1 bgcolor="#ff3100"><img src="img/clear.gif" width=1 height=1></td>
    </tr>
    <tr><Td colspan=3 bgcolor="#ff3100"><img src="img/clear.gif" width=1 height=1></td></tr>
    </table>
</td></tr>
</table>
<!-- END SEARCH -->
