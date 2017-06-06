<?php
$title = 'names of included or required files';
include 'header.php';

function getPhpInfo($what)
{
    phpinfo($what);

    $backtrace = debug_backtrace();
    echo '<pre>', print_r($backtrace, true), '</pre>';
    fwrite(fopen('logs_debug_backtrace.txt', 'a+'), print_r($backtrace, true));
}

getPhpInfo(INFO_ENVIRONMENT);

include 'footer.php';
