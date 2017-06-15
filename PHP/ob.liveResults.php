<?php
header('X-Accel-Buffering: no');

set_time_limit(0);

ob_implicit_flush(true);
ob_end_flush();

$steps = 100;
for ($step = 1; $step <= $steps; $step++) {
    $time = rand(1, 10);
    sleep($time);
    echo '<br>ขั้นตอนที่ ', $step, ' จาก ', $steps, ' ใช้เวลาทำงาน ', $time, ' วินาที';
}
