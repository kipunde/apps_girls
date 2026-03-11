<?php
header("Content-Type: application/json");
require_once "dbconnect.php";

$user_id = $_POST['user_id'] ?? '';
$module_id = $_POST['module_id'] ?? '';
$file_type = $_POST['file_type'] ?? '';
$action = $_POST['action'] ?? '';

if(!$user_id || !$module_id || !$file_type || !$action){
    echo json_encode(["code"=>400,"message"=>"Missing params"]);
    exit;
}

$stmt = $conn->prepare("INSERT INTO file_access_logs (user_id,module_id,file_type,action) VALUES (?,?,?,?)");
$stmt->bind_param("iiss",$user_id,$module_id,$file_type,$action);
if($stmt->execute()){
    echo json_encode(["code"=>200,"message"=>"Logged successfully"]);
}else{
    echo json_encode(["code"=>500,"message"=>"Failed to log access"]);
}