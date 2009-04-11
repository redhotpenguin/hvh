<?php
// --- SET THIS VARIABLE FOR THE PAGE TITLE --- //
$page_title = 'Hideaway Vacation Homes - Property Listing';
$left_cols = 'listing_detail';
$sub_nav = 'listing_sub';
$content = '../phpdev/xdev_content_listing';

$content =
'<div id="cse-search-results"></div><script type="text/javascript"> var googleSearchIframeName = "cse-search-results";  var googleSearchFormName = "cse-search-box";  var googleSearchFrameWidth = 600;  var googleSearchDomain = "www.google.com";  var googleSearchPath = "/cse";</script><script type="text/javascript" src="http://www.google.com/afsonline/show_afs_search.js"></script>';

$banner = 'main_image.inc';
// --- HEADER = TOP NAV + LOGO - OPENS ALL PAGES --- //
// --- COLUMN_SPACER IS THE 15 PIXEL SPACER IN BETWEEN COLUMNS --- //
// --- FOOTER IS THE PHILANTHROPY AND MOUNTAIN IMAGE - CLOSES ALL PAGES --- //
// --- ANYTHING CALLED INBETWEEN HEADER AND FOOTER IS THE MAIN BODY OF THE PAGE --- //
include "template/page.inc";

?>
