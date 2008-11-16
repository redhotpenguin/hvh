                    <?php $limit = 3; ?>
                    <td width=550 valign=top>
                        <table border=0 cellpadding=0 cellspacing=0 width="100%">
                        <tr><td img src="img/clear.gif" width=1 height=1></td></tr>
                        </table>
						<?php include "elements/owners_top.inc" ?>
						<table border=0 cellpadding=0 cellspacing=0 width="100%">
                        <tr><td img src="img/clear.gif" width=1 height=32></td></tr>
                        </table> 
                        <!-- SIGNATURE HOMES -->
                        <?php 	$prop_cat = 'Signature Homes'; 
								$cat = 'signature_home';
								$count_it = 1;
						?>
                        <table border=0 cellpadding=0 cellspacing=0 width="100%">
                        <tr class=list_sh>
                            <td class=list_sh><?php echo "<a class=cat_header href=\"list.php?param=prop_cat&value=$prop_cat&search_cat=all_signature_home\">"; ?><?php echo "$prop_cat"; ?><?php echo "</a>"; ?></td>
                            <td class=list_sh><img src="img/clear.gif" width=1 height=1></td>
                            <td align=right class=list_sh><?php echo "<a class=cat_header href=\"list.php?param=prop_cat&value=$prop_cat&search_cat=all_signature_home\">"; ?>View All</a></td>
                        </tr>
                        <tr><td colspan=3 height=1><img src="img/clear.gif" width=1 height=1></td></tr>
                        <tr>
                            <td colspan=3>

                                <table border=0 cellpadding=0 cellspacing=0 width="100%">
                                <tr>
                                <?php
                                include "content/home_row.inc";    
                                ?>    
                                </tr>
                                </table>

                            </td>
                        </tr>
                        </table>

                        <img src="img/clear.gif" width=1 height=2><br>

                        <!-- SIGNATURE INNS -->
                        <?php 	$prop_cat = 'Signature Hotels';
								$cat = 'signature_hotel';
								$count_it = 1;
						 ?>
                        <table border=0 cellpadding=0 cellspacing=0 width="100%">
                        <table border=0 cellpadding=0 cellspacing=0 width="100%">
                        <tr class=list_si>
                            <td class=list_si><?php echo "<a class=cat_header href=\"list.php?param=prop_cat&value=$prop_cat&search_cat=all_signature_hotel\">"; ?><?php echo "$prop_cat"; ?><?php echo "</a>"; ?></td>
                            <td class=list_si><img src="img/clear.gif" width=1 height=1></td>
                            <td align=right class=list_si><?php echo "<a class=cat_header href=\"list.php?param=prop_cat&value=$prop_cat&search_cat=all_signature_hotel\">"; ?>View All</a></td>
                        </tr>
                        <tr><td colspan=3 height=1><img src="img/clear.gif" width=1 height=1></td></tr>
                        <tr>
                            <td colspan=3>

                                <table border=0 cellpadding=0 cellspacing=0 width="100%">
                                <tr>
                                <?php
                                include "content/home_row.inc";
                                ?>    
                                </tr>   
                                </table>
    
                            </td>   
                        </tr>   
                        </table>

                        <img src="img/clear.gif" width=1 height=2><br>

                        <!-- PREMIER HOMES -->
                        <?php 	$prop_cat = 'Premier Homes'; 
								$cat = 'premier_home';
								$count_it = 1;
						?>
                        <table border=0 cellpadding=0 cellspacing=0 width="100%">
                        <tr class=list_ph>
                            <td class=list_ph><?php echo "<a class=cat_header href=\"list.php?param=prop_cat&value=$prop_cat&search_cat=all_premier_home\">"; ?><?php echo "$prop_cat"; ?><?php echo "</a>"; ?></td>
                            <td class=list_ph><img src="img/clear.gif" width=1 height=1></td>
                            <td align=right class=list_ph><?php echo "<a class=cat_header href=\"list.php?param=prop_cat&value=$prop_cat&search_cat=all_premier_home\">"; ?>View All</a></td>
                        </tr>
                        <tr><td colspan=3 height=1><img src="img/clear.gif" width=1 height=1></td></tr>
                        <tr>    
                            <td colspan=3>

                                <table border=0 cellpadding=0 cellspacing=0 width="100%">
                                <tr>    
                                <?php
                                include "content/home_row.inc";
                                ?>
                                </tr>   
                                </table>
    
                            </td>   
                        </tr>   
                        </table>

                        <img src="img/clear.gif" width=1 height=2><br>

                        <!-- PREMIER INNS -->
                        <?php 	$prop_cat = 'Premier Hotels'; 
								$cat = 'premier_hotel';
								$count_it = 1;
						?>
                        <table border=0 cellpadding=0 cellspacing=0 width="100%">
                        <tr class=list_pi>
                            <td class=list_pi><?php echo "<a class=cat_header href=\"list.php?param=prop_cat&value=$prop_cat&search_cat=all_premier_hotel\">"; ?><?php echo "$prop_cat"; ?><?php echo "</a>"; ?></td>
                            <td class=list_pi><img src="img/clear.gif" width=1 height=1></td>
                            <td align=right class=list_pi><?php echo "<a class=cat_header href=\"list.php?param=prop_cat&value=$prop_cat&search_cat=all_premier_hotel\">"; ?>View All</a></td>
                        </tr>
                        <tr><td colspan=3 height=1><img src="img/clear.gif" width=1 height=1></td></tr>
                        <tr>    
                            <td colspan=3>

                                <table border=0 cellpadding=0 cellspacing=0 width="100%">
                                <tr>    
                                <?php
                                include "content/home_row.inc";
                                ?>
                                </tr>       
                                </table>
                            </td>       
                        </tr>       
                        </table>


                    </td>       
