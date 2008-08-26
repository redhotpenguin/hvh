<?php
$sig_homes = mysql_query("select * from property where prop_cat='$prop_cat' order by home_pos asc limit $limit");
$count_it = 0;
while ($sig_home = mysql_fetch_array($sig_homes)) {
    echo "<td width=175 bgcolor=\"#f2f2f2\" valign=top>";
    echo "<table border=0 cellpadding=8 cellspacing=0 width=175>";
    echo "<tr><td align=center class=entry>";
        echo "<span class=entry_title><a href=\"listing.php?prop_id=$sig_home[id]\" class=home_row>$sig_home[name]</a></span><br>";
        echo "<span class=entry_loc><a href=\"listing.php?prop_id=$sig_home[id]\" class=home_row>$sig_home[location]</a></span><Br>";
        echo "<a href=\"listing.php?prop_id=$sig_home[id]\"><img src=\"img/$sig_home[image_name]\" border=0 vspace=4></a><br>";
        echo "<span class=entry_desc>$sig_home[teaser]</span><br>";
        echo "<a href=\"listing.php?prop_id=$sig_home[id]\" class=ulink>More Details</a>";
        echo "</td></tr>";
    echo "</table>";
    echo "<td>";
    $count_it++;
    if ($count_it < $limit) {
        echo "<td width=3><img src=\"img/clear.gif\" width=3 height=1></td>";
    }
}
?>    

