<?php
require_once "fixcors.php";
session_start();
require_once "dbconnect.php";
require_once "logs.php";

// --- Debugging (remove in production) ---
ini_set('display_errors', 1);
error_reporting(E_ALL);

// --- DB connection check ---
if (!$conn) {
    http_response_code(500);
    echo json_encode([
        "code" => 500,
        "message" => "Database connection failed"
    ]);
    exit;
}

try {
    // --- Fetch all courses ---
$sql = "SELECT c.id, c.title, c.description, c.thumbnail, c.status, ce.user_id, ce.course_id, ce.enrolled_at,ce.status
FROM courses AS c
LEFT JOIN course_enrollments AS ce
ON c.id = ce.course_id
ORDER BY c.id DESC";
    $result = $conn->query($sql);

    $courses = [];
    while ($row = $result->fetch_assoc()) {
        // Build full URL for thumbnail if exists
        $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') ? "https" : "http";
        $host = $_SERVER['HTTP_HOST'];
        $basePath = rtrim(dirname($_SERVER['SCRIPT_NAME']), '/');

        if (!empty($row['thumbnail'])) {
            $row['thumbnail'] = $protocol . "://" . $host . $basePath . "/uploads/" . $row['thumbnail'];
        } else {
            $row['thumbnail'] = null; // or leave empty string if preferred
        }

        $courses[] = $row;
    }

    // --- Optional logging ---
    if (function_exists('write_log')) {
        $user = $_SESSION['user']['fullname'] ?? 'Unknown';
        write_log("Courses fetched by user {$user}", "INFO");
    }

    // --- Send response ---
    echo json_encode([
        "code" => 200,
        "courses" => $courses
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "code" => 500,
        "message" => "Server error: " . $e->getMessage()
    ]);
}

$conn->close();
?>