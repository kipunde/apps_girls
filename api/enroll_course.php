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
$check = $conn->prepare("SELECT id, user_id, status FROM course_enrollments WHERE user_id = ? AND course_id = ? AND status IN ('enrolled','in_progress')");
$check->bind_param("ii", $user_id, $course_id);
$check->execute();
$check->store_result();

if ($check->num_rows > 0) {
    echo json_encode([
        "code" => 409,
        "message" => "User already enrolled in this course"
    ]);
    exit;
}

// Insert enrollment
$stmt = $conn->prepare("INSERT INTO course_enrollments (user_id, course_id, enrolled_at, status)
                        VALUES (?, ?, NOW(), 'enrolled')");
$stmt->bind_param("ii", $user_id, $course_id);

if ($stmt->execute()) {

    // ✅ Insert user_course_modules
    $modules_stmt = $conn->prepare("INSERT INTO user_course_modules (user_id, course_id, module_number, unlocked_at) VALUES (?, ?, ?, ?)");
    
    if ($modules_stmt) {
        $now = date("Y-m-d H:i:s");
        for ($i = 1; $i <= 4; $i++) {
            // Module 1 unlocked immediately, others locked (NULL)
            $unlock_at = ($i == 1) ? $now : null;
            $modules_stmt->bind_param("iiis", $user_id, $course_id, $i, $unlock_at);
            $modules_stmt->execute();
        }
    }

    echo json_encode([
        "code" => 200,
        "message" => "Course assigned and modules initialized"
    ]);

} else {
    echo json_encode([
        "code" => 500,
        "message" => "Failed to assign course"
    ]);
}
?>