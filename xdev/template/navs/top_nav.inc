<?
$this_page = basename($_SERVER['REQUEST_URI']);
if (strpos($this_page, "?") !== false) $this_page = reset(explode("?", $this_page));
?>

<table border=0 cellpadding=0 width="1000" cellspacing=0>
<tr>
	<? if ($this_page == 'index.php') { ?>
	<td><a href="index.php"><img src="img/home_on.gif" name=home border=0></a></td>
	<? } else { ?>
	<td><a href="index.php" onMouseOver="document.images.home.src='img/home_on.gif'" onMouseOut="document.images.home.src='img/home_off.gif'"><img src="img/home_off.gif" border=0 name=home></a></td>
	<? } ?>
	<? if ($this_page == 'contact_us.php') { ?>
	<td><a href="contact_us.php"><img src="img/contact_us_on.gif" name=contact border=0></a></td>
	<? } else { ?>
	<td><a href="contact_us.php" onMouseOver="document.images.contact.src='img/contact_us_on.gif'" onMouseOut="document.images.contact.src='img/contact_us_off.gif'"><img src="img/contact_us_off.gif" border=0 name=contact></a></td>
	<? } ?>
	<? if ($this_page == 'about_us.php') { ?>	
	<td><a href="about_us.php"><img src="img/about_us_on.gif" name=about border=0></a></td>
	<? } else { ?>
	<td><a href="about_us.php" onMouseOver="document.images.about.src='img/about_us_on.gif'" onMouseOut="document.images.about.src='img/about_us_off.gif'"><img src="img/about_us_off.gif" border=0 name=about></a></td>
	<? } ?>
	<? if ($this_page == 'philanthropy.php') { ?>
	<td><a href="philanthropy.php"><img src="img/philanthropy_on.gif" name=philanthropy border=0></a></td>
	<? } else { ?>
	<td><a href="philanthropy.php" onMouseOver="document.images.philanthropy.src='img/philanthropy_on.gif'" onMouseOut="document.images.philanthropy.src='img/philanthropy_off.gif'"><img src="img/philanthropy_off.gif" border=0 name=philanthropy></a></td>
	<? } ?>
	<? if ($this_page == 'love_life.php') { ?>
	<td><a href="love_life.php"><img src="img/love_life_on.gif" name=love border=0></a></td>
	<? } else { ?>
	<td><a href="love_life.php" onMouseOver="document.images.love.src='img/love_life_on.gif'" onMouseOut="document.images.love.src='img/love_life_off.gif'"><img src="img/love_life_off.gif" border=0 name=love></a></td>
	<? } ?>
	<? if ($this_page == 'success.php') { ?>
	<td><a href="success.php"><img src="img/customer_success_on.gif" name=success border=0></a></td>
	<? } else { ?>
	<td><a href="success.php" onMouseOver="document.images.success.src='img/customer_success_on.gif'" onMouseOut="document.images.success.src='img/customer_success_off.gif'"><img src="img/customer_success_off.gif" border=0 name=success></a></td>
	<? } ?>
	<? if ($this_page == 'solutions.php') { ?>
	<td><a href="solutions.php"><img src="img/solutions_on.gif" name=solutions border=0></a></td>
	<? } else { ?>
	<td><a href="solutions.php" onMouseOver="document.images.solutions.src='img/solutions_on.gif'" onMouseOut="document.images.solutions.src='img/solutions_off.gif'"><img src="img/solutions_off.gif" border=0 name=solutions></a></td>
	<? } ?>
</tr>
</table>
