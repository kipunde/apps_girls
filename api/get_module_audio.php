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
if (!$module_id) {
    echo json_encode([
        "code" => 400,
        "message" => "Module id is required"
    ]);
    exit;
}

// Allowed file types
$allowedTypes = ['mp3', 'wav', 'aac', 'm4a', 'ogg', 'amr', 'wma', 'aiff'];

// Prepare query
$query = "SELECT id, module_id, title, file_type, file_path 
          FROM module_attachments 
          WHERE module_id = ?";

$stmt = $conn->prepare($query);
$stmt->bind_param("i", $module_id);
$stmt->execute();
$result = $stmt->get_result();

$modules = [];

// Build modules array
while ($row = $result->fetch_assoc()) {
    $fileType = strtolower($row['file_type'] ?? '');
    
    // Only include allowed types
    if (in_array($fileType, $allowedTypes)) {
        $modules[] = [
            'module_id'    => (int)$row['module_id'],
            'module_title' => $row['title'] ?? '',
            'file_type'    => $row['file_type'] ?? '',
            'audioLink'=> $row['file_path'] ?? '',
        ];
    }
}

// Return JSON response
if (!empty($modules)) {
    echo json_encode([
        "code"    => 200,
        "modules" => $modules
    ]);
} else {
    echo json_encode([
        "code"    => 404,
        "message" => "No documents available for this module"
    ]);
}

// Close connection
$stmt->close();
$conn->close();
?>