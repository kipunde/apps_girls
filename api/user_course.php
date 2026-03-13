<?php
session_start();
header('Content-Type: application/json');

require_once "dbconnect.php";

if (!isset($_SESSION['user']['id'])) {
    http_response_code(401);
    echo json_encode(["error" => "User not logged in"]);
    exit;
}

$userId = $_SESSION['user']['id'];

$stmt = $conn->prepare("
    SELECT c.id, c.title, c.description, c.thumbnail, c.status
    FROM course_enrollments ce
    JOIN courses c ON ce.course_id = c.id
    WHERE ce.user_id = ?
");

$stmt->bind_param("i", $userId);
$stmt->execute();
$result = $stmt->get_result();

$courses = [];

while ($row = $result->fetch_assoc()) {
    $courses[] = $row;
}

echo json_encode([
    "code" => 200,
    "courses" => $courses
]);

$conn->close();
?>