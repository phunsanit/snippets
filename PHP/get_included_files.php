<?php
$title = 'names of included or required files';
include 'header.php';

$files = get_included_files();
echo '<pre>', print_r($files, true), '</pre>';
fwrite(fopen('logs_get_included_files.txt', 'a+'), print_r($files, true));

include 'footer.php';
