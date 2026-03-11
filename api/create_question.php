<?php
header("Content-Type: application/json");
require_once "dbconnect.php";

$data = json_decode(file_get_contents("php://input"), true);
$module_id = $data['module_id'] ?? '';
$question = $data['question'] ?? '';
$answer = $data['answer'] ?? '';

if(!$module_id || !$question){
    echo json_encode(["code"=>400,"message"=>"Module ID and question required"]);
    exit;
}

$stmt = $conn->prepare("INSERT INTO questions (module_id, question, answer) VALUES (?,?,?)");
$stmt->bind_param("iss", $module_id, $question, $answer);

if($stmt->execute()){
    echo json_encode(["code"=>200,"message"=>"Question created"]);
}else{
    echo json_encode(["code"=>500,"message"=>"Failed to create question"]);
}