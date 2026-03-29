<?php
require_once "fixcors.php";
session_start();
require_once "dbconnect.php";

header("Content-Type: application/json");

// Read JSON
$data = json_decode(file_get_contents("php://input"), true);

$user_id = isset($data['user_id']) ? (int)$data['user_id'] : 0;

if (!$user_id) {
    echo json_encode([
        "code" => 400,
        "message" => "User ID is required"
    ]);
    exit;
}

// =======================
// GET LATEST QUIZ ATTEMPT
// =======================
$stmt = $conn->prepare("
    SELECT module_id, quiz_id, answers
    FROM quiz_answers
    WHERE user_id=?
    ORDER BY submitted_at DESC
    LIMIT 1
");

$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows == 0) {
    echo json_encode([
        "code" => 404,
        "message" => "No quiz attempt found"
    ]);
    exit;
}

$row = $result->fetch_assoc();

$module_id = (int)$row['module_id'];   // ✅ NOW AVAILABLE
$quiz_id   = (int)$row['quiz_id'];     // ✅ NOW AVAILABLE
$submitted_answers = json_decode($row['answers'], true);

// =======================
// GET QUIZ QUESTIONS
// =======================
$stmt2 = $conn->prepare("
    SELECT questions 
    FROM quizzes 
    WHERE id=? AND module_id=?
");

$stmt2->bind_param("ii", $quiz_id, $module_id);
$stmt2->execute();
$result2 = $stmt2->get_result();

if ($result2->num_rows == 0) {
    echo json_encode([
        "code" => 404,
        "message" => "Quiz not found"
    ]);
    exit;
}

$row2 = $result2->fetch_assoc();
$questions = json_decode($row2['questions'], true);

// =======================
// MARKING
// =======================
$total_score = 0;
$max_score = 0;
$details = [];

foreach ($questions as $index => $question) {

    $qid = $index + 1;

    $correct_answer = $question['correct_answer'] ?? '';
    $score = isset($question['score']) ? (int)$question['score'] : 0;

    $max_score += $score;

    $user_answer = null;

    foreach ($submitted_answers as $ans) {
        if ((int)$ans['question_id'] === $qid) {
            $user_answer = $ans['selected_answer'];
            break;
        }
    }

    $is_correct = ($user_answer === $correct_answer);

    if ($is_correct) {
        $total_score += $score;
    }

    $details[] = [
        "question_id" => $qid,
        "question" => $question['question'] ?? '',
        "correct_answer" => $correct_answer,
        "user_answer" => $user_answer,
        "score_awarded" => $is_correct ? $score : 0,
        "max_score" => $score,
        "is_correct" => $is_correct
    ];
}

// =======================
// RESPONSE
// =======================
echo json_encode([
    "code" => 200,
    "module_id" => $module_id,
    "quiz_id" => $quiz_id,
    "total_score" => $total_score,
    "max_score" => $max_score,
    "percentage" => $max_score > 0 ? round(($total_score / $max_score) * 100, 2) : 0,
    "status" => ($total_score >= ($max_score * 0.5)) ? "PASS" : "FAIL",
    "details" => $details
]);

$stmt->close();
$stmt2->close();
$conn->close();
?>