<?php
require_once("MyFunctions/FunctionsForSQL.php");
require_once("MyFunctions/Error.php");
require_once("MyFunctions/CheckAppVersion.php");

if(!checkAppVersion($_POST)){
    echo returnError(0);
    exit();
}

$con = getConnectionToMySql();
if($con === null){
    echo returnError(1);
    mysqli_close($con);
    exit();
}

#region Get data from device.
$email = $con->real_escape_string($_POST['email']);
$passhash = strtolower($con->real_escape_string($_POST['passhash']));
$car_id = (int)$_POST['car_id'];
$new_lot = isset($_POST['new_lot']) ? $_POST['new_lot'] : null;
#endregion

$user_id = getUserId($con, $email, $passhash);
if(($error = getErrorFromObject($user_id)) !== null){
    echo $error;
    mysqli_close($con);
    exit();
}

$updateResult = updateParkingLot($con, $user_id, $car_id, $new_lot);
if(($error = getErrorFromObject($updateResult)) !== null){
    echo $error;
    mysqli_close($con);
    exit();
}

$full_account = getFullAccount($con, $email, $passhash);
if(($error = getErrorFromObject($full_account)) !== null){
    echo $error;
    mysqli_close($con);
    exit();
}

echo json_encode($full_account);
mysqli_close($con);
exit();
