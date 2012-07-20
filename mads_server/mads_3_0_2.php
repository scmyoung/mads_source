

<?php

    if (authentication($_POST['id'], $_POST['passwd'])) {
        $mysql_link = mysql_connect('localhost', 'scm', 'scm1234567')
            or die('Cound not connect: ' . mysql_error());
        mysql_select_db('3_0_2') 
            or die('Cound not select DB M_AD_S!');

        // check compaign based on post value
        if (campaign_available($_POST['campaignName'], $_POST['AppID'])) {

            // update record
            mads_status_update_record($_POST['AppID'], $_POST['DeviceID'], $_POST['campaignName'], $_POST['digitalVoucher'], $_POST['stampsCounter'], 
                        $_POST['missed_banner_imp'], $_POST['missed_banner_click'], $_POST['first_missed_time'],
                        $_POST['stamp1_banner_imp'], $_POST['stamp1_banner_click'], $_POST['first_stamp_time'],
                        $_POST['stamp2_banner_imp'], $_POST['stamp2_banner_click'], $_POST['second_stamp_time'], 
                        $_POST['stamp3_banner_imp'], $_POST['stamp3_banner_click'], $_POST['third_stamp_time']);
            
            if (!strcmp($_POST['digitalVoucher'], "YES") || !strcmp($_POST['stamp3_banner_click'], "1")) {
                fetch_one_campaign();
            } else {
                if (!hurdle_changed($_POST['AppID'], $_POST['hurdle'])) {
                    echo ("Same Campaign");
                }
            }

        } else if (!strcmp($_POST['campaignName'], "NoCampaign")){ 
            // check if in the case of re-installation
            if (!mads_status_has_valid_record($_POST['AppID'], $_POST['DeviceID'])) {

                fetch_one_campaign();
            }

        } else {
            fetch_one_campaign();
        }

        // Close mysql
        mysql_close($mysql_link);
    }


    /******************************* functions *************************************/

    function authentication ($username, $passwd)
    {
        if (!strcmp($username,"M.AD.S") &&  
                !strcmp($passwd,"qkrtkdwls78!")) {
            return 1;
        } else {
            return 0;
        }   
    }

    function campaign_available ($campaignName, $appId)
    {
        if (!strcmp($campaignName, "NoCampaign")) 
            return 0;
/*
        $query_campaign_info    = 'SELECT campaign_info.campaign FROM campaign_info,campaign_media WHERE
            NOW() BETWEEN campaign_info.startdate AND campaign_info.enddate and campaign_info.campaign=\'' . $campaignName . 
            '\' and campaign_info.campaign = campaign_media.campaign and campaign_media.media = \'' . $appId . '\'';
            */

        $query_campaign_info    = 'SELECT campaign FROM campaign_info WHERE NOW() BETWEEN startdate AND enddate and campaign=\'' . $campaignName . '\'';
        $result_campaign_info   = mysql_query($query_campaign_info) or die ('campaign_info query faield: - 3 ' . mysql_error());

        $num = mysql_numrows($result_campaign_info);

        if (intval($num) == 1) {
            return 1;
        } else if (intval($num) == 0) {
            return 0;
        }
    }

    function hurdle_changed ($AppID, $hurdle) 
    {
        //TODO: check hurdle and write xml
        $query_campaign_info = 'SELECT * FROM media_info WHERE appid=\'' . $AppID . '\'';
        $result_campaign_info = mysql_query($query_campaign_info) or die ('campaign_info query failed: - 4' . mysql_error());
        $hurdle_new = mysql_result($result_campaign_info, 0, "hurdle");

        if (intval($hurdle) != intval($hurdle_new)) {
            echo ("Hurdle");
            echo ($hurdle_new);
            return 1;
        } else {
            return 0;
        }

        return 0;
    }

    function mads_status_has_valid_record($AppID, $DeviceID) 
    {
        $query_mads_status = 'SELECT * FROM mads_status WHERE appid=\'' . $AppID . '\' and deviceid=\'' . $DeviceID . '\'
            and stamps<>\'3\'';
        $result_mads_status = mysql_query($query_mads_status) or die ('mads_status query faield!' . mysql_error());
        if (intval(mysql_numrows($result_mads_status)) == 1) {
            $campaign = mysql_result($result_mads_status, 0, "campaign");
            if (campaign_available($campaign, $AppID)) {
                //TODO: create xml file

                $query_campaign_info = 'SELECT * FROM campaign_info WHERE campaign=\'' . $campaign . '\'';
                $result_campaign_info = mysql_query($query_campaign_info) or die ('campaign_info query failed! - 1' . mysql_error());

                $digitalVoucher = mysql_result($result_mads_status, 0, "digital_voucher");
                $stamps         = mysql_result($result_mads_status, 0, "stamps");
                $missed_imp     = mysql_result($result_mads_status, 0, "miss_banner_imp");
                $missed_click   = mysql_result($result_mads_status, 0, "miss_banner_click");
                $missed_time    = mysql_result($result_mads_status, 0, "first_missed_time");
                $stamp1_imp     = mysql_result($result_mads_status, 0, "stamp1_banner_imp");
                $stamp1_click   = mysql_result($result_mads_status, 0, "stamp1_banner_click");
                $stamp1_time    = mysql_result($result_mads_status, 0, "first_stamp_time");
                $stamp2_imp     = mysql_result($result_mads_status, 0, "stamp2_banner_imp");
                $stamp2_click   = mysql_result($result_mads_status, 0, "stamp2_banner_click");
                $stamp2_time    = mysql_result($result_mads_status, 0, "second_stamp_time");
                $stamp3_imp     = mysql_result($result_mads_status, 0, "stamp3_banner_imp");
                $stamp3_click   = mysql_result($result_mads_status, 0, "stamp3_banner_click");
                $stamp3_time    = mysql_result($result_mads_status, 0, "third_stamp_time");
                $campaignUrl    = mysql_result($result_campaign_info, 0, "campaignUrl");

                $query_game_info = 'SELECT * FROM media_info WHERE appid=\'' . $AppID. '\'';
                $result_game_info = mysql_query($query_game_info) or die ('campaign_info query failed! - 1' . mysql_error());
                $num = mysql_numrows($result_game_info);
                if (intval($num) == 1) {
                    $hurdle = mysql_result($result_game_info, 0, "hurdle");
                } else {
                    // should never be here
                    $hurdle="0";
                    $campaign="NoCampaign";
                }

                $query_campaign_info = 'SELECT * FROM campaign_info WHERE campaign=\'' . $campaign. '\'';
                $result_campaign_info = mysql_query($query_campaign_info) or die ('campaign_info query failed! - 1' . mysql_error());
                $num = mysql_numrows($result_campaign_info);
                if (intval($num) == 1) {
                    $countryCode= mysql_result($result_campaign_info, 0, "country_code");
                } else {
                    $countryCode= "SG";
                }

                create_xml_file($AppID, $DeviceID, $campaign, $hurdle, $digitalVoucher, $stamps, 
                    $missed_imp, $missed_click, $missed_time, $stamp1_imp, $stamp1_click, $stamp1_time, $stamp2_imp, $stamp2_click, $stamp2_time, 
                    $stamp3_imp, $stamp3_click, $stamp3_time, $campaignUrl, $countryCode);

                echo($campaign);
                return 1;
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    }
    
    function mads_status_update_record($AppID, $DeviceID, $campaignName, $digitalVoucher, $stampsCounter, 
            $missed_imp, $missed_click, $missed_time, $stamp1_imp, $stamp1_click, $stamp1_time, 
            $stamp2_imp, $stamp2_click, $stamp2_time, $stamp3_imp, $stamp3_click, $stamp3_time) 
    {
        $query_mads_status = 'UPDATE mads_status SET digital_voucher=\'' . $digitalVoucher . '\', 
                    miss_banner_imp=\'' . $missed_imp . '\', miss_banner_click=\'' . $missed_click . '\', first_missed_time=\'' . $missed_time . '\',   
                    stamp1_banner_imp=\'' . $stamp1_imp . '\', stamp1_banner_click=\'' . $stamp1_click . '\', first_stamp_time=\'' . $stamp1_time . '\',  
                    stamp2_banner_imp=\'' . $stamp2_imp . '\', stamp2_banner_click=\'' . $stamp2_click . '\', second_stamp_time=\'' . $stamp2_time . '\',  
                    stamp3_banner_imp=\'' . $stamp3_imp . '\', stamp3_banner_click=\'' . $stamp3_click . '\', third_stamp_time=\'' . $stamp3_time . '\', 
                    stamps=\'' . $stampsCounter . '\' WHERE appid=\'' . $AppID . '\' and deviceid=\'' . $DeviceID . '\' 
                    and campaign=\'' . $campaignName . '\'';

        $result_mads_status = mysql_query($query_mads_status) or die ('mads_status update failed!' . mysql_error());
    }

    function mads_status_insert_record($AppID, $DeviceID, $campaignName, $digitalVoucher, $stampsCounter, 
            $missed_imp, $missed_click, $missed_time, $stamp1_imp, $stamp1_click, $stamp1_time, 
            $stamp2_imp, $stamp2_click, $stamp2_time, $stamp3_imp, $stamp3_click, $stamp3_time) 
    {
        $query_mads_status = 'INSERT INTO mads_status (deviceid, appid, campaign, digital_voucher, miss_banner_imp, miss_banner_click, first_missed_time, 
                stamp1_banner_imp, stamp1_banner_click, first_stamp_time, stamp2_banner_imp, stamp2_banner_click, second_stamp_time, 
                stamp3_banner_imp, stamp3_banner_click, third_stamp_time, stamps)
                VALUES (\'' . $DeviceID . '\', \'' . $AppID . '\', \'' . $campaignName . '\', \'' . $digitalVoucher . '\', \'' .
                        $missed_imp . '\', \'' . $missed_click . '\', \'' . $missed_time . '\', \'' . 
                        $stamp1_imp . '\', \'' . $stamp1_click . '\', \'' . $stamp1_time . '\', \'' . 
                        $stamp2_imp . '\', \'' . $stamp2_click . '\', \'' . $stamp2_time . '\', \'' . 
                        $stamp3_imp . '\', \'' . $stamp3_click . '\', \'' . $stamp3_time . '\', \'' . $stampsCounter . '\')';

        $result_mads_status = mysql_query($query_mads_status) or die ('mads_status insert failed!' . mysql_error());

    }

    function fetch_one_campaign()
    {
        // check campaign status and get current_campaign & total campaign number
        $query_sentinel_campaign = 'SELECT * FROM sentinel_campaign';
        $result_sentinel_campaign = mysql_query($query_sentinel_campaign) or die ('sentinel_campaign query failed!');
        $sentinel_campaign = mysql_result($result_sentinel_campaign, 0, "campaign");
        $flag_campaign = $sentinel_campaign;
        $ad_setting = "";
        $ad_count = "";
        $countryCode = "";
        $campaignUrl = "";
        $row = "";
        $isOnlyOneCampaign = 0;

        $campaign = "NoCampaign";

        $query_campaign_info = 'SELECT * FROM campaign_info'; 
        $result_campaign_info = mysql_query($query_campaign_info) or die ('campaign_info query failed!');

        //$row = mysql_fetch_array($result_campaign_info, MYSQL_ASSOC);

        while ($row = mysql_fetch_array($result_campaign_info, MYSQL_ASSOC)) {
            if (!strcmp($row["campaign"], $sentinel_campaign)) 
                break;
        }


        do {
            $row = mysql_fetch_array($result_campaign_info, MYSQL_ASSOC);
            
            if($row) {
                // found target campaign
                $campaign = $row["campaign"];
                            
            } else {
                // fetch first row
                $query_campaign_info = 'SELECT * FROM campaign_info'; 
                $result_campaign_info = mysql_query($query_campaign_info) or die ('campaign_info query failed!');
                $row = mysql_fetch_array($result_campaign_info, MYSQL_ASSOC);
                $campaign = $row["campaign"];

            }

            if (!strcmp($campaign, $flag_campaign)) {

                /*
                // if there's only one option - get campaign name and break!
                $query_count_campaign_by_appid = 'SELECT * FROM campaign_media where media=\'' . $_POST['AppID'] . '\''; 
                $result_campaign_count_campaign_by_appid = mysql_query($query_count_campaign_by_appid) or die ('campaign_media query failed!');
                $num = mysql_numrows($result_campaign_count_campaign_by_appid);

                if (intval($num) == 1) {
                    $row = mysql_fetch_array($result_campaign_info_campaign_media, MYSQL_ASSOC);
                    $target_campaign = $row["campaign"];
                    if (!strcmp ($flag_campaign, $target_campaign)) {
                        $campaign = $target_campaign;
                        $isOnlyOneCampaign = 1;
                    }        
                } else {
                */

                    // all campaigns have been used by this app device combination
                    $campaign="NoCampaign";
                    create_xml_file ($_POST['AppID'], $_POST['DeviceID'], "NoCampaign", "0", "NO", "0",
                        "0", "0", "0000-00-00 00:00:00", "0", "0", "0000-00-00 00:00:00", "0", "0", "0000-00-00 00:00:00", 
                        "0", "0", "0000-00-00 00:00:00", "https://event.secondcommercials.com", "SG");
                    echo($campaign);
                    return;
                //}
            }


            $ad_setting = $row["ad_setting"]; 
            $ad_count = $row["ad_count"];
            if(intval($ad_setting) <= intval($ad_count)) 
                continue;

            $countryCode = $row["country_code"];
            $campaignUrl = $row["campaignUrl"];
            
            $query_campaign_info_campaign_media = 'SELECT campaign_media.campaign FROM campaign_info,campaign_media WHERE campaign_media.campaign=\'' . $campaign . '\' AND 
                campaign_media.media =\'' . $_POST['AppID'] . '\' AND campaign_info.campaign=\'' . $campaign . '\' AND country_code=\'' . $_POST['CountryCode'] . '\' AND 
                 NOW() BETWEEN campaign_info.startdate AND campaign_info.enddate';

            $result_campaign_info_campaign_media   = mysql_query($query_campaign_info_campaign_media) or die ('campaign_info query faield: - 3 ' . mysql_error());
            $num_ci = mysql_numrows($result_campaign_info_campaign_media);

            $mads_count = 0;
            if (intval($num_ci) == 1) {
                $query_mads_status = 'SELECT * FROM mads_status WHERE appid=\'' . $_POST['AppID'] . '\' and deviceid=\'' . $_POST['DeviceID'] . '\'
                    and campaign=\'' . $campaign . '\' and stamps=\'3\'';
                $result_mads_status = mysql_query($query_mads_status) or die ('mads_status query faield!' . mysql_error());
                $mads_count = intval(mysql_numrows($result_mads_status));

                /*
                if ($mads_count == 1 && $isOnlyOneCampaign == 1) {
                    $campaign = "NoCampaign";
                    echo ($campaign);
                    return;
                }
                */

            } else if (intval($num_ci) == 0) {
                /*
                if ($isOnlyOneCampaign == 1) {
                    $campaign = "NoCampaign";
                    echo ($campaign);
                    return;
                }
                */

                $mads_count = 1;
                continue;
            }

        } while ($mads_count == 1);
        
        // Update sentinel_campaign 
        $query_sentinel_campaign = 'UPDATE sentinel_campaign set campaign=\'' . $campaign . '\'';
        $result_sentinel_campaign = mysql_query($query_sentinel_campaign) or die ('sentinel_campaign query failed!');


        // Check if country code is match
        $phoneCountryCode = $_POST['CountryCode'];
        $countryCodeArray = explode(",", $countryCode);

        $isCountryCodeMatch = FALSE;

        for ($i=0; $i<sizeof($countryCodeArray); $i++) {
            if ($phoneCountryCode == $countryCodeArray[$i]) {
                $isCountryCodeMatch = TRUE;
                break;
            }
        }

        if ($isCountryCodeMatch == FALSE) {
            $campaign = "NoCountryCodeMatch";
            echo ($campaign);
            return;
        }

        mads_status_insert_record ($_POST['AppID'], $_POST['DeviceID'], $campaign, "NO", "0",
                "0", "0", "0000-00-00 00:00:00", "0", "0", "0000-00-00 00:00:00", "0", "0", "0000-00-00 00:00:00", "0", "0", "0000-00-00 00:00:00");
        
        $query_game_info = 'SELECT * FROM media_info WHERE appid=\'' . $_POST['AppID'] . '\'';
        $result_game_info = mysql_query($query_game_info) or die ('campaign_info query failed! - 1' . mysql_error());
        $num = mysql_numrows($result_game_info);
        if (intval($num) == 1) {
            $hurdle = mysql_result($result_game_info, 0, "hurdle");
        } else {
            // should never be here
            $hurdle="0";
            $campaign="NoCampaign";
            echo($campaign); return;
        }

        // update campaign count
        $updated_count = intval($ad_count)+1;
        $query_campaign_info = 'UPDATE campaign_info SET ad_count=\'' . $updated_count . '\'
             where campaign=\'' . $campaign . '\''; 
        $result_campaign_info = mysql_query($query_campaign_info) or die ('campaign_info query failed!' . mysql_error());

        // write xml file
        create_xml_file ($_POST['AppID'], $_POST['DeviceID'], $campaign, $hurdle, "NO", "0",
                "0", "0", "0000-00-00 00:00:00", "0", "0", "0000-00-00 00:00:00", "0", "0", "0000-00-00 00:00:00", 
                "0", "0", "0000-00-00 00:00:00", $campaignUrl, $countryCode);


        echo ($campaign);

    }

    function create_xml_file($XmlAppId, $XmlDeviceId, $XmlCampaignName, $XmlHurdlePoint, $XmlDigitalVoucher, $XmlStampsCounter, 
            $XmlMissedImp, $XmlMissedClick, $XmlMissedTime, 
            $XmlStamp1Imp, $XmlStamp1Click, $XmlStamp1Time, $XmlStamp2Imp, $XmlStamp2Click, $XmlStamp2Time, 
            $XmlStamp3Imp, $XmlStamp3Click, $XmlStamp3Time, $CampaignUrl, $CountryCode)
    {
        $xml = new SimpleXMLElement('<xml/>');

            $fb_link        = "";
            $fb_link_desc   = "";
            $fb_ad_desc     = "";
            $fb_thumb_img   = "";
            $fb_post_one    = "";
            $fb_post_two    = "";
            $fb_post_three  = "";
            $tw_post_one    = "";
            $tw_post_two    = ""; 
            $tw_post_three  = "";
            $tw_dm          = "";

        // Get Facebook and Twitter information from Database
        $query_campaign_info    = 'SELECT * FROM campaign_info WHERE campaign=\'' . $XmlCampaignName . '\'';
        $result_campaign_info   = mysql_query($query_campaign_info) or die ('campaign_info query faield: - 3 ' . mysql_error());
        
        $num = mysql_numrows($result_campaign_info);
        if (intval($num) == 1) {
            $fb_link        = mysql_result($result_campaign_info, 0, "fb_link");
            $fb_link_desc   = mysql_result($result_campaign_info, 0, "fb_link_desc");
            $fb_ad_desc     = mysql_result($result_campaign_info, 0, "fb_ad_desc");
            $fb_thumb_img   = mysql_result($result_campaign_info, 0, "fb_thumb_img");
            $fb_post_one    = mysql_result($result_campaign_info, 0, "fb_post_one");
            $fb_post_two    = mysql_result($result_campaign_info, 0, "fb_post_two");
            $fb_post_three  = mysql_result($result_campaign_info, 0, "fb_post_three");
            $tw_post_one    = mysql_result($result_campaign_info, 0, "tw_post_one");
            $tw_post_two    = mysql_result($result_campaign_info, 0, "tw_post_two");
            $tw_post_three  = mysql_result($result_campaign_info, 0, "tw_post_three");
            $tw_dm          = mysql_result($result_campaign_info, 0, "tw_dm");
        } 

        $xml->addChild('AppID', $XmlAppId); 
        $xml->addChild('DeviceID', $XmlDeviceId);
        $xml->addChild('campaign', $XmlCampaignName);
        $xml->addChild('hurdle', $XmlHurdlePoint);
        $xml->addChild('digitalVoucher', $XmlDigitalVoucher);
        $xml->addChild('stamps', $XmlStampsCounter);
        $xml->addChild('missed_banner_imp', $XmlMissedImp);
        $xml->addChild('missed_banner_click', $XmlMissedClick);
        $xml->addChild('first_missed_time', $XmlMissedTime);
        $xml->addChild('stamp1_banner_imp', $XmlStamp1Imp);
        $xml->addChild('stamp1_banner_click', $XmlStamp1Click);
        $xml->addChild('first_stamp_time', $XmlStamp1Time);
        $xml->addChild('stamp2_banner_imp', $XmlStamp2Imp);
        $xml->addChild('stamp2_banner_click', $XmlStamp2Click);
        $xml->addChild('second_stamp_time', $XmlStamp2Time);
        $xml->addChild('stamp3_banner_imp', $XmlStamp3Imp);
        $xml->addChild('stamp3_banner_click', $XmlStamp3Click);
        $xml->addChild('third_stamp_time', $XmlStamp3Time);
        $xml->addChild('campaignUrl', $CampaignUrl);
        $xml->addChild('countryCode', $CountryCode);

        $xml->addChild('hurdle_x_p', "30");
        $xml->addChild('hurdle_y_p', "350");
        $xml->addChild('hurdle_w_p', "260");
        $xml->addChild('hurdle_h_p', "20");

        $xml->addChild('hurdle_x_l', "108");
        $xml->addChild('hurdle_y_l', "240");
        $xml->addChild('hurdle_w_l', "264");
        $xml->addChild('hurdle_h_l', "20");

        /*
        $xml->addChild('hurdle_x', "30");
        $xml->addChild('hurdle_y', "350");
        $xml->addChild('hurdle_w', "260");
        $xml->addChild('hurdle_h', "20");
        */


        // add facebook post contents here
        //$xml->addChild('fb_link', "http://www.facebook.com/pages/Secondcommercials/318165364868518?sk=app_291626854213649");
        $xml->addChild('fb_link', $fb_link);
        $xml->addChild('fb_link_desc', $fb_link_desc); 
        $xml->addChild('fb_ad_desc', $fb_ad_desc);
        $xml->addChild('fb_picture', $fb_thumb_img);

        // Test.Mar Postings
        $xml->addChild('fb_post_one', $fb_post_one);
        $xml->addChild('fb_post_two', $fb_post_two);
        $xml->addChild('fb_post_three', $fb_post_three);
        

        $xml->addChild('tw_post_one', $tw_post_one);
        $xml->addChild('tw_post_two', $tw_post_two);
        $xml->addChild('tw_post_three',$tw_post_three);
        $xml->addChild('tw_dm', $tw_dm);
        

        $xmlInfoFile = getcwd() . "/../campaign/" . $XmlCampaignName . "/scmAdInfo.xml";
        $fh = fopen($xmlInfoFile, 'w')or die("Can't open file");
        fwrite($fh, $xml->asXml());
        fclose($fh);
    }

?>




