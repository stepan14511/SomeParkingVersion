<?php
function checkAppVersion($post_data){
    $IOS_LATEST_VER = "1.0";
    $AND_LATEST_VER = "1.0";

    $ios_app_ver = (isset($post_data['ios_app_ver']) ? $post_data['ios_app_ver'] : "not found");
    $and_app_ver = (isset($post_data['and_app_ver']) ? $post_data['and_app_ver'] : "not found");

    if (($ios_app_ver != $IOS_LATEST_VER) && ($and_app_ver != $AND_LATEST_VER)){
        return false;
    }
    else{
        return true;
    }
}