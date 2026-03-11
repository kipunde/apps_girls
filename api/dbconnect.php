<?php
//local database
$host = "localhost";
$username = "root";
$password = "ubunifu2016";
$database = "odo_db";

// remote database
// $host = "localhost";
// $username = "praspera_appdb_user";
// $password = "Password@123";
// $database = "praspera_app_db";

$conn = new mysqli($host, $username, $password, $database);

if ($conn->connect_error) {
    die(json_encode([
        "code" => 500,
        "message" => "Database connection failed"
    ]));
}