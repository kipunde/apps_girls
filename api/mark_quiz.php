<?php
require_once "fixcors.php";
session_start();
require_once "dbconnect.php";

header("Content-Type: application/json");

// Read POST JSON from Flutter
$data = json_decode(file_get_contents("php://input"), true);

$user_id   = isset($data['user_id']) ? (int)$data['user_id'] : 0;
$module_id = isset($data['module_id']) ? (int)$data['module_id'] : 0;
$quiz_id   = isset($data['quiz_id']) ? (int)$data['quiz_id'] : 0;

// Validate input
if (!$user_id || !$module_id || !$quiz_id) {
    echo json_encode([
        "code" => 400,
        "message" => "User ID, Module ID, and Quiz ID are required"
    ]);
    exit;
}

// =======================
// GET USER ANSWERS
// =======================
$stmt = $conn->prepare("
    SELECT answers 
    FROM quiz_answers 
    WHERE user_id=? AND module_id=? AND quiz_id=?
");
$stmt->bind_param("iii", $user_id, $module_id, $quiz_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows == 0) {
    echo json_encode([
        "code" => 404,
        "message" => "No submitted answers found"
    ]);
    exit;
}

$row = $result->fetch_assoc();
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
// MARKING LOGIC
// =======================
$total_score = 0;
$max_score = 0;
$details = [];

foreach ($questions as $index => $question) {

    // ✅ FIX: generate question_id using index
    $qid = $index + 1;

    $correct_answer = $question['correct_answer'] ?? '';
    $score = isset($question['score']) ? (int)$question['score'] : 0;

    $max_score += $score;

    // Find user answer
    $user_answer = null;

    foreach ($submitted_answers as $ans) {
        if ((int)$ans['question_id'] === $qid) {
            $user_answer = $ans['selected_answer'];
            break;
        }
    }

    // Check correctness
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
// FINAL RESPONSE
// =======================
echo json_encode([
    "code" => 200,
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