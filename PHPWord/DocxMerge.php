<?php
ini_set('max_execution_time', 0);
ini_set('memory_limit', '-1');

include '../vendor/autoload.php';
use DocxMerge\DocxMerge;

$fileName = 'result_' . date('Y-m-d_H-i-s') . '.docx';
$fileNameTemp = sys_get_temp_dir() . $fileName;
$templates = [
    'header.docx',
    'body.docx',
    'footer.docx',
];

/* merge document */
$dm = new DocxMerge();
$dm->merge($templates, $fileNameTemp);

/* download */
header('Content-Description: File Transfer');
header('Content-Disposition: attachment; filename="' . $fileName . '"');
header('Content-Type: application/vnd.openxmlformats-officedocument.wordprocessingml.document');
header('Content-Transfer-Encoding: binary');
header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
header('Expires: 0');
readfile($fileNameTemp);
