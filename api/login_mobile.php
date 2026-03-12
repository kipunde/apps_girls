<?php
require_once 'fixcors.php';
require_once "dbconnect.php";
require_once 'logs.php';

ini_set('display_errors', 1);
error_reporting(E_ALL);
header('Content-Type: application/json');

/*-------------------------------------------
| Read JSON or POST form-data
-------------------------------------------*/
$rawBody = file_get_contents('php://input');
$data = json_decode($rawBody, true);

$email = trim($data['email'] ?? $_POST['email'] ?? '');
$password = trim($data['password'] ?? $_POST['password'] ?? '');

if (!$email || !$password) {
    echo json_encode([
        "code" => 400,
        "message" => "Email and password required",
        "debug_raw_body" => $rawBody,
        "debug_post" => $_POST,
        "debug_data" => $data
    ]);
    exit;
}

/*-------------------------------------------
| Find user in database
-------------------------------------------*/
$stmt = $conn->prepare("SELECT id, fullname, email, password, role, profile_pic, mobile, location, status, created_at FROM users WHERE email=? LIMIT 1");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if (!$result || $result->num_rows == 0) {
    echo json_encode([
        "code" => 401,
        "message" => "Invalid username or password"
    ]);
    exit;
}

$user = $result->fetch_assoc();

/*-------------------------------------------
| Verify password
-------------------------------------------*/
if (!password_verify($password, $user['password'])) {
    echo json_encode([
        "code" => 401,
        "message" => "Invalid username or password"
    ]);
    exit;
}

/*-------------------------------------------
| Check role
-------------------------------------------*/
if ($user['role'] !== 'admin') {
    echo json_encode([
        "code" => 403,
        "message" => "Only admin allowed"
    ]);
    exit;
}

/*-------------------------------------------
| Prepare user response
-------------------------------------------*/
$responseUser = [
    "id" => $user['id'] ?? '',
    "name" => $user['fullname'] ?? '',
    "email" => $user['email'] ?? '',
    "mobile" => $user['mobile'] ?? '',
    "location" => $user['location'] ?? '',
    "profile_pic" => $user['profile_pic'] ?? '',
    "role" => $user['role'] ?? '',
    "status" => $user['status'] ?? '',
    "created_at" => $user['created_at'] ?? '',
];

/*-------------------------------------------
| Send success response
-------------------------------------------*/
echo json_encode([
    "code" => 200,
    "message" => "Login successful",
    "user" => $responseUser
]);