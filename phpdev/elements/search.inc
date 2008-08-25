<?php
// AUTO POLULATE THE RGION AND CITY DROP DOWNS --- //
$regions = mysql_query("select distinct region from property order by region asc");
$cities = mysql_query("select distinct city from property order by city asc");
?>
<!-- BEGIN SEARCH -->
<table border=0 cellpadding=0 cellspacing=0>
<tr><Td><img src="img/search_props_box.gif"></td></tr>
<tr><td valign=top>
    <table border0 cellpadding=0 cellspacing=0 width="100%">
    <tr><td width=1 bgcolor="#99cc99"><img src="img/clear.gif" width=1 height=1></td>
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
                while ($cit = mysql_fetch_array($cities)) {
                    echo "<option value=\"$cit[city]\">$cit[city]</option>";
                }
                ?>
				</select>
				<br/>
				<select name=region class=search_select onChange="this.form.submit()">
				<option value="">By Region</option>
                <?php
                while ($reg = mysql_fetch_array($regions)) {
                    echo "<option value=\"$reg[region]\">$reg[region]</option>";
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
        <td width=1 bgcolor="#99cc99"><img src="img/clear.gif" width=1 height=1></td>
    </tr>
    <tr><Td colspan=3 bgcolor="#99cc99"><img src="img/clear.gif" width=1 height=1></td></tr>
    </table>
</td></tr>
</table>
<!-- END SEARCH -->
