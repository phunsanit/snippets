<?php
$datas = [
    "aaa" => "bbb",
    "ccc" => "ddd",
    "eee" => "fff",
    "ggg" => "hhh",
];

$datas = array_merge($datas, $_REQUEST);

header('Content-Type: application/json');
echo json_encode($datas);
