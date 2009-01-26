<? $display_map = $_GET['get_map']; ?>
                    <?php $limit = 3; ?>
			<table border=0 cellpadding=0 cellspacing=0 width="100%">
			<tr><td width="14"></td>
				<td width="148" valign=top>

	
                        <!-- SIGNATURE HOMES -->
                        <?php 	$prop_cat = 'Signature Homes'; 
								$cat = 'signature_home';
								$count_it = 1;
						?>
                        <table border=0 cellpadding=0 cellspacing=0 width="100%">
                        <tr><td colspan=3 height=1><img src="img/clear.gif" width=1 height=8></td></tr>
                        <tr>
                            <td colspan=3>

                                <table border=0 cellpadding=0 cellspacing=0 width="100%">
                                <tr><td valign=top>
                                <?php
                                include "content/xdev_content_home_row.inc";    
                                ?>    
                                </td></tr>
                                </table>

                            </td>
                        </tr>
                        </table>

			</td>
			<td width="14"></td>
			<td width="148" valign=top>
                        <!-- SIGNATURE INNS -->
                        <?php 	$prop_cat = 'Signature Hotels';
								$cat = 'signature_hotel';
								$count_it = 1;
						 ?>
                        <table border=0 cellpadding=0 cellspacing=0 width="100%">
                        <tr><td colspan=3 height=1><img src="img/clear.gif" width=1 height=8></td></tr>
                        <tr>
                            <td colspan=3>

                                <table border=0 cellpadding=0 cellspacing=0 width="100%">
                                <tr><td valign=top>
                                <?php
                                include "content/xdev_content_home_row.inc";
                                ?>    
                                </td></tr>   
                                </table>
    
                            </td>   
                        </tr>   
                        </table>

			</td>
			<td width="14"></td>
			<td width="148" valign=top>
                        <!-- PREMIER HOMES -->
                        <?php 	$prop_cat = 'Premier Homes'; 
								$cat = 'premier_home';
								$count_it = 1;
						?>
                        <table border=0 cellpadding=0 cellspacing=0 width="100%">
                        <tr><td colspan=3 height=1><img src="img/clear.gif" width=1 height=8></td></tr>
                        <tr>    
                            <td colspan=3>

                                <table border=0 cellpadding=0 cellspacing=0 width="100%">
                                <tr><td valign=top>   
                                <?php
                                include "content/xdev_content_home_row.inc";
                                ?>
                                </td></tr>   
                                </table>
    
                            </td>   
                        </tr>   
                        </table>
			</td>
			<td width="14"></td>
			<td width="148" valign=top>

                        <!-- PREMIER INNS -->
                        <?php 	$prop_cat = 'Premier Hotels'; 
								$cat = 'premier_hotel';
								$count_it = 1;
						?>
                        <table border=0 cellpadding=0 cellspacing=0 width="100%">
                        <tr><td colspan=3 height=1><img src="img/clear.gif" width=1 height=8></td></tr>
                        <tr>    
                            <td colspan=3>

                                <table border=0 cellpadding=0 cellspacing=0 width="100%">
                                <tr><td valign=top>   
                                <?php
                                include "content/xdev_content_home_row.inc";
                                ?>
                                </td></tr>       
                                </table>
                            </td>       
                        </tr>       
                        </table>

			
			</td>
			<td width="14"></td>
			</tr>
			<tr><Td colspan=9><br>
			<?php include "../xdev/elements/map_bar.inc"; ?>
			</td></tr>
			</table>
