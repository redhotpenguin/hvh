                    <?php 
			if (isset($_GET['prop_cat'])) {
                	        $prop_cat = $_GET['prop_cat'];
			}
			if (isset($_GET['search_cat'])) {
				$search_cat = $_GET['search_cat'];
			}
                    ?>
                        
                        <!-- DISPLAY THE SEARCH RESULTS -->
                                <?php
                                include "content/xdev_content_list_row.inc";    
                                ?>    
