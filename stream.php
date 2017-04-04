<?php

set_time_limit(0);

header('Cache-Control: no-cache');
header('Content-Type: text/event-stream');

function task($ad, $message, $progress = '')
{
    $data = [
        'id' => $ad,
        'message' => $message,
        'progress' => $progress,
    ];

    echo json_encode($data);

    ob_flush();
    flush();
}

/* loop processing  */
for ($a = 1; $a <= 10; $a++) {
    task($a, 'on iteration ' . $a . ' of 10', $a * 10);

    sleep(rand(1, 10));
}

task('CLOSE', 'Process complete');
