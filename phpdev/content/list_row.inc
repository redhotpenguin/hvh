<?php
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
    } 
    if ($_POST['city']) {
        $param = 'city';
        $value = $_POST['city'];
        $show_city = $value;
    }
}

$props = mysql_query("select * from property where $param='$value' order by prop_cat, name  asc");
$count_it = 0;

while ($home = mysql_fetch_array($props)) {

    $start_type = "$home[prop_cat]";
    
    echo "<table border=0 cellpadding=0 cellspacing=0 width=\"100%\">";

    if ($start_type != $end_type) {
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
        echo "</tr>";
        echo "<tr><td colspan=2 height=1><img src=\"img/clear.gif\" width=1 height=1></td></tr>";
    }
    
    echo "<tr><td colspan=2>";
    echo "<table border=0 cellpadding=0 cellspacing=0 width=\"100%\">";
    echo "<tr>";
    
    echo "<td width=175 bgcolor=\"#f2f2f2\" valign=top>";
    echo "<table border=0 cellpadding=8 cellspacing=0 width=\"100%\">";
    echo "<tr>";
    echo "<td class=entry valign=top>";
    echo "<span class=entry_title>$home[name]</span> - ";
    echo "<span class=entry_loc>$home[location]</span><Br>";
    echo "<span class=entry_desc>$home[teaser]</span><br>";
    echo "<a href=\"listing.php?prop_id=$home[0]\">More</a>";
    echo "</td>";
    echo "<td valign=top><img src=\"img/$home[image_name]\" border=0 vspace=4></td>";
    echo "</tr>";
    echo "</table>";
    echo "<td>";
    $count_it++;
    echo "</tr>";
    echo "</table>";
    echo "<tr><td colspan=2 height=1 bgcolor=\"#cccccc\"><img src=\"img/clear.gif\" width=1 height=1></td></tr>";
    
    $end_type = "$home[prop_cat]"; 
    
    echo "</td></tr>";
    echo "</table>";


}    
    
    
    ?>    

