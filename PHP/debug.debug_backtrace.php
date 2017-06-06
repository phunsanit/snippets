<?php
$title = 'names of included or required files';
include 'header.php';

function getBacktrace()
{
    return debug_backtrace();
}

$backtrace = getBacktrace();

echo '<pre>', print_r($backtrace, true), '</pre>';
fwrite(fopen('logs_debug_backtrace.txt', 'a+'), print_r($backtrace, true));

include 'footer.php';
