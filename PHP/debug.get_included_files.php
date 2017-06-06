<?php
$title = 'names of included or required files';
include 'header.php';

function getIncludedFiles()
{
    $files = get_included_files();
    echo '<pre>', print_r($files, true), '</pre>';
    fwrite(fopen('logs_get_included_files.txt', 'a+'), "\n\n" . __FILE__ . ' :' . __LINE__ . "\n\n" . print_r($files, true));

}

getIncludedFiles();

include 'footer.php';
