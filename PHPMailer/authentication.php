<?php
include '../vendor/autoload.php';

use PHPMailer\PHPMailer\PHPMailer;

$from = '';
$message = 'vvvvvvvvv';
$smtp_host = 'smtp.gmail.com';
$smtp_password = 'xx5QMobw0rFG';
$smtp_port = 587;
$smtp_username = 'phunsanit@gmail.com';
$subject = 'Authentication';
$to = 'getcrud@gmail.com';

try {
    $mail = new PHPMailer;
    //$mail->isSendmail();

    /* Server settings connect กับ smtp server */
    $mail->Host = $smtp_host;
    $mail->isSMTP();
    $mail->Password = $smtp_password;
    $mail->Port = $smtp_port;
    $mail->SMTPAuth = true;
    $mail->SMTPSecure = 'tls';
    $mail->Username = $smtp_username;

    $mail->SMTPDebug = 2;
    $mail->Debugoutput = 'html';

    $mail->addAddress($to);

    $mail->From = $smtp_username;

    $mail->IsHTML(true);
    $mail->msgHTML($message);
    $mail->Subject = $subject;

    if ($mail->send()) {
        echo 'ส่งอีเมล์สำเร็จ';
    } else {
        echo 'ส่งอีเมล์ไม่สำเร็จ';
    }
} catch (Exception $e) {
    echo 'Message could not be sent.';
    echo 'Mailer Error: ' . $mail->ErrorInfo;
}
