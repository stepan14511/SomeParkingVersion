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
$new_surname = $con->real_escape_string($_POST['surname']);
$new_name = $con->real_escape_string($_POST['name']);
$new_patronymic = null;
if (isset($_POST['patronymic'])){
    $new_patronymic = $con->real_escape_string($_POST['patronymic']);
}
#endregion

$user_id = getUserId($con, $email, $passhash);
if(($error = getErrorFromObject($user_id)) !== null){
    echo $error;
    mysqli_close($con);
    exit();
}

$updateResult = updateFIO($con, $user_id, $new_surname, $new_name, $new_patronymic);
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
