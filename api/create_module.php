<?php
header("Content-Type: application/json");
require_once "dbconnect.php";

$course_id = $_POST['course_id'] ?? '';
$title = $_POST['title'] ?? '';
$short_detail = $_POST['short_detail'] ?? '';
$video_link = $_POST['video_link'] ?? '';
$audio_link = $_POST['audio_link'] ?? '';

if (!$course_id || !$title) {
    echo json_encode(["code"=>400,"message"=>"Course and module title required"]);
    exit;
}

// Handle multiple file uploads
$document_paths = [];
if(isset($_FILES['documents'])){
    foreach($_FILES['documents']['tmp_name'] as $key => $tmp_name){
        $name = basename($_FILES['documents']['name'][$key]);
        $target_dir = "uploads/documents/";
        if(!file_exists($target_dir)) mkdir($target_dir, 0777, true);
        $target_file = $target_dir . time() . "_".$name;
        if(move_uploaded_file($tmp_name, $target_file)){
            $document_paths[] = $target_file;
        }
    }
}

// Convert array to JSON for storage
$document_paths_json = json_encode($document_paths);

$stmt = $conn->prepare("INSERT INTO modules (course_id, title, short_detail, document_path, audio_link, video_link) VALUES (?,?,?,?,?,?)");
$stmt->bind_param("isssss", $course_id, $title, $short_detail, $document_paths_json, $audio_link, $video_link);

if($stmt->execute()){
    echo json_encode(["code"=>200, "message"=>"Module created", "module_id"=>$stmt->insert_id]);
}else{
    echo json_encode(["code"=>500, "message"=>"Module creation failed"]);
}