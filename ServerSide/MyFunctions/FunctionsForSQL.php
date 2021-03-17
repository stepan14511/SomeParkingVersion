<?php
// TODO: check if stmt is checked in right place

function getConnectionToMySql(){
$con=mysqli_connect("localhost","ios_app","","Parking");
    mysqli_set_charset($con, 'utf8');

    // Check connection.
    if (mysqli_connect_errno())
    {
        return null;
    }
    return $con;
}

# Also often used to check if the user exists.
function getUserId($con, $email, $passhash){
    $stmt = $con->prepare("SELECT id FROM users WHERE email = ? AND password_hash = ?");
    if(!$stmt){
        return -1;
    }
    $stmt->bind_param("ss", $email, $passhash);
    $stmt->execute();
    $result = $stmt->get_result();
    if($result->num_rows < 1){
        return -2;
    }
    $user_id = -1;
    while ($row = $result->fetch_assoc()){$user_id = $row['id'];}
    return $user_id;
}

function getFullAccount($con, $email, $passhash){
    $stmt = $con->prepare("SELECT * FROM users WHERE email = ? AND password_hash = ?");
    $stmt->bind_param("ss", $email, $passhash);
    if( ! $stmt ){ return -1; }
    $stmt->execute();
    $result = $stmt->get_result();
    if($result->num_rows < 1){ return -2; }

    $user_id = -1;
    $email = "";
    $phone = "";
    $surname = "";
    $name = "";
    $patronymic = "";
    $balance = 0;

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

    $stmt = $con->prepare("SELECT * FROM (SELECT cars.id, cars.tariff, cars.new_tariff, parking_lots.lot_id, parking_lots.type, cars.plates, cars.payed_till, cars.is_auto_cont, cars.main_card, cars.second_main_card, cars.additional_card_1, cars.additional_card_2, cars.additional_card_3, cars.additional_card_4, cars.additional_card_5 FROM cars, parking_lots WHERE cars.owner_id = ? AND (cars.parking_lot_id = parking_lots.unique_id_for_DB OR (cars.parking_lot_id is NULL AND unique_id_for_DB = 177))) t1 INNER JOIN (SELECT cars.id, parking_lots.lot_id as new_lot_id, parking_lots.type as new_type FROM parking_lots, cars WHERE cars.owner_id = ? AND (cars.new_parking_lot_id = parking_lots.unique_id_for_DB OR (cars.new_parking_lot_id is NULL AND unique_id_for_DB = 177))) t2 ON t1.id = t2.id");
    $stmt->bind_param("ii", $user_id, $user_id);

    if( ! $stmt ){ return -1; }

    $stmt->execute();
    $result = $stmt->get_result();

    $cars = array();

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

    $user_data = array(
        "email" => $email,
        'phone' => $phone,
        'surname' => $surname,
        'name' => $name,
        'patronymic' => $patronymic,
        'balance' => $balance,
        'cars' => ((count($cars) < 1) ? NULL : $cars)
    );
    return $user_data;
}

