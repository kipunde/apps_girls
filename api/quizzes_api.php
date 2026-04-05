<?php
require_once "fixcors.php";
require_once "dbconnect.php";
require_once "logs.php";

// --- Debugging ---
ini_set('display_errors', 1);
error_reporting(E_ALL);

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

        // ------------------- SAVE QUIZ -------------------
        case 'saveQuiz':
            $input = json_decode(file_get_contents('php://input'), true);

            $course_id = isset($input['course_id']) ? intval($input['course_id']) : 0;
            $module_id = isset($input['module_id']) ? intval($input['module_id']) : 0;
            $title     = trim($input['title'] ?? '');
            $questions = $input['questions'] ?? [];

            if (!$course_id || !$module_id || empty($title) || empty($questions)) {
                echo json_encode(["code"=>400,"message"=>"Course, Module, Title and Questions are required"]);
                exit;
            }

            $questions_json = json_encode($questions);

            $stmt = $conn->prepare("INSERT INTO quizzes (course_id, module_id, title, questions, created_at) VALUES (?, ?, ?, ?, NOW())");
            $stmt->bind_param("iiss", $course_id, $module_id, $title, $questions_json);
            $stmt->execute();

            echo json_encode(
                $stmt->affected_rows > 0
                ? ["code"=>200,"message"=>"Quiz saved successfully"]
                : ["code"=>500,"message"=>"Failed to save quiz"]
            );
            break;

        // ------------------- UPDATE QUIZ -------------------
        case 'updateQuiz':
            $input = json_decode(file_get_contents('php://input'), true);

            $quiz_id   = isset($input['id']) ? intval($input['id']) : 0;
            $course_id = isset($input['course_id']) ? intval($input['course_id']) : 0;
            $module_id = isset($input['module_id']) ? intval($input['module_id']) : 0;
            $title     = trim($input['title'] ?? '');
            $questions = $input['questions'] ?? [];

            if (!$quiz_id || !$course_id || !$module_id || empty($title) || empty($questions)) {
                echo json_encode(["code"=>400,"message"=>"Quiz ID, Course, Module, Title and Questions are required"]);
                exit;
            }

            $questions_json = json_encode($questions);

            $stmt = $conn->prepare("UPDATE quizzes SET course_id=?, module_id=?, title=?, questions=?, updated_at=NOW() WHERE id=?");
            $stmt->bind_param("iissi", $course_id, $module_id, $title, $questions_json, $quiz_id);
            $stmt->execute();

            echo json_encode(
                $stmt->affected_rows > 0
                ? ["code"=>200,"message"=>"Quiz updated successfully"]
                : ["code"=>500,"message"=>"Failed to update quiz"]
            );
            break;

        // ------------------- GET ALL QUIZES-------------------
            case 'getQuizList':
            $module_id= isset($_GET['module_id']) ? intval($_GET['module_id']) : null;

            if ($module_id) {
                $stmt = $conn->prepare("
                    SELECT q.*, c.title AS course_name, m.title AS module_name
                    FROM quizzes q
                    LEFT JOIN courses c ON q.course_id = c.id
                    LEFT JOIN modules m ON q.module_id = m.id
                    WHERE q.module_id = ?
                ");
                $stmt->bind_param("i", $module_id);
                $stmt->execute();
                $result = $stmt->get_result();
                $quiz = $result->fetch_assoc();
                echo json_encode($quiz ? ["code" => 200, "data" => $quiz] : ["code" => 404, "message" => "Quiz not found"]);
            } else {
                $result = $conn->query("
                    SELECT q.*, c.title AS course_name, m.title AS module_name
                    FROM quizzes q
                    LEFT JOIN courses c ON q.course_id = c.id
                    LEFT JOIN modules m ON q.module_id = m.id
                    ORDER BY q.created_at DESC
                ");
                $quizzes = [];
                while ($row = $result->fetch_assoc()) {
                    $quizzes[] = $row;
                }
                echo json_encode(["code" => 200, "data" => $quizzes]);
            }
            break;


        // ------------------- GET QUIZ BY ID -------------------
        case 'getQuiz':
            $quiz_id = isset($_GET['id']) ? intval($_GET['id']) : null;

            if ($quiz_id) {
                $stmt = $conn->prepare("
                    SELECT q.*, c.title AS course_name, m.title AS module_name
                    FROM quizzes q
                    LEFT JOIN courses c ON q.course_id = c.id
                    LEFT JOIN modules m ON q.module_id = m.id
                    WHERE q.id = ?
                ");
                $stmt->bind_param("i", $quiz_id);
                $stmt->execute();
                $result = $stmt->get_result();
                $quiz = $result->fetch_assoc();
                echo json_encode($quiz ? ["code" => 200, "data" => $quiz] : ["code" => 404, "message" => "Quiz not found"]);
            } else {
                $result = $conn->query("
                    SELECT q.*, c.title AS course_name, m.title AS module_name
                    FROM quizzes q
                    LEFT JOIN courses c ON q.course_id = c.id
                    LEFT JOIN modules m ON q.module_id = m.id
                    ORDER BY q.created_at DESC
                ");
                $quizzes = [];
                while ($row = $result->fetch_assoc()) {
                    $quizzes[] = $row;
                }
                echo json_encode(["code" => 200, "data" => $quizzes]);
            }
            break;

        // ------------------- DELETE QUIZ -------------------
        case 'deleteQuiz':
            $quiz_id = isset($_GET['id']) ? intval($_GET['id']) : 0;
            if (!$quiz_id) {
                echo json_encode(["code"=>400,"message"=>"Quiz ID is required"]);
                exit;
            }

            $stmt = $conn->prepare("DELETE FROM quizzes WHERE id=?");
            $stmt->bind_param("i", $quiz_id);
            $stmt->execute();

            echo json_encode(
                $stmt->affected_rows > 0
                ? ["code"=>200,"message"=>"Quiz deleted successfully"]
                : ["code"=>404,"message"=>"Quiz not found"]
            );
            break;

        default:
            echo json_encode(["code"=>400,"message"=>"Invalid action"]);
            break;
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["code"=>500,"message"=>"Server error: ".$e->getMessage()]);
}

$conn->close();
?>