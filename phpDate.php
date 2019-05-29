<<<<<<< HEAD
<?php
$date = new DateTime('now');
echo '<br>วันเวลาปัจจุบัน ', $date->format('d/m/Y');
echo '<br>ถ้าเป็นที่สหรัฐจะเขียนแบบนี้ ', $date->format('m/d/Y');
$dateUS = new DateTime('now', new DateTimeZone('America/New_York'));
echo '<br>เวลาของเค้าคือ ', $dateUS->format('m/d/Y H:i:s');
echo '<br>ถ้าเป็น MySQL จะเก็บแบบนี้ ', $date->format('Y-m-d H:i:s');
echo '<br>ถ้าเป็น ISO 8601 จะเก็บแบบนี้ ', $date->format('c');
echo '<br>ถ้าเป็น Unix จะเก็บแบบนี้ ', $date->format('U');
echo '<hr>';
echo '<br>เพิ่มอีก 1 วัน ', $date->modify('+1 day')->format('d/m/Y');
echo '<br>เพิ่มอีก 7 วัน ', $date->modify('+1 day')->format('d/m/Y');
echo '<br>เพิ่มอีก 1 เดือน ', $date->modify('+1 month')->format('d/m/Y');
echo '<br>เพิ่มอีก 1 ปี ', $date->modify('+1 year')->format('d/m/Y');
echo '<hr>';
echo '<br>ลดอีก 1 วัน ', $date->modify('-1 day')->format('d/m/Y');
echo '<br>ลดอีก 7 วัน ', $date->modify('-1 day')->format('d/m/Y');
echo '<br>ลดอีก 1 เดือน ', $date->modify('-1 month')->format('d/m/Y');
echo '<br>ลดอีก 1 ปี ', $date->modify('-1 year')->format('d/m/Y');
echo '<hr>';
$timeStart = DateTime::createFromFormat('d/m/Y', '5/8/1982');
echo '<br>ฉันเกิดวันที่ ', $timeStart->format('d/m/Y');
echo '<hr>';
echo '<br>อายุ ', $timeStart->diff($date)->format('%y'), ' ปี ', $timeStart->diff($date)->format('%m'), ' เดือน ', $timeStart->diff($date)->format('%d'), ' วัน';
echo '<br>คิดอายุเป็น ', $timeStart->diff($date)->format('%a'), ' วัน';
echo '<br>ถ้าจะหากิจกรรมระหว่างวันเกิด ถึงปัจจะปัญคือ xxx BETWEEN ', $timeStart->format('Y-m-d 00:00:00'), ' AND ', $date->format('Y-m-d 23:59:59');
=======
<?php
$date = new DateTime('now');
echo '<br>วันเวลาปัจจุบัน ', $date->format('d/m/Y');
echo '<br>ถ้าเป็นที่สหรัฐจะเขียนแบบนี้ ', $date->format('m/d/Y');
$dateUS = new DateTime('now', new DateTimeZone('America/New_York'));
echo '<br>เวลาของเค้าคือ ', $dateUS->format('m/d/Y H:i:s');
echo '<br>ถ้าเป็น MySQL จะเก็บแบบนี้ ', $date->format('Y-m-d H:i:s');
echo '<br>ถ้าเป็น ISO 8601 จะเก็บแบบนี้ ', $date->format('c');
echo '<br>ถ้าเป็น Unix จะเก็บแบบนี้ ', $date->format('U');
echo '<hr>';
echo '<br>เพิ่มอีก 1 วัน ', $date->modify('+1 day')->format('d/m/Y');
echo '<br>เพิ่มอีก 7 วัน ', $date->modify('+1 day')->format('d/m/Y');
echo '<br>เพิ่มอีก 1 เดือน ', $date->modify('+1 month')->format('d/m/Y');
echo '<br>เพิ่มอีก 1 ปี ', $date->modify('+1 year')->format('d/m/Y');
echo '<hr>';
echo '<br>ลดอีก 1 วัน ', $date->modify('-1 day')->format('d/m/Y');
echo '<br>ลดอีก 7 วัน ', $date->modify('-1 day')->format('d/m/Y');
echo '<br>ลดอีก 1 เดือน ', $date->modify('-1 month')->format('d/m/Y');
echo '<br>ลดอีก 1 ปี ', $date->modify('-1 year')->format('d/m/Y');
echo '<hr>';
$timeStart = DateTime::createFromFormat('d/m/Y', '5/8/1982');
echo '<br>ฉันเกิดวันที่ ', $timeStart->format('d/m/Y');
echo '<hr>';
echo '<br>อายุ ', $timeStart->diff($date)->format('%y'), ' ปี ', $timeStart->diff($date)->format('%m'), ' เดือน ', $timeStart->diff($date)->format('%d'), ' วัน';
echo '<br>คิดอายุเป็น ', $timeStart->diff($date)->format('%a'), ' วัน';
echo '<br>ถ้าจะหากิจกรรมระหว่างวันเกิด ถึงปัจจะปัญคือ xxx BETWEEN ', $timeStart->format('Y-m-d 00:00:00'), ' AND ', $date->format('Y-m-d 23:59:59');
>>>>>>> no message