function updateTariff($con, $user_id, $car_id, $new_tariff){
    $stmt = $con->prepare("SELECT tariff, new_tariff FROM cars WHERE id = ? AND owner_id = ?");
    if (!$stmt) { return -1; }
    $stmt->bind_param("ii", $car_id, $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    if ($result->num_rows < 1) { return -1; }

    $old_tariff = null;
    $old_new_tariff = null;
    while ($row = $result->fetch_assoc())
    {
        $old_tariff = $row['tariff'];
        $old_new_tariff = $row['new_tariff'];
    }

    if($new_tariff === null){
        if($old_new_tariff !== null){
            $stmt = $con->prepare("UPDATE cars SET new_tariff = NULL WHERE cars.id = ? AND cars.owner_id = ?");
            if( ! $stmt ){ return -1; }
            $stmt->bind_param("ii", $car_id, $user_id);
            $stmt->execute();
        }
    }
    else{
        if($old_tariff === null) {
            $stmt = $con->prepare("UPDATE cars SET tariff = ? WHERE cars.id = ? AND cars.owner_id = ?");
            if( ! $stmt ){ return -1; }
            $stmt->bind_param("iii", $new_tariff, $car_id, $user_id);
            $stmt->execute();
        }
        else{
            $stmt = $con->prepare("UPDATE cars SET new_tariff = ? WHERE cars.id = ? AND cars.owner_id = ?");
            if( ! $stmt ){ return -1; }
            $stmt->bind_param("iii", $new_tariff, $car_id, $user_id);
            $stmt->execute();
        }
    }
    return null;
}

// TODO: rewrite updating parking lot
function updateParkingLot($con, $user_id, $car_id, $new_lot){
    $stmt = $con->prepare("SELECT parking_lot_id, new_parking_lot_id FROM cars WHERE id = ? AND owner_id = ?");
    if( ! $stmt ){
        echo returnError(1);
        mysqli_close($con);
        exit();
    }
    $stmt->bind_param("ii", $car_id, $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    if($result->num_rows < 1){
        echo returnError(1);
        mysqli_close($con);
        exit();
    }
    $parking_lot_id = null;
    $new_parking_lot_id = null;
    while ($row = $result->fetch_assoc())
    {
        $parking_lot_id = $row['parking_lot_id'];
        $new_parking_lot_id = $row['new_parking_lot_id'];
    }

    if($new_lot === null){
        if($new_parking_lot_id !== null){
            $stmt = $con->prepare("SELECT car_id, owner_id FROM parking_lots WHERE unique_id_for_DB = ?");
            $stmt->bind_param("s", $new_parking_lot_id);
            if( ! $stmt ){
                echo returnError(1);
                mysqli_close($con);
                exit();
            }
            $stmt->execute();
            $result = $stmt->get_result();
            if($result->num_rows != 1){
                echo returnError(1);
                mysqli_close($con);
                exit();
            }

            while ($row = $result->fetch_assoc())
            {
                $future_car_id = $row['car_id'];
                $future_owner_id = $row['owner_id'];
            }

            if(($car_id === $future_car_id) && ($future_owner_id === null)){
                $stmt = $con->prepare("UPDATE parking_lots SET car_id = NULL WHERE unique_id_for_DB = ?");
                if( ! $stmt ){
                    echo returnError(1);
                    mysqli_close($con);
                    exit();
                }
                $stmt->bind_param("i", $new_parking_lot_id);
                $stmt->execute();

                $stmt = $con->prepare("UPDATE cars SET new_parking_lot_id = NULL WHERE cars.id = ? AND cars.owner_id = ?");
                if( ! $stmt ){
                    echo returnError(1);
                    mysqli_close($con);
                    exit();
                }
                $stmt->bind_param("ii", $car_id, $user_id);
                $stmt->execute();
            }
        }
    }
    else{
        $stmt = $con->prepare("SELECT car_id, owner_id, unique_id_for_DB FROM parking_lots WHERE lot_id = ?");
        if( ! $stmt ){
            echo returnError(1);
            mysqli_close($con);
            exit();
        }
        $stmt->bind_param("s", $new_lot);
        $stmt->execute();
        $result = $stmt->get_result();
        if($result->num_rows != 1){
            echo returnError(1);
            mysqli_close($con);
            exit();
        }
        $picked_lot_car_id = null;
        $picked_lot_owner_id = null;
        $new_lot_id = null;
        while ($row = $result->fetch_assoc())
        {
            $picked_lot_car_id = $row['car_id'];
            $picked_lot_owner_id = $row['owner_id'];
            $new_lot_id = $row['unique_id_for_DB'];
        }

        if(($picked_lot_car_id !== null) || ($picked_lot_owner_id !== null)){
            echo returnError(1);
            mysqli_close($con);
            exit();
        }

        if($parking_lot_id === null) {
            $stmt = $con->prepare("UPDATE cars SET parking_lot_id = ? WHERE cars.id = ? AND cars.owner_id = ?");
            if( ! $stmt ){
                echo returnError(1);
                mysqli_close($con);
                exit();
            }
            $stmt->bind_param("iii", $new_lot_id, $car_id, $user_id);
            $stmt->execute();

            $stmt = $con->prepare("UPDATE parking_lots SET car_id = ? WHERE unique_id_for_DB = ?");
            if( ! $stmt ){
                echo returnError(1);
                mysqli_close($con);
                exit();
            }
            $stmt->bind_param("ii", $car_id, $new_lot_id);
            $stmt->execute();
        }
        else if ($new_parking_lot_id === null){
            $stmt = $con->prepare("UPDATE cars SET new_parking_lot_id = ? WHERE cars.id = ? AND cars.owner_id = ?");
            if( ! $stmt ){
                echo returnError(1);
                mysqli_close($con);
                exit();
            }
            $stmt->bind_param("iii", $new_lot_id, $car_id, $user_id);
            $stmt->execute();

            $stmt = $con->prepare("UPDATE parking_lots SET car_id = ? WHERE unique_id_for_DB = ?");
            if( ! $stmt ){
                echo returnError(1);
                mysqli_close($con);
                exit();
            }
            $stmt->bind_param("ii", $car_id, $new_lot_id);
            $stmt->execute();
        }
        else{ // new parking lot is NOT null
            $stmt = $con->prepare("UPDATE cars SET new_parking_lot_id = ? WHERE id = ? AND owner_id = ?");
            if( ! $stmt ){
                echo returnError(1);
                mysqli_close($con);
                exit();
            }
            $stmt->bind_param("iii", $new_lot_id, $car_id, $user_id);
            $stmt->execute();

            $stmt = $con->prepare("UPDATE parking_lots SET car_id = ? WHERE unique_id_for_DB = ?");
            if( ! $stmt ){
                echo returnError(1);
                mysqli_close($con);
                exit();
            }
            $stmt->bind_param("ii", $car_id, $new_lot_id);
            $stmt->execute();

            $stmt = $con->prepare("UPDATE parking_lots SET car_id = NULL WHERE unique_id_for_DB = ?");
            if( ! $stmt ){
                echo returnError(1);
                mysqli_close($con);
                exit();
            }
            $stmt->bind_param("i", $new_parking_lot_id);
            $stmt->execute();
        }

    }
    return null;
}

function updateFIO($con, $user_id, $new_surname, $new_name, $new_patronymic){
    if($new_patronymic === null){
        $stmt = $con->prepare("UPDATE `users` SET `surname` = ?, `name` = ?, `patronymic` = NULL WHERE `users`.`id` = ?");
        $stmt->bind_param("sss", $new_surname, $new_name, $user_id);
    }
    else{
        $stmt = $con->prepare("UPDATE `users` SET `surname` = ?, `name` = ?, `patronymic` = ? WHERE `users`.`id` = ?");
        $stmt->bind_param("ssss", $new_surname, $new_name, $new_patronymic, $user_id);
    }

    if( ! $stmt ){
        return -1;
    }

    $stmt->execute();
    if($stmt->affected_rows != 1){
        return -1;
    }
}

function updateCards($con, $user_id, $car_id, $main_card_1, $main_card_2, $additional_card_1, $additional_card_2, $additional_card_3, $additional_card_4, $additional_card_5){
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
    if(($count < 4) || ($count > 9)){ return -1; }
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

    if( ! $stmt ){ return -1; }

    $stmt->execute();
    if($stmt->affected_rows != 1){ return -1; }
    return null;
}

function updateAutoPay($con, $user_id, $car_id, $autoPay){
    $stmt = $con->prepare("UPDATE `cars` SET `is_auto_cont` = ? WHERE `cars`.`id` = ? AND `cars`.`owner_id` = ?");
    $stmt->bind_param("iii", $autoPay, $car_id, $user_id);

    if( ! $stmt ){ return -1; }

    $stmt->execute();
    return null;
}

function accountRegistration($con, $email, $passhash, $phone, $surname, $name, $patronymic){
    // Check email for being not used
    $stmt = $con->prepare("SELECT * FROM users WHERE email = ?");
    $stmt->bind_param("s", $email);
    if( ! $stmt ){ return -1; }
    $stmt->execute();
    $result = $stmt->get_result();
    if($result->num_rows >= 1){ return -3; }

    // Check phone number for being not used
    $stmt = $con->prepare("SELECT * FROM users WHERE phone = ?");
    $stmt->bind_param("s", $phone);
    if( ! $stmt ){ return -1; }
    $stmt->execute();
    $result = $stmt->get_result();
    if($result->num_rows >= 1){ return -1; }

    // Insert new user into DB
    $stmt = null;
    if($patronymic === null){
        $stmt = $con->prepare("INSERT INTO `users` (`email`, `phone`, `password_hash`, `surname`, `name`, `balance`) VALUES (?, ?, ?, ?, ?, 0);");
        $stmt->bind_param("sssss", $email, $phone, $passhash, $surname, $name);
    }
    else{
        $stmt = $con->prepare("INSERT INTO `users` (`email`, `phone`, `password_hash`, `surname`, `name`, `patronymic`, `balance`) VALUES (?, ?, ?, ?, ?, ?, 0);");
        $stmt->bind_param("ssssss", $email, $phone, $passhash, $surname, $name, $patronymic);
    }
    if( ! $stmt ){ return -1; }
    $stmt->execute();
    return null;
}

function processPayment($con, $user_id, $payment_amount){
    $stmt = $con->prepare("UPDATE `users` SET `balance` = `balance` + ? WHERE `users`.`id` = ?");
    $stmt->bind_param("is", $payment_amount, $user_id);

    if( ! $stmt ){ return -1; }

    $stmt->execute();
    return null;
}

function getAvailableParkingLots($con){
    $stmt = $con->prepare("SELECT lot_id, type FROM parking_lots WHERE car_id IS NULL AND owner_id is NULL");

    if( ! $stmt ){ return -1; }

    $stmt->execute();
    $result = $stmt->get_result();

    $lots = array();

    while ($row = $result->fetch_assoc())
    {
        $lot = array(
            "id" => $row['lot_id'],
            "type" => $row['type']
        );
        array_push($lots, $lot);
    }
    return $lots;
}

function addCar($con, $user_id, $plates, $main_card, $additional_card){
    $stmt = $con->prepare("SELECT * FROM cars WHERE main_card = ?");
    $stmt->bind_param("i", $main_card);

    if( ! $stmt ){ return -1; }

    $stmt->execute();
    $result = $stmt->get_result();

    if($result->num_rows >= 1){ return -5; }

    $stmt = $con->prepare("INSERT INTO cars (owner_id, plates, main_card, additional_card_1) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("isii", $user_id, $plates, $main_card, $additional_card);

    if( ! $stmt ){ return -1; }

    $stmt->execute();
    if($stmt->affected_rows != 1){ return -1; }

    return null;
}

function deleteCar($con, $user_id, $car_id){
    $stmt = $con->prepare("DELETE FROM cars WHERE id = ? AND owner_id = ?");
    $stmt->bind_param("ii", $car_id, $user_id);

    if( ! $stmt ){ return -1; }

    $stmt->execute();
    if($stmt->affected_rows != 1){ return -1; }
    return null;
}