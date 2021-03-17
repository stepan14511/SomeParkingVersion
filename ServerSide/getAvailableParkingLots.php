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

$lots = getAvailableParkingLots($con);
if(($error = getErrorFromObject($lots)) !== null){
    echo $error;
    mysqli_close($con);
    exit();
}

// Send data to app.
echo json_encode($lots);
mysqli_close($con);
exit();
?>
