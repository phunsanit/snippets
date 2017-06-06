<?php

function getBacktrace()
{
    $backtrace = debug_backtrace();
    echo '<pre>', print_r($backtrace, true), '</pre>';
    fwrite(fopen('logs_debug_backtrace.txt', 'a+'), "\n\n" . __FILE__ . ' :' . __LINE__ . "\n\n" . print_r($backtrace, true));
}

function getPhpInfo($what)
{
    phpinfo($what);

    /* จะดูว่า ทำไม่ getPhpInfo ถึงทำงาน */
    getBacktrace();
}

function index()
{
    getPhpInfo(INFO_ENVIRONMENT);
}

index();
