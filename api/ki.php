<?php
// Generate a 36-character alphanumeric key automatically
//http://localhost/oddproject/api/courses_api.php?action=save&debug=1
function generateKey($length = 36) {
    $bytes = random_bytes($length);
    $key = substr(strtr(base64_encode($bytes), '+/', 'Aa'), 0, $length);
    return $key;
}

$private_key = generateKey();
echo $private_key;
?>
