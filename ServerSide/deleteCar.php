<?php
$IOS_LATEST_VER = "1.0";
$AND_LATEST_VER = "1.0";
// Check app version.
// An app filles it's version + 0 in the other field.

$ios_app_ver = (isset($_POST['ios_app_ver']) ? $_POST['ios_app_ver'] : "not found");
$and_app_ver = (isset($_POST['and_app_ver']) ? $_POST['and_app_ver'] : "not found");
if(($ios_app_ver != $IOS_LATEST_VER) &&
    ($and_app_ver != $AND_LATEST_VER)){

    echo returnError(0);
    exit();
}

// Create connection to database.
$con=mysqli_connect("localhost","ios_app","","Parking");
mysqli_set_charset($con, 'utf8');
 
// Check connection.
if (mysqli_connect_errno())
{
    echo returnError(1);
    mysqli_close($con);
    exit();
}

// Get data from device.
$email = $con->real_escape_string($_POST['email']);
$passhash = strtolower($con->real_escape_string($_POST['passhash']));
$car_id = $con->real_escape_string($_POST['car_id']);

$stmt = $con->prepare("SELECT * FROM users WHERE email = ? AND password_hash = ?");
$stmt->bind_param("ss", $email, $passhash);

if( ! $stmt ){ // Check for the query and return error if smthing is wrong.
    echo returnError(1);
    mysqli_close($con);
    exit();
}

$stmt->execute();
$result = $stmt->get_result();

if($result->num_rows < 1){ // Check if account exists in DB
    echo returnError(2);
    mysqli_close($con);
    exit();
}

// Default value.
$user_id = -1;

// Get data of last row with given login and password. Just safe way for case of 2 and more rows.
while ($row = $result->fetch_assoc())
{
    $user_id = $row['id'];
}

// Delete car if car_id and owner_id matches the input
$stmt = $con->prepare("DELETE FROM cars WHERE id = ? AND owner_id = ?");
$stmt->bind_param("ii", $car_id, $user_id);

if( ! $stmt ){ // Check for the query and return error if smthing is wrong.
    echo returnError(1);
    mysqli_close($con);
    exit();
}

$stmt->execute();
if($stmt->affected_rows != 1){
    echo returnError(1);
    mysqli_close($con);
    exit();
}

// Send data to app.
$success_return = array(
    "success" => true,
);
echo json_encode($success_return);
mysqli_close($con);
exit();

function returnError($err_num)
{
    $err_messages = array(
        0 => "Обновите приложение.",
        1 => "Неизвестная ошибка сервера.",
        2 => "Неверный email или пароль.",
        3 => "Email уже используется другим аккаунтом.",
        4 => "Данный номер телефона уже используется другим аккаунтом.",
        5 => "Данная карта от ворот уже используется другим автомобилем."
    );
    $err_sub_messages = array(
        0 => "Возможна нестабильная работа приложения. Старая версия может не функционировать полностью.",
        1 => "Попробуйте повторить через пару минут.",
        2 => null,
        3 => "Используйте другую почту или восстановите старый аккаунт.",
        4 => "Используйте другой номер телефона или восстановите старый аккаунт.",
        5 => "Данная карта от ворот уже используется другим автомобилем."
    );

    $err_message = $err_messages[$err_num];
    $err_sub_message = $err_sub_messages[$err_num];


    $error_data = array("err_num" => $err_num, 'err_message' => $err_message, 'err_sub_message' => $err_sub_message);
    return json_encode($error_data);
}
?>
