<?php
$headers = 'Content-Type: text/html; charset=UTF-8';
$message = 'hello';
$subject = 'the subject';
$to = 'phunsanit@gmail.com';

if (mail($to, $subject, $message, $headers)) {
	echo 'ส่งอีเมล์แล้ว';
} else {
	echo 'ไม่สำเร็จ';
}