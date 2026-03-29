<?php
require_once "fixcors.php";
session_start();
require_once "dbconnect.php";
require_once "logs.php";

// --- Debugging (remove in production) ---
ini_set('display_errors', 1);
error_reporting(E_ALL);
header('Content-Type: application/json');

try {
    // --- DB connection check ---
    if (!$conn) {
        throw new Exception("Database connection failed");
    }

    // =======================
    // GET ALL QUIZ ATTEMPTS
    // =======================
    $query = "
        SELECT 
            qa.id,
            qa.user_id,
            u.name AS user_name,
            qa.module_id,
            qa.quiz_id,
            qa.answers,
            qa.submitted_at,
            m.title AS module_title,
            c.title AS course_title,
            q.title AS quiz_title,
            q.questions
        FROM quiz_answers qa
        LEFT JOIN users u ON u.id = qa.user_id
        LEFT JOIN modules m ON m.id = qa.module_id
        LEFT JOIN courses c ON c.id = m.course_id
        LEFT JOIN quizzes q ON q.id = qa.quiz_id
        ORDER BY qa.submitted_at DESC
    ";

    $result = $conn->query($query);

    if ($result === false) {
        throw new Exception("Database query failed: " . $conn->error);
    }

    $results = [];

    while ($row = $result->fetch_assoc()) {

        // Decode JSON safely
        $submitted_answers = json_decode($row['answers'], true) ?: [];
        $questions = json_decode($row['questions'], true) ?: [];

        $total_score = 0;
        $max_score = 0;

        foreach ($questions as $index => $question) {
            $qid = $question['id'] ?? ($index + 1); // fallback to index +1
            $correct_answer = $question['correct_answer'] ?? '';
            $score = isset($question['score']) ? (int)$question['score'] : 0;

            $max_score += $score;

            $user_answer = null;

            foreach ($submitted_answers as $ans) {
                if (isset($ans['question_id']) && (int)$ans['question_id'] === (int)$qid) {
                    $user_answer = $ans['selected_answer'] ?? null;
                    break;
                }
            }

            if ($user_answer !== null && $user_answer === $correct_answer) {
                $total_score += $score;
            }
        }

        $results[] = [
            "id" => (int)$row['id'],
            "user_id" => (int)$row['user_id'],
            "user_name" => $row['user_name'] ?? "Unknown",
            "course_title" => $row['course_title'] ?? "-",
            "module_title" => $row['module_title'] ?? "-",
            "quiz_title" => $row['quiz_title'] ?? "-",
            "module_id" => (int)($row['module_id'] ?? 0),
            "quiz_id" => (int)($row['quiz_id'] ?? 0),
            "total_score" => $total_score,
            "max_score" => $max_score,
            "percentage" => $max_score > 0 ? round(($total_score / $max_score) * 100, 2) : 0,
            "status" => ($max_score > 0 && $total_score >= ($max_score * 0.5)) ? "PASS" : "FAIL",
            "submitted_at" => $row['submitted_at'] ?? null
        ];
    }

    echo json_encode([
        "code" => 200,
        "results" => $results
    ]);

} catch (Exception $e) {
    // Log the error and return JSON safely
    if (function_exists('log_error')) {
        log_error($e->getMessage());
    }

    http_response_code(500);
    echo json_encode([
        "code" => 500,
        "message" => $e->getMessage(),
        "results" => []
    ]);
} finally {
    if (isset($conn) && $conn) $conn->close();
}