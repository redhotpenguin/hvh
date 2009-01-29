<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 TRANSITIONAL//EN">
<html>
<head>
<title><?php echo "$page_title" ?></title>
<link rel=stylesheet type="text/css" href="css/main.css">
<?php
include "elements/maps/North_America_head.inc";
$my_page = basename($_SERVER['REQUEST_URI']);
if (strpos($my_page, "?") !== false) $my_page = reset(explode("?", $my_page));

?>
</head>

<body rightmargin='0' leftmargin='0' topmargin='0' bottommargin='0' marginheight='0' marginwidth='0' background="img/bg.gif">
<script type="text/javascript" src="js/wz_tooltip.js"></script>
<script type="text/javascript" src="js/tip_balloon.js"></script>

<!-- START CENTERING TABLE -->
<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr><td align=center valign=top><br>
    <!-- START HEADER -->
    <table border=0 cellpadding=0 cellspacing=0 width=1000>
    <tr>
        <td width=1000 bgcolor=white>
            <!-- BEGIN TOP NAV -->
            <table border=0 cellpadding=0 cellspacing=0 width=1000>
            <Tr><td><img src="img/hvh_top.gif">
            </tr>
			<Tr><Td><?php include "template/navs/top_nav.inc"; ?></td></tr>
<?php if ($my_page == 'philanthropy.php') { ?>
			<tr><Td><a href="index.php"><img src="img/top_mountain_banner.gif" border=0></a></td></tr>
<?php } ?> 

<?php if ($my_page == 'index.php') { ?>
<tr><Td><a href="index.php"><img src="img/hvh_logo_blue.gif" border=0></a></td></tr>
<?php } ?>

<?php if ($my_page == 'index2.php') { ?>
<tr><Td valign=top>
<script language="JavaScript" type="text/javascript">
	AC_FL_RunContent(
		'codebase', 'http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=10,0,0,0',
		'width', '1000',
		'height', '150',
		'src', 'hvhbanner',
		'quality', 'high',
		'pluginspage', 'http://www.adobe.com/go/getflashplayer',
		'align', 'middle',
		'play', 'true',
		'loop', 'true',
		'scale', 'showall',
		'wmode', 'window',
		'devicefont', 'false',
		'id', 'hvhbanner',
		'bgcolor', '#ffffff',
		'name', 'hvhbanner',
		'menu', 'true',
		'allowFullScreen', 'false',
		'allowScriptAccess','sameDomain',
		'movie', 'hvhbanner',
		'salign', ''
		); //end AC code
</script>
	<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=10,0,0,0" width="1000" height="150" id="hvhbanner" align="middle">
	<param name="allowScriptAccess" value="sameDomain" />
	<param name="allowFullScreen" value="false" />
	<param name="movie" value="swf/hvhbanner.swf" />
	<param name="quality" value="high" /><param name="bgcolor" value="#ffffff" />	
	<embed src="swf/hvhbanner.swf" loop='False' quality="high" bgcolor="#ffffff" width="1000" height="150" name="hvhbanner" align="middle" allowScriptAccess="sameDomain" allowFullScreen="false" type="application/x-shockwave-flash" pluginspage="http://www.adobe.com/go/getflashplayer" />
	</object>

</td></tr>
<?php } ?>


