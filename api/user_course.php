<?php
require_once "fixcors.php";
require_once "dbconnect.php";

header("Content-Type: application/json");

// --- Check DB connection ---
if (!$conn) {
    echo json_encode([
        "code" => 500,
        "message" => "Database connection failed"
    ]);
    exit;
}

// --- Read POST data from Flutter ---
$user_id = $_POST['user_id'] ?? 0;
$user_id = (int)$user_id;

if (!$user_id) {
    echo json_encode([
        "code" => 400,
        "message" => "User ID is required"
    ]);
    exit;
}

// --- Fetch courses for the user ---
try {
    $sql = "
        SELECT c.id, c.title, c.description, c.thumbnail, c.status,
               IF(ce.id IS NULL, 0, 1) AS is_enrolled
        FROM courses AS c
        inner JOIN course_enrollments AS ce
        ON c.id = ce.course_id AND ce.user_id = ?
        ORDER BY c.id DESC
    ";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $courses = [];

    // --- Build full URL for thumbnail ---
    $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') ? "https" : "http";
    $host = $_SERVER['HTTP_HOST'];
    $basePath = rtrim(dirname($_SERVER['SCRIPT_NAME']), '/');

    while ($row = $result->fetch_assoc()) {
        if (!empty($row['thumbnail'])) {
            $row['thumbnail'] = $protocol . "://" . $host . $basePath . "/uploads/" . $row['thumbnail'];
        } else {
            $row['thumbnail'] = null;
        }
        $courses[] = $row;
    }

    echo json_encode([
        "code" => 200,
        "message" => "Courses fetched successfully",
        "courses" => $courses
    ]);

} catch (Exception $e) {
    echo json_encode([
        "code" => 500,
        "message" => "Server error: " . $e->getMessage()
    ]);
}

$conn->close();
?>