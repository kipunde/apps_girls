<?php
require_once 'fixcors.php';

// Collect POST data (supports both JSON and form-data)
$input = json_decode(file_get_contents('php://input'), true);

$fullname = $input['fullname'] ?? $_POST['fullname'] ?? '';
$email = $input['email'] ?? $_POST['email'] ?? '';
$password = $input['password'] ?? $_POST['password'] ?? '';
$mobile = $input['mobile'] ?? $_POST['mobile'] ?? '';
$location = $input['location'] ?? $_POST['location'] ?? '';
$role = "user";
$status = "2";
$profile_pic = '';

// Handle profile picture if uploaded via form-data
if(isset($_FILES['profile_pic'])){
    $file = $_FILES['profile_pic'];
    $target_dir = "uploads/profile/";
    if(!file_exists($target_dir)) mkdir($target_dir, 0777, true);
    $profile_pic = $target_dir . time() . "_" . basename($file['name']);
    move_uploaded_file($file['tmp_name'], $profile_pic);
}

// Validate required fields
if(!$fullname || !$email || !$password){
    echo json_encode(["code"=>400,"message"=>"Fullname, email and password required"]);
    exit;
}

// Hash password
$hashed_password = password_hash($password, PASSWORD_DEFAULT);

// Insert into database
$stmt = $conn->prepare("
    INSERT INTO users (fullname,email,password,mobile,location,profile_pic,role,status) 
    VALUES (?,?,?,?,?,?,?,?)
");

// Bind all 8 parameters: 7 strings + 1 status (can be string or int)
$stmt->bind_param(
    "ssssssss",
    $fullname,
    $email,
    $hashed_password,
    $mobile,
    $location,
    $profile_pic,
    $role,
    $status
);

if($stmt->execute()){
    echo json_encode(["code"=>200,"message"=>"User registered","user_id"=>$stmt->insert_id]);
}else{
    echo json_encode(["code"=>500,"message"=>"Registration failed","error"=>$stmt->error]);
}

$conn->close();
?>