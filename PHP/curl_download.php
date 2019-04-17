<?php
header('Cache-Control: no-cache, no-store, must-revalidate');
header('Expires: 0');
header('Pragma: no-cache');

$post = [
    'file' => 'test.docx',
    'token' => $token,
];
$token = 'HH89VOiirgXlCdEqDrFs';
$url = 'http://localhost/snippets/PHP/download.php';

$ch = curl_init();

curl_setopt_array($ch, [
    CURLOPT_ENCODING => 'UTF-8',
    CURLOPT_FRESH_CONNECT => true,
    CURLOPT_POST => 1,
    CURLOPT_POSTFIELDS => http_build_query($post),
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_URL => $url,
]);

$result = curl_exec($ch);

switch ($result) {
    case 'bad token':{
            curl_close($ch);
            exit('check token in ' . $url);
        }break;

    case 'file not found':{
            curl_close($ch);
            exit('file not found in target server.');
        }break;

    default:{
            header('Content-Disposition: attachment; filename="' . $post['file']);
            echo $result;
        }
}
curl_close($ch);
