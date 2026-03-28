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

// Read POST JSON from Flutter
$data = json_decode(file_get_contents("php://input"), true);

$user_id   = isset($data['user_id']) ? (int)$data['user_id'] : 0;
$module_id = isset($data['module_id']) ? (int)$data['module_id'] : 0;
$quiz_id   = isset($data['quiz_id']) ? (int)$data['quiz_id'] : 0;
$answers   = $data['answers'] ?? []; // Array of {question_id, selected_answer}

// Validate input
if (!$user_id || !$module_id || !$quiz_id || !is_array($answers) || count($answers) == 0) {
    echo json_encode([
        "code" => 400,
        "message" => "All fields are required and answers must be provided"
    ]);
    exit;
}

// Convert answers array to JSON string
$answers_json = json_encode($answers);

// Insert into `quiz_answers`
$stmt = $conn->prepare("
    INSERT INTO quiz_answers (user_id, module_id, quiz_id, answers, submitted_at)
    VALUES (?, ?, ?, ?, NOW())
");
$stmt->bind_param("iiis", $user_id, $module_id, $quiz_id, $answers_json);

if ($stmt->execute()) {
    echo json_encode([
        "code" => 200,
        "message" => "Quiz answers submitted successfully",
        "insert_id" => $stmt->insert_id
    ]);
} else {
    echo json_encode([
        "code" => 500,
        "message" => "Failed to save quiz answers"
    ]);
}

$stmt->close();
$conn->close();
?>