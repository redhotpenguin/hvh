<?php
$get_map = $_GET['map'];

if ($get_map == 'na') {
	$fetch_me_div = 'North_America_map_div';	
    $fetch_me_script = 'North_America_map_script';

}
if ($get_map == 'ha') {
    $fetch_me_div = 'Hawaii_map_div';
	$fetch_me_script = 'Hawaii_map_script';
}
if ($get_map == 'ca') {
    $fetch_me_div = 'Caribbean_map_div';
    $fetch_me_script = 'Caribbean_map_script';

}
if ($get_map == 'ak') {
    $fetch_me_div = 'Alaska_map_div';
    $fetch_me_script = 'Alaska_map_script';

}
echo "<table border=0 cellpadding=30 cellspacing=0 width=\"100%\">";
echo "<tr><td class=reg_copy><h2>Search Using Google Maps</h2>";
echo "To switch between regional maps, click on the gray tabs at the top of the map. The Current map is highlighted with a blue tab. To preview a property, click on the blue palm tree for that individual property. If you would like to view a detailed description of the property, click on the blue underlined title in preview window.<Br><Br>";
echo "<table border=0 cellpadding=2 cellspacing=0 width=\"100%\">";
echo "<tr>";
echo "<td bgcolor=white width=1><img src=\"img/clear.gif\" width=1 height=1></td>";
$what_map = $_GET['map'];
if ($what_map == 'na') { $bgc = '496b97'; $fc = 'ffffff'; } else { $bgc = 'e2e2e1'; $fc = '000000'; }
echo "<td width=\"25%\" bgcolor=\"#$bgc\" align=center><a href=\"map.php?map=na\"><font color=\"$fc\">North America</font></a></td>";
echo "<td bgcolor=white width=1><img src=\"img/clear.gif\" width=1 height=1></td>";
if ($what_map == 'ha') { $bgc = '496b97'; $fc = 'ffffff'; } else { $bgc = 'e2e2e1'; $fc = '000000'; }
echo "<td width=\"25%\" align=center bgcolor=\"#$bgc\"><a href=\"map.php?map=ha\"><font color=\"$fc\">Hawaii</font></a></td>";
echo "<td bgcolor=white width=1><img src=\"img/clear.gif\" width=1 height=1></td>";
if ($what_map == 'ca') { $bgc = '496b97'; $fc = 'ffffff'; } else { $bgc = 'e2e2e1'; $fc = '000000'; }
echo "<td width=\"25%\" align=center bgcolor=\"#$bgc\"><a href=\"map.php?map=ca\"><font color=\"$fc\">Carribean</font></a></td>";
echo "<td bgcolor=white width=1><img src=\"img/clear.gif\" width=1 height=1></td>";
if ($what_map == 'ak') { $bgc = '496b97'; $fc = 'ffffff'; } else { $bgc = 'e2e2e1'; $fc = '000000'; }
echo "<td width=\"25%\" align=center bgcolor=\"#$bgc\"><a href=\"map.php?map=ak\"><font color=\"$fc\">Alaska</font></a></td>";
echo "<td bgcolor=white width=1><img src=\"img/clear.gif\" width=1 height=1></td>";
echo "</tr>";
echo "</table>";

echo "<table border=0 cellpadding=0 cellspacing=0 width=\"100%\">";
echo "<tr><td bgcolor=\"#496b97\" colspan=3><img src=\"img/clear.gif\" width=1 height=2></td></tr>";
echo "<tr><td width=1 bgcolor=\"#496b97\"><img src=\"img/clear.gif\" width=1 height=1></td>";
echo "<td valign=top>";
include "maps/$fetch_me_div.inc";
include "maps/$fetch_me_script.inc";
echo "</td>";
echo "<td width=1 bgcolor=\"#496b97\"><img src=\"img/clear.gif\" width=1 height=1></td>";
echo "</tr>";
echo "<tr><td colspan=3 width=1 bgcolor=\"#496b97\"><img src=\"img/clear.gif\" width=1 height=1></td></tr>";
echo "</table>";
echo "</td></tr></table>";
?>

