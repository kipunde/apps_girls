<?php
require_once "fixcors.php";
session_start();
require_once "dbconnect.php";
require_once "logs.php";

try {

    $sql = "
        SELECT 
            c.id,
            c.title AS course_title,

            COUNT(DISTINCT ce.user_id) AS total_students,

            SUM(CASE WHEN ce.status = 'active' THEN 1 ELSE 0 END) AS active_students,

            SUM(CASE WHEN ce.certificate_issued = 1 THEN 1 ELSE 0 END) AS completed_students,

            ROUND(AVG(ce.progress), 0) AS avg_progress,

            ROUND(AVG(ce.grade), 0) AS avg_grade,

            COUNT(DISTINCT m.id) AS total_modules,

            COUNT(DISTINCT q.id) AS total_quizzes

        FROM courses c

        LEFT JOIN course_enrollments ce 
            ON ce.course_id = c.id

        LEFT JOIN modules m 
            ON m.course_id = c.id

        LEFT JOIN quizzes q 
            ON q.course_id = c.id

        GROUP BY c.id
        ORDER BY c.id DESC
    ";

    $result = mysqli_query($conn, $sql);

    $reports = [];

    while ($row = mysqli_fetch_assoc($result)) {
        $reports[] = $row;
    }

    echo json_encode([
        "code" => 200,
        "reports" => $reports
    ]);

} catch (Exception $e) {
    echo json_encode([
        "code" => 500,
        "message" => $e->getMessage()
    ]);
}