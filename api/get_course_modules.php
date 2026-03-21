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
$user_id = isset($_POST['user_id']) ? (int)$_POST['user_id'] : 0;
$course_id = isset($_POST['course_id']) ? (int)$_POST['course_id'] : 0;

// Validate input
if (!$user_id || !$course_id) {
    echo json_encode([
        "code" => 400,
        "message" => "User ID and Course ID are required"
    ]);
    exit;
}

// Prepare query: get all modules for the user's enrolled course
$query = "
    SELECT 
    m.id AS module_id,
    c.title AS course_name,
    m.title AS module_title,
    m.short_detail,
    m.document_path,
    m.audio_link,
    m.video_link,
    me.status AS module_status,
    me.assigned_at,
    ce.created_at AS enrolled_at
FROM course_enrollments AS ce
INNER JOIN module_enrollments AS me 
    ON me.user_id = ce.user_id 
    AND me.module_id IN (
        SELECT id FROM modules WHERE course_id = ce.course_id
    )
INNER JOIN modules AS m 
    ON m.id = me.module_id
INNER JOIN courses AS c 
    ON c.id = m.course_id
WHERE ce.user_id = ? 
  AND ce.course_id = ? 
  AND ce.status IN ('enrolled','in_progress')
ORDER BY m.id ASC
";

$stmt = $conn->prepare($query);
$stmt->bind_param("ii", $user_id, $course_id);
$stmt->execute();
$result = $stmt->get_result();

$modules = [];

while ($row = $result->fetch_assoc()) {
    $modules[] = [
        'id' => (int)$row['module_id'],
        'course_name' => $row['course_name'],
        'module_title' => $row['module_title'] ?? '',
        'short_detail' => $row['short_detail'] ?? '',
        'document_path' => $row['document_path'],
        'audio_link' => $row['audio_link'],
        'video_link' => $row['video_link'],
        'module_status' => $row['module_status'] ?? 'disabled',
        'assigned_at' => $row['assigned_at'] ?? null,
        'enrolled_at' => $row['enrolled_at'] ?? null,
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