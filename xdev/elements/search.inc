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

<tr><td class=search>
<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr><td class=search colspan=2>
<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr><td width=16><img src="img/clear.gif" width=16 height=1></td>
	<td class=search>
<b>TRAVELERS</b><br>
Looking for the perfect vacation rental? Search our extensive list of qualified vacation rental properties to find that special spot for you and your family.
</td>
<td width=16><img src="img/clear.gif" width=16 height=1></td>
</tr>
</table>
<br><Br>
</td></tr>
<tr><td width=16><img src="img/clear.gif" width=16 height=1></td><td class=search>Search by keyword.</td></tr>

<tr><td width=16><img src="img/clear.gif" width=16 height=1></td><td class=search>
<form action="http://www.hvh.com/xdev/gsearch.php" id="cse-search-box">
  <div>
<!--<input type="hidden" name="cx" value="008563546325721658501:ic2lrvldrhu" />-->
    <input type="hidden" name="cx" value="008563546325721658501:ty76vbgkwp0" />

    <input type="hidden" name="cof" value="FORID:11;NB:1" />
    <input type="hidden" name="ie" value="UTF-8" />
    <input type="text" name="q" size="25" />
    &nbsp;<input type="submit" name="sa" value="Search" />

  </div>
</form>
</td></tr>
<tr><td width=16><img src="img/clear.gif" width=16 height=1></td><td class=search><font size=4><B>Or</b></font>, <i>Search by city or region.</i></td></tr>
</table>
<Br>

</td></tr>

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
                 while ($count < 500) {

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
                 while ($count < 500) {

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
