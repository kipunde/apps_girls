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
$module_id = isset($_POST['module_id']) ? (int)$_POST['module_id'] : 0;

// Validate input
if (!$module_id ) {
    echo json_encode([
        "code" => 400,
        "message" => "Module ID are required"
    ]);
    exit;
}

// Prepare query: get all modules for the user's enrolled course
$query = "SELECT `id`, `course_id`, `module_id`, `title`, `questions`, `created_at`, `updated_at` FROM `quizzes` WHERE  module_id =?";

$stmt = $conn->prepare($query);
$stmt->bind_param("i", $module_id);
$stmt->execute();
$result = $stmt->get_result();

$modules = [];

while ($row = $result->fetch_assoc()) {
    $modules[] = [
        'module_id' => (int)$row['module_id'],
        'quiz_id'=> (int)$row['id'],
        'course_name' => $row['title'],
        'module_title' => $row['title'] ?? '',
        'short_detail' => $row['title'] ?? '',
        'document_path' => $row['document_path'],
        'audio_link' => $row['audio_link'],
        'video_link' => $row['video_link'],
        'module_status' => $row['module_status'] ?? 'disabled',
        'assigned_at' => $row['assigned_at'] ?? null,
        'enrolled_at' => $row['enrolled_at'] ?? null,
        'quize_name' =>$row['title']?? null,
        'questions' =>$row['questions'] ?? null,

    ];
}

if (count($modules) > 0) {
    echo json_encode([
        "code" => 200,
        "modules" => $modules
    ]);
} else {
    echo json_encode([
        "code" => 404,
        "message" => "No modules found for this course"
    ]);
}

$stmt->close();
$conn->close();
?>