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

// Get login data from device.
$email = $con->real_escape_string($_POST['email']);
$passhash = strtolower($con->real_escape_string($_POST['passhash']));
$car_id = (int)$_POST['car_id'];
$main_card_1 = (int)$_POST['main_card_1'];
$additional_card_1 = (int)$_POST['additional_card_1'];
$main_card_2 = isset($_POST['main_card_2']) ? (int)$_POST['main_card_2'] : null;
$additional_card_2 = isset($_POST['additional_card_2']) ? (int)$_POST['additional_card_2'] : null;
$additional_card_3 = isset($_POST['additional_card_3']) ? (int)$_POST['additional_card_3'] : null;
$additional_card_4 = isset($_POST['additional_card_4']) ? (int)$_POST['additional_card_4'] : null;
$additional_card_5 = isset($_POST['additional_card_5']) ? (int)$_POST['additional_card_5'] : null;

// Get account before applying changing
$stmt = $con->prepare("SELECT id FROM users WHERE email = ? AND password_hash = ?");
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

// Apply FIO change
$params = array($main_card_1, $additional_card_1);
$stmt_string = "UPDATE `cars` SET `main_card` = ?, `additional_card_1` = ?";

$stmt_string .= ", `second_main_card` = ";
if($main_card_2 === null) {
    $stmt_string .= "NULL";
}
else {
    $stmt_string .= "?";
    array_push($params, $main_card_2);
}

$stmt_string .= ", `additional_card_2` = ";
if($additional_card_2 === null) {
    $stmt_string .= "NULL";
}
else {
    $stmt_string .= "?";
    array_push($params, $additional_card_2);
}

$stmt_string .= ", `additional_card_3` = ";
if($additional_card_3 === null) {
    $stmt_string .= "NULL";
} 
else {
    $stmt_string .= "?";
    array_push($params, $additional_card_3);
}

$stmt_string .= ", `additional_card_4` = ";
if($additional_card_4 === null) {
    $stmt_string .= "NULL";
}
else {
    $stmt_string .= "?";
    array_push($params, $additional_card_4);
}

$stmt_string .= ", `additional_card_5` = ";
if($additional_card_5 === null) {
    $stmt_string .= "NULL";
}
else {
    $stmt_string .= "?";
    array_push($params, $additional_card_5);
}
$stmt_string .= " WHERE `cars`.`id` = ? AND `cars`.`owner_id` = ?";
array_push($params, $car_id, $user_id);
$stmt = $con->prepare($stmt_string);

$count = count($params);
if(($count < 4) || ($count > 9)){
    echo returnError(1);
    mysqli_close($con);
    exit();
}
if($count == 4){
    $stmt->bind_param("iiii", $params[0], $params[1], $params[2], $params[3]);
}
if($count == 5){
    $stmt->bind_param("iiiii", $params[0], $params[1], $params[2], $params[3], $params[4]);
}
if($count == 6){
    $stmt->bind_param("iiiiii", $params[0], $params[1], $params[2], $params[3], $params[4], $params[5]);
}
if($count == 7){
    $stmt->bind_param("iiiiiii", $params[0], $params[1], $params[2], $params[3], $params[4], $params[5], $params[6]);
}
if($count == 8){
    $stmt->bind_param("iiiiiiii", $params[0], $params[1], $params[2], $params[3], $params[4], $params[5], $params[6], $params[7]);
}
if($count == 9){
    $stmt->bind_param("iiiiiiiii", $params[0], $params[1], $params[2], $params[3], $params[4], $params[5], $params[6], $params[7], $params[8]);
}

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

// Get account after applying payment
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
$email = "";
$phone = "";
$surname = "";
$name = "";
$patronymic = "";
$balance = 0;

// Get data of last row with given login and password. Just safe way for case of 2 and more rows.
while ($row = $result->fetch_assoc())
{
    $user_id = $row['id'];
    $email = $row['email'];
    $phone = $row['phone'];
    $surname = $row['surname'];
    $name = $row['name'];
    $patronymic = $row['patronymic'];
    $balance = $row['balance'];
}

// Get data about cars of the user.
$stmt = $con->prepare("SELECT * FROM (SELECT cars.id, cars.tariff, cars.new_tariff, parking_lots.lot_id, parking_lots.type, cars.plates, cars.payed_till, cars.is_auto_cont, cars.main_card, cars.second_main_card, cars.additional_card_1, cars.additional_card_2, cars.additional_card_3, cars.additional_card_4, cars.additional_card_5 FROM cars, parking_lots WHERE cars.owner_id = ? AND (cars.parking_lot_id = parking_lots.unique_id_for_DB OR (cars.parking_lot_id is NULL AND unique_id_for_DB = 177))) t1 INNER JOIN (SELECT cars.id, parking_lots.lot_id as new_lot_id, parking_lots.type as new_type FROM parking_lots, cars WHERE cars.owner_id = ? AND (cars.new_parking_lot_id = parking_lots.unique_id_for_DB OR (cars.new_parking_lot_id is NULL AND unique_id_for_DB = 177))) t2 ON t1.id = t2.id");
$stmt->bind_param("ii", $user_id, $user_id);

if( ! $stmt ){ // Check for the query and return error if smthing is wrong.
    echo returnError(1);
    mysqli_close($con);
    exit();
}

$stmt->execute();
$result = $stmt->get_result();

$cars = array();

// Get data of last row with given login and password. Just safe way for case of 2 and more rows.
while ($row = $result->fetch_assoc())
{
    $additional_card_1 = $row['additional_card_1'];
    $additional_card_2 = $row['additional_card_2'];
    $additional_card_3 = $row['additional_card_3'];
    $additional_card_4 = $row['additional_card_4'];
    $additional_card_5 = $row['additional_card_5'];
    $additional_cards = array($additional_card_1, $additional_card_2, $additional_card_3, $additional_card_4, $additional_card_5);

    // Format time for applications
    $datetime = new DateTime($row['payed_till']);
    $datetime = $datetime->format(DateTime::ATOM);
    if($row['payed_till'] == null){
        $datetime = null;
    }

    $car_data = array(
        "id" => $row['id'],
        "tariff" => $row['tariff'],
        "new_tariff" => $row['new_tariff'],
        "parking_lot_type" => $row['type'],
        "parking_lot_id" => $row['lot_id'],
        "new_parking_lot_type" => $row['new_type'],
        "new_parking_lot_id" => $row['new_lot_id'],
        "plates" => $row['plates'],
        "payed_till" => $datetime,
        "is_auto_cont" => ($row['is_auto_cont'] == 1),
        "main_card" => $row['main_card'],
        "second_main_card" => $row['second_main_card'],
        "additional_cards" => $additional_cards,
    );
    array_push($cars, $car_data);
}

// Send data to app.
$user_data = array(
    "email" => $email,
    'phone' => $phone,
    'surname' => $surname,
    'name' => $name,
    'patronymic' => $patronymic,
    'balance' => $balance,
    'cars' => ((count($cars) < 1) ? NULL : $cars)
);
echo json_encode($user_data);
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