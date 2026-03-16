<?php
require_once "fixcors.php";
session_start();
require_once "dbconnect.php";

header("Content-Type: application/json");

// Check DB connection
if (!$conn) {
    echo json_encode([
        "code" => 500,
        "message" => "Database connection failed"
    ]);
    exit;
}

// Read POST data from Flutter
$user_id = $_POST['user_id'] ?? 0;
$course_id = $_POST['course_id'] ?? 0;

// Validate
if (!$user_id || !$course_id) {
    echo json_encode([
        "code" => 400,
        "message" => "User ID and Course ID are required"
    ]);
    exit;
}

// Check duplicate enrollment
$check = $conn->prepare("SELECT id, user_id, status FROM course_enrollments WHERE user_id = ? AND status IN ('enrolled','in_progress')");
$check->bind_param("i", $user_id);
$check->execute();
$check->store_result();

if ($check->num_rows > 0) {
    echo json_encode([
        "code" => 409,
        "message" => "User already enrolled"
    ]);
    exit;
}

// Insert enrollment
$stmt = $conn->prepare("INSERT INTO course_enrollments (user_id, course_id, enrolled_at, status)
                        VALUES (?, ?, NOW(), 'enrolled')");
$stmt->bind_param("ii", $user_id, $course_id);

if ($stmt->execute()) {
    echo json_encode([
        "code" => 200,
        "message" => "Course assigned to user"
    ]);
} else {
    echo json_encode([
        "code" => 500,
        "message" => "Failed to assign course"
    ]);
}
?>