<?php if (($my_page != 'philanthropy.php') && ($my_page != 'index.php') && ($my_page != 'index2.php')) { ?>
            <tr><Td><a href="index.php"><img src="img/hvh_logo_blue.gif" border=0></a></td></tr>
<?php } ?>
			</table>
		</td>
	</tr>
	</table>
	<table border=0 cellpadding=0 cellspacing=0 width=1000>
	<tr><td width=1 bgcolor="#0166a9"><img src="img/clear.gif" width=1 height=1></td>
		<td width=250 valign=top bgcolor="#ffffff">
			<table border=0 cellpadding=0 cellspacing=0 width="100%" id=fullheight>
			<tr><td valign=top>
			<table border=0 cellpadding=0 cellspacing=0 width=296>
			<Tr><td height=35 bgcolor="#ffffff" colspan=3 valign=top>
				<table border=0 cellpadding=0 cellspacing=0 widht="100%">
				<tr><td width=10 bgcolor="#ff0000"><img src="img/clear.gif" width=12 height=1></td>

					<? if ($my_page != 'index.php') { ?>	
					<td bgcolor="#ffffff" height=29><img src="img/fad.gif" border=0><br><img src="img/clear.gif" width=1 height=1></td>
					<? } else { ?>
					<td bgcolor="#ffffff">
	<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=10,0,0,0" width="283" height="26" id="search" align="middle">
	<param name="allowScriptAccess" value="sameDomain" />
	<param name="allowFullScreen" value="false" />
	<param name="movie" value="swf/search.swf" /><param name="quality" value="high" /><param name="bgcolor" value="#ffffff" />	
	<embed src="swf/search.swf" loop='False' quality="high" bgcolor="#ffffff" width="283" height="26" name="search" align="middle" allowScriptAccess="sameDomain" allowFullScreen="false" type="application/x-shockwave-flash" pluginspage="http://www.adobe.com/go/getflashplayer" />
	</object>
					</td>
					<? } ?>
				</tr>
				<tr><td width=10 bgcolor="#ff0000"><img src="img/clear.gif" width=12 height=1></td><Td height=1 bgcolor="#ffffff"><img src="img/clear.gif" width=1 height=3></td></tr>
				<tr><Td colspan=2 height=1 bgcolor="red"><img src="img/clear.gif" width=1 height=1></td></tr>
				<tr><Td colspan=2 height=1 bgcolor="#ffffff"><img src="img/clear.gif" width=1 height=9></td></tr>
				</table>


			</td></tr>
			<tr>
				<td bgcolor="#ffffff">


				<!-- SEARCH IS ON EVERY PAGE -->
				<?php include "elements/search.inc"; ?>


				</td>
			</tr>
			</table>
			<!-- LEFT PAGE ELEMENTS LISTED UNDERNEATH SEARCH BOX -->
			<?php include "left_columns/$left_cols.inc";  ?>	
			</td></tr>
			</table>

		</td>
		<td width=1 bgcolor="#cccccc"><img src="img/clear.gif" width=1 height=1></td>
		<td valign=top>
			<table border=0 cellpadding=0 cellspacing=0 width="100%">
<!--			<tr><Td bgcolor="#508fc4" height=42>
		
			<?php // include "template/navs/blank.inc"; ?>

			</td></tr>-->
			<tr><td valign=top bgcolor="#ffffff">
			<!-- WHAT CONTENT DO WE PASS -->
			<?php include "$content.inc"; ?>
			
			<!-- SHOULD BE -->
			<?php //include "content/$content.inc"; ?>
			</td></tr>
			</table>
		</td>
		<td width=1 bgcolor="#0166a9"><img src="img/clear.gif" width=1 height=1></td>
		
	</tr>
	<tr><td colspan=4>
<? //include "elements/map_bar.inc"; ?>

	</td></tr>
	<tr><td colspan=4 height=1 bgcolor="#0166a9"><img src="img/clear.gif" width=1 height=1></td></tr>
	<tr><td colspan=4 align=center class=footer>Copyright &copy; 2009 Hideaway Vacation Homes, Inc. All rights reserved.&nbsp;&nbsp;|&nbsp;&nbsp;Privacy Policy&nbsp;&nbsp;|&nbsp;&nbsp;Terms of Use&nbsp;&nbsp;|&nbsp;&nbsp;<a href="mailto:thomas@hvh.com">thomas@hvh.com</a>&nbsp;&nbsp;|&nbsp;&nbsp;888-858-6562</td></tr>
	</table>



	</td></tr>
	</table>
</body>
</html>
