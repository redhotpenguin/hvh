<?php
// --- SET THIS VARIABLE FOR THE PAGE TITLE --- //
$page_title = 'Hideaway Vacation Homes';

// --- HEADER = TOP NAV + LOGO - OPENS ALL PAGES --- //
// --- COLUMN_SPACER IS THE 15 PIXEL SPACER IN BETWEEN COLUMNS --- //
// --- FOOTER IS THE PHILANTHROPY AND MOUNTAIN IMAGE - CLOSES ALL PAGES --- //
// --- ANYTHING CALLED INBETWEEN HEADER AND FOOTER IS THE MAIN BODY OF THE PAGE --- //

include "template/header.inc";
include "left_columns/home.inc";
include "template/column_spacer.inc";
include "content/list.inc";
include "template/footer.inc";
?>
