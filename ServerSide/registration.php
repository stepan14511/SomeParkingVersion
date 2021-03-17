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
$phone = $con->real_escape_string($_POST['phone']);
$surname = $con->real_escape_string($_POST['surname']);
$name = $con->real_escape_string($_POST['name']);
$patronymic = null;
if (isset($_POST['patronymic'])){
    $patronymic = $con->real_escape_string($_POST['patronymic']);
}
#endregion

$registrationResult = accountRegistration($con, $email, $passhash, $phone, $surname, $name, $patronymic);
if(($error = getErrorFromObject($registrationResult)) !== null){
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
?>
