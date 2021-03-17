<?php
function checkAppVersion($_POST){
    $IOS_LATEST_VER = "1.0";
    $AND_LATEST_VER = "1.0";

    $ios_app_ver = (isset($_POST['ios_app_ver']) ? $_POST['ios_app_ver'] : "not found");
    $and_app_ver = (isset($_POST['and_app_ver']) ? $_POST['and_app_ver'] : "not found");

    if (($ios_app_ver != $IOS_LATEST_VER) && ($and_app_ver != $AND_LATEST_VER)){
        return false;
    }
    else{
        return true;
    }
}