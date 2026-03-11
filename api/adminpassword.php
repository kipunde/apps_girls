<?php
require_once "dbconnect.php";

// 1. Create users table if not exists
$sql_create = "
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fullname VARCHAR(255) NOT NULL,
    mobile VARCHAR(20),
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    profile_pic VARCHAR(255),
    role VARCHAR(20) NOT NULL DEFAULT 'user',
    status TINYINT(1) NOT NULL DEFAULT 2,  -- added status column
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
";

if ($conn->query($sql_create) === TRUE) {
    echo "Table 'users' ready.<br>";
} else {
    echo "Error creating table: " . $conn->error . "<br>";
}

// 2. Admin default info
$admin_email = 'admin@gmail.com';
$fullname    = 'System Admin';
$mobile      = '0788377879';
$define_pass = 'Password@123';
$password    = password_hash($define_pass, PASSWORD_DEFAULT); // default password
$role        = 'admin';
$status      = 2;
$location    = 'HQ';
$profile_pic = NULL;

// 3. Check if admin exists
$check_admin = $conn->prepare("SELECT id FROM users WHERE email=?");
$check_admin->bind_param("s", $admin_email);
$check_admin->execute();
$result = $check_admin->get_result();

if ($result->num_rows > 0) {
    // Admin exists → UPDATE details
    $row = $result->fetch_assoc();
    $admin_id = $row['id'];

    $update_admin = $conn->prepare("
        UPDATE users 
        SET fullname=?, mobile=?, password=?, role=?, location=?, profile_pic=?, status=?
        WHERE id=?
    ");
    $update_admin->bind_param("ssssssii", $fullname, $mobile, $password, $role, $location, $profile_pic, $status, $admin_id);

    if ($update_admin->execute()) {
        echo "Admin details updated successfully!<br>";
        echo "Email: $admin_email<br>Password: $define_pass<br>";
    } else {
        echo "Error updating admin: " . $conn->error . "<br>";
    }

} else {
    // Admin does not exist → INSERT
    $insert_admin = $conn->prepare("
        INSERT INTO users (fullname, mobile, email, password, role, location, profile_pic, status) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ");
    $insert_admin->bind_param("ssssssss", $fullname, $mobile, $admin_email, $password, $role, $location, $profile_pic, $status);

    if ($insert_admin->execute()) {
        echo "Default admin created successfully!<br>";
        echo "Email: $admin_email<br>Password: $define_pass<br>";
    } else {
        echo "Error creating admin: " . $conn->error . "<br>";
    }
}

$conn->close();
?>