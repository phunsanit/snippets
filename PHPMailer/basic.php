<?php
include '../vendor/autoload.php';

use PHPMailer\PHPMailer\PHPMailer;

$attachment1 = '';
$attachment2 = '';
$bcc = '';
$cc = '';
$from = '';
$message = 'vvvvvvvvv';
$smtp_host = 'smtp.gmail.com';
$smtp_password = 'xx5QMobw0rFG';
$smtp_port = 587;
$smtp_username = 'phunsanit@gmail.com';
$subject = '';
$to = 'getcrud@gmail.com';

sendEmail($attachment1, $attachment2, $bcc, $cc, $from, $message, $subject, $to);

function sendEmail($attachment1, $attachment2, $bcc, $cc, $from, $message, $subject, $to) {
	global $smtp_host, $smtp_password, $smtp_port, $smtp_username;
	try {
		/* add style */
		$message = '<style type="text/css">
p, strong, table, tr, td, a {font-family: Arial, Helvetica, sans-serif !important;}
p, strong, table, tr, td, a {font-size: 10pt;}
</style>' . $message;

		$mail = new PHPMailer;
		//$mail->isSendmail();

		/* Server settings connect กับ smtp server */
		$mail->Host = $smtp_host;
		$mail->isSMTP();
		$mail->Password = $smtp_password;
		$mail->Port = $smtp_port;
		$mail->SMTPAuth = true;
		$mail->SMTPDebug = 2;
		$mail->SMTPSecure = 'tls';
		$mail->Username = $smtp_username;

		$mail->addAddress($to);
		//$mail->addBCC($bcc);
		//$mail->addCC($cc);

		//$mail->addAttachment($filename, $attachment2);
		//$mail->addStringAttachment(file_get_contents($attachment1), 'RenewalNotification.pdf');

		$mail->addReplyTo($smtp_username);
		$mail->From = $smtp_username;
		$mail->FromName = 'Automatic System';
		$mail->setFrom($smtp_username);

		$mail->CharSet = 'UTF-8';
		$mail->IsHTML(true);
		$mail->msgHTML($message);
		$mail->Subject = $subject;

		if ($mail->send()) {
			echo '';
		} else {
			echo '';
		}
	} catch (Exception $e) {
		echo 'Message could not be sent.';
		echo 'Mailer Error: ' . $mail->ErrorInfo;
	}
}