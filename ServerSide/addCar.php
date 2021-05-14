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
$plates = $con->real_escape_string($_POST['plates']);
$main_card = (int)$_POST['main_card'];
$additional_card = (int)$_POST['additional_card'];
#endregion

$user_id = getUserId($con, $email, $passhash);
if(($error = getErrorFromObject($user_id)) !== null){
    echo $error;
    mysqli_close($con);
    exit();
}

$car_id = addCar($con, $user_id, $plates, $main_card, $additional_card);
if(($error = getErrorFromObject($car_id)) !== null){
    echo $error;
    mysqli_close($con);
    exit();
}

updateTariff($con, $user_id, $car_id, 1);

// Send data to app.
$success_return = array(
    "success" => true,
);
echo json_encode($success_return);
mysqli_close($con);
exit();
?>
