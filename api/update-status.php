<?php
require_once "fixcors.php";
session_start();
require_once "dbconnect.php";
require_once "logs.php";
// Check if POST data exists
$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['id']) || !isset($data['status'])) {
    echo json_encode(['success' => false, 'message' => 'Invalid request']);
    exit;
}

$id = $data['id'];
$status = $data['status'];

// Optional: validate status
if (!in_array($status, ['1', '2'])) {
    echo json_encode(['success' => false, 'message' => 'Invalid status']);
    exit;
}

// Update status in database
try {
    $stmt = $conn->prepare("UPDATE users SET status = ? WHERE id = ?");
    $stmt->bind_param("si", $status, $id);

    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Status updated successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to update status']);
    }

    $stmt->close();
    $conn->close();
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}