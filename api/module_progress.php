<?php
header("Content-Type: application/json");
require_once "dbconnect.php";

$user_course_id = $_POST['user_course_id'] ?? '';
$module_id = $_POST['module_id'] ?? '';
$action = $_POST['action'] ?? 'start'; // start or complete

if(!$user_course_id || !$module_id){
    echo json_encode(["code"=>400,"message"=>"Missing params"]);
    exit;
}

if($action=='complete'){
    $stmt = $conn->prepare("UPDATE module_progress SET completed_at=NOW() WHERE user_course_id=? AND module_id=?");
    $stmt->bind_param("ii",$user_course_id,$module_id);
    $stmt->execute();
    echo json_encode(["code"=>200,"message"=>"Module completed"]);
}else{
    $stmt = $conn->prepare("INSERT INTO module_progress (user_course_id,module_id) VALUES (?,?)");
    $stmt->bind_param("ii",$user_course_id,$module_id);
    $stmt->execute();
    echo json_encode(["code"=>200,"message"=>"Module started"]);
}