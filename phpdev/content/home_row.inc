<?php
$sig_homes = mysql_query("select * from property where prop_cat='$prop_cat' order by home_pos asc limit $limit");
$count_it = 0;
while ($sig_home = mysql_fetch_array($sig_homes)) {
    echo "<td width=175 bgcolor=\"#f2f2f2\" valign=top>";
    echo "<table border=0 cellpadding=8 cellspacing=0 width=175>";
    echo "<tr><td align=center class=entry>";
        echo "<span class=entry_title>$sig_home[name]</span><br>";
        echo "<span class=entry_loc>$sig_home[location]</span><Br>";
        echo "<img src=\"img/$sig_home[image_name]\" border=0 vspace=4><br>";
        echo "<span class=entry_desc>$sig_home[teaser]</span><br>";
        echo "<a href=\"listing.php?prop_id=$prop_cat\">More</a>";
        echo "</td></tr>";
    echo "</table>";
    echo "<td>";
    $count_it++;
    if ($count_it < $limit) {
        echo "<td width=3><img src=\"img/clear.gif\" width=3 height=1></td>";
    }
}
?>    

