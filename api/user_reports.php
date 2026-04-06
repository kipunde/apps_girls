<?php
require_once "fixcors.php";
session_start();
require_once "dbconnect.php";
require_once "logs.php";

try {

    $sql = "
        SELECT 
            u.id,
            u.fullname AS student_name,
            u.email,

            c.title AS course_title,
             m.title as module_title,
            ce.status AS enrollment_status,
            ce.progress AS course_progress,
            ce.grade,
            ce.certificate_issued,

            COUNT(DISTINCT m.id) AS total_modules,

            -- Completed modules
            SUM(CASE WHEN mp.completed = 1 THEN 1 ELSE 0 END) AS completed_modules,

            -- Module progress %
            IFNULL(ROUND(
                (SUM(CASE WHEN mp.completed = 1 THEN 1 ELSE 0 END) 
                / COUNT(DISTINCT m.id)) * 100
            ), 0) AS module_progress,

            -- Quiz attempts
            COUNT(DISTINCT qa.id) AS quiz_attempts,

            -- Last activity
            MAX(
                COALESCE(mp.completed_at, mp.started_at, qa.submitted_at)
            ) AS last_activity

        FROM users u

        -- Course enrollment
        LEFT JOIN course_enrollments ce 
            ON ce.user_id = u.id

        LEFT JOIN courses c 
            ON c.id = ce.course_id

        -- Modules
        LEFT JOIN modules m 
            ON m.course_id = c.id

        -- Module progress
        LEFT JOIN module_progress mp 
            ON mp.user_course_id = ce.id
            AND mp.module_id = m.id

        -- Quiz activity
        LEFT JOIN quiz_answers qa 
            ON qa.user_id = u.id
            AND qa.module_id = m.id

            where u.role!='admin'

        GROUP BY u.id, c.id
        ORDER BY u.id DESC
    ";

    $result = mysqli_query($conn, $sql);

    if (!$result) {
        throw new Exception(mysqli_error($conn));
    }

    $reports = [];

    while ($row = mysqli_fetch_assoc($result)) {

        $progress = (int)$row['module_progress'];
        $grade = $row['grade'] ?? 0;

        // Status Logic
        if ($progress == 100 && $row['certificate_issued'] == 1) {
            $status = "Completed";
        } elseif ($progress > 0) {
            $status = "In Progress";
        } else {
            $status = "Not Started";
        }

        $reports[] = [
            "id" => (int)$row['id'],
            "student_name" => $row['student_name'],
            "email" => $row['email'],
            "course_title" => $row['course_title'] ?? "-",
             "module_title" => $row['module_title'] ?? "-",
            "progress" => $progress,
            "completed_modules" => (int)$row['completed_modules'],
            "total_modules" => (int)$row['total_modules'],

            "grade" => $grade,
            "quiz_attempts" => (int)$row['quiz_attempts'],

            "status" => $status,
            "enrollment_status" => $row['enrollment_status'],

            "certificate" => $row['certificate_issued'] ? "Yes" : "No",

            "last_activity" => $row['last_activity'] ?? "-"
        ];
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