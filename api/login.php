<?php
require_once 'fixcors.php';
session_start();
require_once "dbconnect.php";
require_once 'logs.php';

$data = json_decode(file_get_contents('php://input'), true);
$email = $data['email'] ?? '';
$password = $data['password'] ?? '';

$stmt = $conn->prepare("SELECT * FROM users WHERE email=?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows == 0) {
    echo json_encode(["code"=>401,"message"=>"Invalid username or password"]);
    exit;
}

$user = $result->fetch_assoc();

if (!password_verify($password, $user['password'])) {
    echo json_encode(["code"=>401,"message"=>"Invalid username or password"]);
    exit;
}

if ($user['role'] !== 'admin') {
    echo json_encode(["code"=>403,"message"=>"Only admin allowed"]);
    exit;
}

// Save session
$_SESSION['user'] = [
    "id" => $user['id'],
    "fullname" => $user['fullname'],
    "email" => $user['email'],
    "profile_pic" => $user['profile_pic'],
    "role" => $user['role']
];

echo json_encode(["code"=>200, "message"=>"Login successful", "user"=>$_SESSION['user']]);