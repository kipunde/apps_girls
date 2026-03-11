<?php
require_once "fixcors.php";
session_start();
require_once "dbconnect.php";
require_once "logs.php";

// --- Debugging ---
ini_set('display_errors', 1);
error_reporting(E_ALL);

// --- Authentication ---
if (!isset($_SESSION['user'])) {
    http_response_code(401);
    echo json_encode([
        "code" => 401,
        "message" => "User not authenticated or session expired"
    ]);
    exit;
}

// --- DB check ---
if (!$conn) {
    http_response_code(500);
    echo json_encode([
        "code" => 500,
        "message" => "Database connection failed"
    ]);
    exit;
}

// --- Action ---
$action = $_GET['action'] ?? '';

try {
    switch ($action) {

        // ------------------- LIST ALL COURSES -------------------
        case 'list':
            $result = $conn->query("SELECT * FROM courses ORDER BY id DESC");
            $courses = [];
            $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') ? "https" : "http";
            $host = $_SERVER['HTTP_HOST'];
            $basePath = dirname($_SERVER['SCRIPT_NAME']);

            while ($row = $result->fetch_assoc()) {
                $row['thumbnail_url'] = $row['thumbnail']
                    ? $protocol . "://" . $host . $basePath . "/uploads/" . $row['thumbnail']
                    : null;
                $courses[] = $row;
            }

            echo json_encode(["code" => 200, "courses" => $courses]);
            break;

        // ------------------- SAVE COURSE -------------------
        case 'save':
            $title = $_POST['title'] ?? '';
            $desc = $_POST['description'] ?? '';
            $status = $_POST['status'] ?? 'draft';

            if (empty($title) || empty($desc)) {
                echo json_encode(["code" => 400, "message" => "Title and description are required"]);
                exit;
            }

            $thumbnailName = null;
            if (isset($_FILES['thumbnail']) && $_FILES['thumbnail']['error'] == 0) {
                $ext = pathinfo($_FILES['thumbnail']['name'], PATHINFO_EXTENSION);
                $thumbnailName = uniqid() . '_thumb.' . $ext;
                move_uploaded_file($_FILES['thumbnail']['tmp_name'], 'uploads/' . $thumbnailName);
            }

            $stmt = $conn->prepare("INSERT INTO courses (title, description, status, thumbnail) VALUES (?, ?, ?, ?)");
            $stmt->bind_param("ssss", $title, $desc, $status, $thumbnailName);
            $stmt->execute();

            echo json_encode($stmt->affected_rows > 0
                ? ["code" => 200, "message" => "Course created successfully"]
                : ["code" => 500, "message" => "Failed to create course"]);
            break;

        // ------------------- UPDATE COURSE -------------------
        case 'update':
            $id = $_POST['id'] ?? 0;
            $title = $_POST['title'] ?? '';
            $desc = $_POST['description'] ?? '';
            $status = $_POST['status'] ?? 'draft';

            if (!$id || empty($title) || empty($desc)) {
                echo json_encode(["code" => 400, "message" => "ID, title, and description are required"]);
                exit;
            }

            $thumbnailName = null;
            if (isset($_FILES['thumbnail']) && $_FILES['thumbnail']['error'] == 0) {
                $ext = pathinfo($_FILES['thumbnail']['name'], PATHINFO_EXTENSION);
                $thumbnailName = uniqid() . '_thumb.' . $ext;
                move_uploaded_file($_FILES['thumbnail']['tmp_name'], 'uploads/' . $thumbnailName);
            }

            if ($thumbnailName) {
                $stmt = $conn->prepare("UPDATE courses SET title=?, description=?, status=?, thumbnail=? WHERE id=?");
                $stmt->bind_param("ssssi", $title, $desc, $status, $thumbnailName, $id);
            } else {
                $stmt = $conn->prepare("UPDATE courses SET title=?, description=?, status=? WHERE id=?");
                $stmt->bind_param("sssi", $title, $desc, $status, $id);
            }

            $stmt->execute();
            echo json_encode($stmt->affected_rows > 0
                ? ["code" => 200, "message" => "Course updated successfully"]
                : ["code" => 500, "message" => "Failed to update course"]);
            break;

        // ------------------- DELETE COURSE -------------------
        case 'delete':
            $id = $_POST['id'] ?? 0;
            if (!$id) { echo json_encode(["code"=>400,"message"=>"ID is required"]); exit; }

            $stmt = $conn->prepare("DELETE FROM courses WHERE id=?");
            $stmt->bind_param("i", $id);
            $stmt->execute();
            echo json_encode($stmt->affected_rows > 0
                ? ["code"=>200,"message"=>"Course deleted successfully"]
                : ["code"=>500,"message"=>"Failed to delete course"]);
            break;

       // ------------------- ASSIGN COURSE -------------------
case 'assign':
    // Read JSON input from request body
    $input = json_decode(file_get_contents('php://input'), true);
    $user_id = $input['user_id'] ?? 0;
    $course_id = $input['course_id'] ?? 0;

    // Validate input
    if (!$user_id || !$course_id) {
        echo json_encode(["code" => 400, "message" => "User ID and Course ID are required"]);
        exit;
    }

    // Check for duplicate enrollment
    $check = $conn->prepare("SELECT id FROM course_enrollments WHERE user_id = ? AND course_id = ?");
    $check->bind_param("ii", $user_id, $course_id);
    $check->execute();
    $check->store_result();
    if ($check->num_rows > 0) {
        echo json_encode(["code" => 409, "message" => "User already enrolled"]);
        exit;
    }

    // Insert enrollment
    $stmt = $conn->prepare("INSERT INTO course_enrollments (user_id, course_id, enrolled_at, status) VALUES (?, ?, NOW(), 'enrolled')");
    $stmt->bind_param("ii", $user_id, $course_id);
    $stmt->execute();

    if ($stmt->affected_rows > 0) {
        echo json_encode(["code" => 200, "message" => "Course assigned to user"]);
    } else {
        echo json_encode(["code" => 500, "message" => "Failed to assign course"]);
    }
    exit;
    // Assign course
    $stmt = $conn->prepare("INSERT INTO course_enrollments (user_id, course_id, enrolled_at, status) VALUES (?, ?, NOW(), 'enrolled')");
    $stmt->bind_param("ii", $user_id, $course_id);
    $stmt->execute();

    // Return JSON response
    echo json_encode(
        $stmt->affected_rows > 0
            ? ["code" => 200, "message" => "Course assigned to user"]
            : ["code" => 500, "message" => "Failed to assign course"]
    );
    break;

        // ------------------- REMOVE COURSE -------------------
        case 'remove':
            $user_id = $_POST['user_id'] ?? 0;
            $course_id = $_POST['course_id'] ?? 0;

            if (!$user_id || !$course_id) {
                echo json_encode(["code"=>400,"message"=>"User ID and Course ID are required"]);
                exit;
            }

            $stmt = $conn->prepare("DELETE FROM course_enrollments WHERE user_id=? AND course_id=?");
            $stmt->bind_param("ii", $user_id, $course_id);
            $stmt->execute();

            echo json_encode($stmt->affected_rows > 0
                ? ["code"=>200,"message"=>"Course removed from user"]
                : ["code"=>500,"message"=>"Failed to remove course"]);
            break;

        // ------------------- USER COURSES -------------------
        case 'user_courses':
            $user_id = $_SESSION['user']['id'];
            $stmt = $conn->prepare("SELECT c.id AS course_id, c.title, c.description, c.thumbnail,
                                           ce.enrolled_at, ce.status, ce.progress
                                    FROM course_enrollments ce
                                    JOIN courses c ON ce.course_id = c.id
                                    WHERE ce.user_id = ?
                                    ORDER BY ce.enrolled_at DESC");
            $stmt->bind_param("i", $user_id);
            $stmt->execute();
            $result = $stmt->get_result();

            $courses = [];
            $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') ? "https" : "http";
            $host = $_SERVER['HTTP_HOST'];
            $basePath = dirname($_SERVER['SCRIPT_NAME']);

            while ($row = $result->fetch_assoc()) {
                $row['thumbnail_url'] = $row['thumbnail']
                    ? $protocol . "://" . $host . $basePath . "/uploads/" . $row['thumbnail']
                    : null;
                $courses[] = $row;
            }

            echo json_encode(["code"=>200,"courses"=>$courses]);
            break;

            // ------------------- UPDATE ASSIGNED COURSE -------------------
    case 'update_assign':
        $input = json_decode(file_get_contents('php://input'), true);
        $enrollment_id = isset($input['id']) ? intval($input['id']) : 0;
        $user_id       = isset($input['user_id']) ? intval($input['user_id']) : 0;
        $course_id     = isset($input['course_id']) ? intval($input['course_id']) : 0;

        if (!$enrollment_id || !$user_id || !$course_id) {
            echo json_encode(["code" => 400, "message" => "Enrollment ID, User ID, and Course ID are required"]);
            exit;
        }

        // Check duplicate (excluding current enrollment)
        $check = $conn->prepare("SELECT id FROM course_enrollments WHERE user_id=? AND course_id=? AND id<>?");
        $check->bind_param("iii", $user_id, $course_id, $enrollment_id);
        $check->execute();
        $check->store_result();
        if ($check->num_rows > 0) {
            echo json_encode(["code" => 409, "message" => "User already enrolled in this course"]);
            exit;
        }

        // Update
        $stmt = $conn->prepare("UPDATE course_enrollments SET user_id=?, course_id=? WHERE id=?");
        $stmt->bind_param("iii", $user_id, $course_id, $enrollment_id);
        $stmt->execute();

        if ($stmt->affected_rows > 0) {
            echo json_encode(["code" => 200, "message" => "Course updated successfully"]);
        } else {
            echo json_encode(["code" => 500, "message" => "Failed to update course"]);
        }
        exit;


        // ------------------- ADMIN: ALL USERS COURSES -------------------
        case 'all_user_courses':
            $sql = "SELECT ce.id, u.id AS user_id, u.fullname, c.id AS course_id, c.title, ce.enrolled_at, ce.status
                    FROM course_enrollments ce
                    JOIN users u ON ce.user_id = u.id
                    JOIN courses c ON ce.course_id = c.id
                    ORDER BY u.fullname, ce.enrolled_at DESC";
            $result = $conn->query($sql);
            $data = [];
            while ($row = $result->fetch_assoc()) { $data[] = $row; }
            echo json_encode(["code"=>200,"enrollments"=>$data]);
            break;

        // REMOVE USER COURSE
        case 'remove-user-course':
            // Read JSON input
            $input = json_decode(file_get_contents('php://input'), true);
            $enrollment_id = $input['enrollment_id'] ?? 0;

            if (!$enrollment_id) {
                echo json_encode(["code" => 400, "message" => "Enrollment ID is required"]);
                exit;
            }

            $stmt = $conn->prepare("DELETE FROM course_enrollments WHERE id=?");
            $stmt->bind_param("i", $enrollment_id);
            $stmt->execute();

            echo json_encode($stmt->affected_rows > 0
                ? ["code" => 200, "message" => "Enrollment removed successfully"]
                : ["code" => 500, "message" => "Failed to remove enrollment"]);
            break;

            // ------------------- MODULE MANAGEMENT -------------------
case 'list_modules':
    $sql = "SELECT m.id, m.course_id, m.title AS module_title, m.short_detail, 
    m.document_path, m.audio_link, m.video_link, m.created_at,
    c.title AS course_title
    FROM modules m
    JOIN courses c ON m.course_id = c.id
    ORDER BY m.id DESC";

    $result = $conn->query($sql);
    $modules = [];

    $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') ? "https" : "http";
    $host = $_SERVER['HTTP_HOST'];
    $basePath = dirname($_SERVER['SCRIPT_NAME']);

    while ($row = $result->fetch_assoc()) {
    $row['document_url'] = $row['document_path']
    ? $protocol . "://" . $host . $basePath . "/uploads/modules/" . $row['document_path']
    : null;
    $row['audio_url'] = $row['audio_link'] 
    ? $protocol . "://" . $host . $basePath . "/uploads/modules/" . $row['audio_link'] 
    : null;
    $row['video_url'] = $row['video_link'] 
    ? $protocol . "://" . $host . $basePath . "/uploads/modules/" . $row['video_link'] 
    : null;

    $modules[] = [
    'id' => $row['id'],
    'course_id' => $row['course_id'],
    'course_title' => $row['course_title'],
    'title' => $row['module_title'],
    'short_detail' => $row['short_detail'],
    'document_url' => $row['document_url'],
    'audio_url' => $row['audio_url'],
    'video_url' => $row['video_url'],
    'created_at' => $row['created_at'],
    ];
    }

    echo json_encode(["code" => 200, "modules" => $modules]);
break;

case 'save_module':
    // --- Get fields from POST ---
    $course_id    = isset($_POST['course_id']) ? intval($_POST['course_id']) : 0;
    $title        = trim($_POST['title'] ?? '');
    $short_detail = trim($_POST['short_detail'] ?? '');
    $audio_link   = trim($_POST['audio_link'] ?? '');
    $video_link   = trim($_POST['video_link'] ?? '');

    // --- Validation ---
    if ($course_id <= 0 || $title === '') {
        echo json_encode(["code" => 400, "message" => "Course ID and title are required"]);
        exit;
    }

    // --- Handle file upload ---
    $document_path = null;
    if (isset($_FILES['document']) && $_FILES['document']['error'] === 0) {
        $ext = pathinfo($_FILES['document']['name'], PATHINFO_EXTENSION);
        $document_path = uniqid() . '.' . $ext;

        if (!is_dir('uploads/modules')) {
            mkdir('uploads/modules', 0777, true);
        }

        move_uploaded_file($_FILES['document']['tmp_name'], 'uploads/modules/' . $document_path);
    }

    // --- Insert module ---
    $stmt = $conn->prepare(
        "INSERT INTO modules (course_id, title, short_detail, document_path, audio_link, video_link, created_at) 
         VALUES (?, ?, ?, ?, ?, ?, NOW())"
    );
    $stmt->bind_param("isssss", $course_id, $title, $short_detail, $document_path, $audio_link, $video_link);
    $stmt->execute();

    echo json_encode(
        $stmt->affected_rows > 0
            ? ["code" => 200, "message" => "Module added successfully"]
            : ["code" => 500, "message" => "Failed to add module"]
    );
    break;
case 'update_module':
    $id = $_POST['id'] ?? 0;
    $title = $_POST['title'] ?? '';
    $short_detail = $_POST['short_detail'] ?? '';

    if (!$id || empty($title)) {
        echo json_encode(["code"=>400, "message"=>"Module ID and title are required"]);
        exit;
    }

    // Handle optional file replacement
    $document_path = null;
    if (isset($_FILES['document']) && $_FILES['document']['error'] == 0) {
        $ext = pathinfo($_FILES['document']['name'], PATHINFO_EXTENSION);
        $document_path = uniqid() . '.' . $ext;
        move_uploaded_file($_FILES['document']['tmp_name'], 'uploads/modules/' . $document_path);
    }

    $audio_link = $_POST['audio_link'] ?? '';
    $video_link = $_POST['video_link'] ?? '';

    if ($document_path) {
        $stmt = $conn->prepare("UPDATE modules SET title=?, short_detail=?, document_path=?, audio_link=?, video_link=? WHERE id=?");
        $stmt->bind_param("sssssi", $title, $short_detail, $document_path, $audio_link, $video_link, $id);
    } else {
        $stmt = $conn->prepare("UPDATE modules SET title=?, short_detail=?, audio_link=?, video_link=? WHERE id=?");
        $stmt->bind_param("ssssi", $title, $short_detail, $audio_link, $video_link, $id);
    }

    $stmt->execute();
    echo json_encode($stmt->affected_rows > 0
        ? ["code"=>200, "message"=>"Module updated successfully"]
        : ["code"=>500, "message"=>"Failed to update module"]);
    break;

case 'delete_module':
    $id = $_POST['id'] ?? 0;
    if (!$id) {
        echo json_encode(["code"=>400,"message"=>"Module ID is required"]);
        exit;
    }

    $stmt = $conn->prepare("DELETE FROM modules WHERE id=?");
    $stmt->bind_param("i", $id);
    $stmt->execute();

    echo json_encode($stmt->affected_rows > 0
        ? ["code"=>200, "message"=>"Module deleted successfully"]
        : ["code"=>500, "message"=>"Failed to delete module"]);
    break;

    // ------------------- ASSIGN USER TO MODULE -------------------
case 'assign_module':
    $input = json_decode(file_get_contents('php://input'), true);
    $user_id = $input['user_id'] ?? 0;
    $module_id = $input['module_id'] ?? 0;

    if (!$user_id || !$module_id) {
        echo json_encode(["code"=>400,"message"=>"User ID and Module ID are required"]);
        exit;
    }

    // Prevent duplicate assignment
    $check = $conn->prepare("SELECT id FROM module_enrollments WHERE user_id=? AND module_id=?");
    $check->bind_param("ii", $user_id, $module_id);
    $check->execute();
    $check->store_result();
    if ($check->num_rows > 0) {
        echo json_encode(["code"=>409,"message"=>"User already assigned to this module"]);
        exit;
    }

    // Insert assignment
    $stmt = $conn->prepare("INSERT INTO module_enrollments (user_id, module_id) VALUES (?, ?)");
    $stmt->bind_param("ii", $user_id, $module_id);
    $stmt->execute();

    echo json_encode($stmt->affected_rows > 0
        ? ["code"=>200,"message"=>"User assigned to module successfully"]
        : ["code"=>500,"message"=>"Failed to assign user"]);
    break;

// ------------------- LIST MODULE USERS -------------------
case 'module_users':
    $module_id = $_GET['module_id'] ?? 0;
    if (!$module_id) {
        echo json_encode(["code"=>400,"message"=>"Module ID is required"]);
        exit;
    }

    $stmt = $conn->prepare("SELECT me.id AS enrollment_id, u.id AS user_id, u.fullname, me.assigned_at, me.status
                            FROM module_enrollments me
                            JOIN users u ON me.user_id = u.id
                            WHERE me.module_id = ?
                            ORDER BY u.fullname ASC");
    $stmt->bind_param("i", $module_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $users = [];
    while($row = $result->fetch_assoc()) { $users[] = $row; }

    echo json_encode(["code"=>200, "users"=>$users]);
    break;

// ------------------- REMOVE USER FROM MODULE -------------------
case 'remove_module_user':
    $enrollment_id = $_POST['enrollment_id'] ?? 0;
    if (!$enrollment_id) {
        echo json_encode(["code"=>400,"message"=>"Enrollment ID is required"]);
        exit;
    }

    $stmt = $conn->prepare("DELETE FROM module_enrollments WHERE id=?");
    $stmt->bind_param("i", $enrollment_id);
    $stmt->execute();

    echo json_encode($stmt->affected_rows > 0
        ? ["code"=>200,"message"=>"User removed from module"]
        : ["code"=>500,"message"=>"Failed to remove user"]);
    break;

        // ------------------- ADMIN: GET USERS -------------------
        case 'get_users':
            $result = $conn->query("SELECT id, fullname FROM users ORDER BY fullname ASC");
            $users = [];
            while ($row = $result->fetch_assoc()) { $users[] = $row; }
            echo json_encode(["code"=>200,"users"=>$users]);
            break;

        default:
            echo json_encode(["code"=>400,"message"=>"Invalid action"]);
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["code"=>500,"message"=>"Server error: ".$e->getMessage()]);
}

$conn->close();
?>