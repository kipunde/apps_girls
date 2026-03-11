<?php
require_once "fixcors.php";
session_start();
require_once "dbconnect.php";
require_once "logs.php";
// Read POST JSON input
$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['id'])) {
    echo json_encode(['success' => false, 'message' => 'Invalid request']);
    exit;
}

$id = $data['id'];

// Delete user from database
try {
    $stmt = $conn->prepare("DELETE FROM users WHERE id = ? AND role!='admin'");
    $stmt->bind_param("i", $id);

    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'User deleted successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to delete user']);
    }

    $stmt->close();
    $conn->close();
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}