<?php
$fileDir = 'D:\xampp\htdocs\snippets\PHP\\';
$token = 'HH89VOiirgXlCdEqDrFs';

if ($_POST['token'] != $token) {
    exit('bad token');
}

$requestFile = $fileDir . $_POST['file'];
if (file_exists($requestFile)) {
    readfile($requestFile);
} else {
    exit('file not found');
}
