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
$car_id = $con->real_escape_string($_POST['car_id']);
#endregion

$user_id = getUserId($con, $email, $passhash);
if(($error = getErrorFromObject($user_id)) !== null){
    echo $error;
    mysqli_close($con);
    exit();
}

$deletionResult = deleteCar($con, $user_id, $car_id);
if(($error = getErrorFromObject($deletionResult)) !== null){
    echo $error;
    mysqli_close($con);
    exit();
}

// Send success to app.
$success_return = array(
    "success" => true,
);
echo json_encode($success_return);
mysqli_close($con);
exit();
?>
