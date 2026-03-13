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
    // --- Dashboard totals ---
    $totalUsers = (int)$conn->query("SELECT COUNT(*) as cnt FROM users")->fetch_assoc()['cnt'];
    $totalStudent = (int)$conn->query("SELECT COUNT(*) as cnt FROM users WHERE role!='admin'")->fetch_assoc()['cnt'];
    $totalCourses = (int)$conn->query("SELECT COUNT(*) as cnt FROM courses")->fetch_assoc()['cnt'];
    $totalModules = (int)$conn->query("SELECT COUNT(*) as cnt FROM modules")->fetch_assoc()['cnt'];

    // --- Quick stats ---
    $totalUsers=$totalUsers;
    $students = $totalStudent;
    $material = 0; // example static value
    $courses = $totalCourses;
    $modules = $totalModules;

    // --- Build JSON response ---
    $response = [
        "code" => 200,
        "dashboardStats" => [
            ["title" => "Total Users", "value" => $totalUsers, "icon" => "users"],
            ["title" => "Total Courses", "value" => $totalCourses, "icon" => "book-open"],
            ["title" => "Total Modules", "value" => $totalModules, "icon" => "layers"],
        ],
        "quickStats" => [
            ["title" => "Students", "value" => $students, "icon" => "user", "className" => ""],
            ["title" => "Materials", "value" => $material, "icon" => "book-open", "className" => "das1"],
            ["title" => "Courses", "value" => $courses, "icon" => "book", "className" => "das2"],
            ["title" => "Modules", "value" => $modules, "icon" => "layers", "className" => "das3"],
        ]
        // You can add recentCourses and recentEnrollments here later
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