<?php
$prop_id = $_GET['prop_id'];
$props = mysql_query("select * from property where id='$prop_id' limit 1");

while ($home = mysql_fetch_array($props)) {

    
    echo "<table border=0 cellpadding=0 align=center cellspacing=0 width=\"100%\">";

        echo "<tr class=list_sh>";
        echo "<td class=list_sh>$home[prop_cat]";
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
    
    echo "<tr><td colspan=3>";
    echo "<table border=0 cellpadding=0 cellspacing=0 width=\"100%\">";
    echo "<tr>";
    
    echo "<td width=175 bgcolor=\"#f2f2f2\" valign=top>";
    echo "<table border=0 cellpadding=8 cellspacing=0 width=\"100%\">";
    echo "<tr>";
    echo "<td class=entry valign=top>";
    echo "<span class=entry_title><a href=\"listing.php?prop_id=$home[0]\" class=home_row>$home[name]</a></span> - ";
    echo "<span class=entry_loc><a href=\"listing.php?prop_id=$home[0]\" class=home_row>$home[location]</span></a><Br>";
    echo "<span class=entry_desc>$home[teaser]</span><br>";
    echo "<a href=\"listing.php?prop_id=$home[0]\" class=ulink>More Details</a>";
    echo "</td>";
    echo "<td valign=top><a href=\"listing.php?prop_id=$home[0]\" class=home_row><img src=\"img/$home[image_name]\" border=0 vspace=4></a></td>";
    echo "</tr>";
    echo "</table>";
    echo "<td>";
    $count_it++;
    echo "</tr>";
    echo "</table>";
    echo "<tr><td colspan=3 height=1 bgcolor=\"#cccccc\"><img src=\"img/clear.gif\" width=1 height=1></td></tr>";
    
    $end_type = "$home[prop_cat]"; 
    
    echo "</td></tr>";
    echo "</table>";


}    
    
    
    ?>    

