<?php
// Disable PHP error output (important for JSON)
ini_set('display_errors', 0);
error_reporting(0);

// Allowed origins
$allowedOrigins = [
    'http://localhost:8080',          // local dev
    'https://prasperascons.com'       // production
];

if (isset($_SERVER['HTTP_ORIGIN']) && in_array($_SERVER['HTTP_ORIGIN'], $allowedOrigins)) {
    header("Access-Control-Allow-Origin: " . $_SERVER['HTTP_ORIGIN']);
}

// Allow cookies/session
header("Access-Control-Allow-Credentials: true");

// Allowed methods
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");

// Allowed headers
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Return JSON by default
header("Content-Type: application/json");

// Include DB and logs
require_once "dbconnect.php";
require_once "logs.php";
?>