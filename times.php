<?php

set_time_limit(0);

header('Cache-Control: no-cache');
header('Content-Type: text/event-stream');

$times = 1000;

fwrite(fopen('pp.txt', 'a+'), "\n\n\n\n\ntimes = " . $times);

/* loop processing  */
for ($a = 1; $a <= $times; $a++) {
    $wait = rand(1, 10);
fwrite(fopen('pp.txt', 'a+'), "\n $a wait = " . $wait);
    sleep($wait);
}

task('CLOSE', 'Process complete');