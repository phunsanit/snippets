<?php
$fileDir = '../assets/';
$token = 'HH89VOiirgXlCdEqDrFs';

if ($_REQUEST['token'] != $token) {
    exit('bad token');
}

$file = $fileDir . $_REQUEST['file'];
if (file_exists($file)) {
    header('Content-Description: File Transfer');
    header('Content-Type: ' . mime_content_type($file));
    header('Content-Disposition: attachment; filename="' . basename($file) . '"');
    header('Expires: 0');
    header('Cache-Control: must-revalidate');
    header('Pragma: public');
    header('Content-Length: ' . filesize($file));

    //readfile($file);
    echo file_get_contents($file);
} else {
    exit('file not found');
}
