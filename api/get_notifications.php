<?php
require_once "fixcors.php";
session_start();
require_once "dbconnect.php";
require_once "logs.php";

// Debugging: enable errors for dev (remove on production)
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Check if logged in
if (!isset($_SESSION['user'])) {
    http_response_code(401);
    echo json_encode([
        "code" => 401,
        "message" => "User not authenticated or session expired"
    ]);
    exit;
}

// Ensure $conn is set
if (!$conn) {
    http_response_code(500);
    echo json_encode([
        "code" => 500,
        "message" => "Database connection failed"
    ]);
    exit;
}

try {
    // --- Notification Data ---
    $total_new_users = (int)$conn->query("SELECT COUNT(*) as cnt FROM users WHERE status=1")->fetch_assoc()['cnt'];
    $total_new_users = $total_new_users;

    // --- Build JSON response ---
    $response = [
        "code" => 200,
        "total_new_users"=>$total_new_users
         ];

    // Optional logging
    if (function_exists('write_log')) {
        write_log("Dashboard data fetched by user {$_SESSION['user']['fullname']}", "INFO");
    }

    // Return JSON
    echo json_encode($response);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "code" => 500,
        "message" => "Server error: " . $e->getMessage()
    ]);
}

$conn->close();
?>