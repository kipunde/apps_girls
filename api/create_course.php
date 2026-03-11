<?php
require_once "fixcors.php";
session_start();
require_once "dbconnect.php";
require_once "logs.php";

// Debugging (remove on production)
ini_set('display_errors', 1);
error_reporting(E_ALL);

// --- Check if user is authenticated ---
if (!isset($_SESSION['user'])) {
    http_response_code(401);
    echo json_encode([
        "code" => 401,
        "message" => "User not authenticated or session expired"
    ]);
    exit;
}

// --- Ensure $conn is valid ---
if (!$conn) {
    http_response_code(500);
    echo json_encode([
        "code" => 500,
        "message" => "Database connection failed"
    ]);
    exit;
}

// --- Get action ---
$action = $_GET['action'] ?? '';

try {
    switch ($action) {

        // ------------------- LIST COURSES -------------------
        case 'list':
            $result = $conn->query("SELECT * FROM courses ORDER BY id DESC");
            $courses = [];
            while ($row = $result->fetch_assoc()) {
                if ($row['thumbnail']) {
                    $row['thumbnail'] = 'uploads/' . $row['thumbnail'];
                }
                $courses[] = $row;
            }

            echo json_encode([
                "code" => 200,
                "courses" => $courses
            ]);
            break;

        // ------------------- SAVE COURSE -------------------
        case 'save':
            $title = $_POST['title'] ?? '';
            $slug = $_POST['slug'] ?? '';
            $short_desc = $_POST['short_description'] ?? null;
            $desc = $_POST['description'] ?? '';
            $status = $_POST['status'] ?? 'draft';

            if (empty($title) || empty($slug) || empty($desc)) {
                echo json_encode([
                    "code" => 400,
                    "message" => "Title, slug, and description are required"
                ]);
                exit;
            }

            // Handle thumbnail upload
            $thumbnailName = null;
            if (isset($_FILES['thumbnail']) && $_FILES['thumbnail']['error'] == 0) {
                $ext = pathinfo($_FILES['thumbnail']['name'], PATHINFO_EXTENSION);
                $thumbnailName = uniqid() . '_thumb.' . $ext;
                move_uploaded_file($_FILES['thumbnail']['tmp_name'], 'uploads/' . $thumbnailName);
            }

            $stmt = $conn->prepare("INSERT INTO courses (title, slug, short_description, description, status, thumbnail) VALUES (?, ?, ?, ?, ?, ?)");
            $stmt->bind_param("ssssss", $title, $slug, $short_desc, $desc, $status, $thumbnailName);
            $stmt->execute();

            if ($stmt->affected_rows > 0) {
                echo json_encode([
                    "code" => 200,
                    "message" => "Course created successfully"
                ]);
                if (function_exists('write_log')) {
                    write_log("Course '$title' created by {$_SESSION['user']['fullname']}", "INFO");
                }
            } else {
                echo json_encode([
                    "code" => 500,
                    "message" => "Failed to create course"
                ]);
            }
            break;

        // ------------------- UPDATE COURSE -------------------
        case 'update':
            $id = $_POST['id'] ?? 0;
            $title = $_POST['title'] ?? '';
            $slug = $_POST['slug'] ?? '';
            $short_desc = $_POST['short_description'] ?? null;
            $desc = $_POST['description'] ?? '';
            $status = $_POST['status'] ?? 'draft';

            if (!$id || empty($title) || empty($slug) || empty($desc)) {
                echo json_encode([
                    "code" => 400,
                    "message" => "ID, title, slug, and description are required"
                ]);
                exit;
            }

            // Handle new thumbnail
            $thumbnailName = null;
            if (isset($_FILES['thumbnail']) && $_FILES['thumbnail']['error'] == 0) {
                $ext = pathinfo($_FILES['thumbnail']['name'], PATHINFO_EXTENSION);
                $thumbnailName = uniqid() . '_thumb.' . $ext;
                move_uploaded_file($_FILES['thumbnail']['tmp_name'], 'uploads/' . $thumbnailName);
            }

            if ($thumbnailName) {
                $stmt = $conn->prepare("UPDATE courses SET title=?, slug=?, short_description=?, description=?, status=?, thumbnail=? WHERE id=?");
                $stmt->bind_param("ssssssi", $title, $slug, $short_desc, $desc, $status, $thumbnailName, $id);
            } else {
                $stmt = $conn->prepare("UPDATE courses SET title=?, slug=?, short_description=?, description=?, status=? WHERE id=?");
                $stmt->bind_param("sssssi", $title, $slug, $short_desc, $desc, $status, $id);
            }

            $stmt->execute();
            if ($stmt->affected_rows > 0) {
                echo json_encode([
                    "code" => 200,
                    "message" => "Course updated successfully"
                ]);
                if (function_exists('write_log')) {
                    write_log("Course ID $id updated by {$_SESSION['user']['fullname']}", "INFO");
                }
            } else {
                echo json_encode([
                    "code" => 500,
                    "message" => "Failed to update course"
                ]);
            }
            break;

        // ------------------- DELETE COURSE -------------------
        case 'delete':
            $id = $_POST['id'] ?? 0;
            if (!$id) {
                echo json_encode([
                    "code" => 400,
                    "message" => "ID is required"
                ]);
                exit;
            }

            $stmt = $conn->prepare("DELETE FROM courses WHERE id=?");
            $stmt->bind_param("i", $id);
            $stmt->execute();

            if ($stmt->affected_rows > 0) {
                echo json_encode([
                    "code" => 200,
                    "message" => "Course deleted successfully"
                ]);
                if (function_exists('write_log')) {
                    write_log("Course ID $id deleted by {$_SESSION['user']['fullname']}", "INFO");
                }
            } else {
                echo json_encode([
                    "code" => 500,
                    "message" => "Failed to delete course"
                ]);
            }
            break;

        default:
            echo json_encode([
                "code" => 400,
                "message" => "Invalid action"
            ]);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "code" => 500,
        "message" => "Server error: " . $e->getMessage()
    ]);
}

$conn->close();
?>