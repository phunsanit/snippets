<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$mail['cc'] = 'pitt@localhost.com';
$mail['from'] = 'pitt@localhost.com';
$mail['Reply-To'] = 'pitt@localhost.com';
$mail['to'] = 'pitt@localhost.com';

$subject = 'สวัสดี ทดสอบส่งอีเมล!';
$from_user = 'ผู้ใช้ Postmaster';

$subject = 'Subject: =?UTF-8?B?' . base64_encode($subject) . '?=';

$headers = 'From: ' . strip_tags($mail['to']) . "\r\n";
$headers .= 'Reply-To: ' . strip_tags($mail['Reply-To']) . "\r\n";
$headers .= 'CC: susan@example.com' . "\r\n";

$headers .= 'MIME-Version: 1.0' . "\r\n";
$headers .= 'Content-Type: text/html; charset=UTF-8' . "\r\n";

$message = '<!doctype html><html><head><meta charset="utf-8"><title>' . $subject . '</title></head><body>';
$message .= 'รายละเอียดอีเมล ทดสอบส่ง <br>';
$message .= 'ใช้งาน mercury/32 ใน xampp ส่งอีเมลใน localhost <br>';
$message .= '</body></html>';

if (mail($mail['to'], $subject, $message, $headers)) {
    echo ('ส่งอีเมลเรียบร้อยแล้ว!');
} else {
    echo ('เกิดข้อผิดพลาด...');
}
