<?php
header("Content-Type: application/json");
require_once "dbconnect.php";

$user_id = $_POST['user_id'] ?? '';
$course_id = $_POST['course_id'] ?? '';

if(!$user_id || !$course_id){
    echo json_encode(["code"=>400,"message"=>"User ID and Course ID required"]);
    exit;
}

// Check if already enrolled
$stmt = $conn->prepare("SELECT * FROM user_courses WHERE user_id=? AND course_id=?");
$stmt->bind_param("ii",$user_id,$course_id);
$stmt->execute();
$res = $stmt->get_result();
if($res->num_rows>0){
    echo json_encode(["code"=>400,"message"=>"Already enrolled"]);
    exit;
}

$stmt = $conn->prepare("INSERT INTO user_courses (user_id, course_id) VALUES (?,?)");
$stmt->bind_param("ii",$user_id,$course_id);
if($stmt->execute()){
    echo json_encode(["code"=>200,"message"=>"Enrolled successfully"]);
}else{
    echo json_encode(["code"=>500,"message"=>"Enrollment failed"]);
}