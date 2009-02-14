            <tr>
                <?php if (in_array('address', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
                <td class="<?php echo "$check_class"; ?>" nowrap><?php if (($fhh == 1) || ($bkt == 1)) { echo "*"; }?>Mailing Address:</td>
                <td class="entry_desc"><input type="text" name="address"  class=full value="<?php echo "$address"; ?>"></td>
            </tr>
            <tr><?php if (in_array('city', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
                <td class="<?php echo "$check_class"; ?>"><?php if (($fhh == 1) || ($bkt == 1)) { echo "*"; }?>City:</td>

                <td class="entry_desc"><input type="text" name="city"  class=full value="<?php echo "$city"; ?>"></td>
            </tr>
            <tr><?php if (in_array('state', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
                <td class="<?php echo "$check_class"; ?>"><?php if (($fhh == 1) || ($bkt == 1)) { echo "*"; }?>State:</td><td class="entry_desc">
                    <select name="state">
                    <option value="">Select One</option>

                    <?php
                    foreach ($states_array AS $state_val) {
                        echo "<option value=\"$state_val\"";
                        if ($state_val == $state) {
                            echo " SELECTED";
                        }
                        echo ">$state_val</option>";
                        }
                    ?>


                    </select>

                </td>
            </tr>

            <tr><?php if (in_array('zip', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
                <td class="<?php echo "$check_class"; ?>"><?php if (($fhh == 1) || ($bkt == 1)) { echo "*"; }?>Zip/Postal Code:</td>
                <td class="entry_desc"><input type="text" name="zip" size="7" value="<?php echo "$zip"; ?>" maxlength=5></td>
            </tr>

            <tr><?php if (in_array('country', $reds)) { $check_class='entry_red'; } else { $check_class = 'entry_desc';} ?>
                <td class="<?php echo "$check_class"; ?>"><?php if (($fhh == 1) || ($bkt == 1)) { echo "*"; }?>Country</td><td class="entry_desc">

                        <select name="country">
                        <option value="" selected>Select a Country</option>
                        <?php

                            foreach ($country_array as $country_val) {

                                echo "<option value=\"$country_val\"";
                                if ($country_val == $country) {
                                    echo " SELECTED";
                                }
                                echo ">$country_val</option>";
                            }


                        ?>


                        </select>
                </td>
            </tr>
