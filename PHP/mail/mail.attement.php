<?php

$filename = 'myfile';
$path = 'your path goes here';
$file = $path . "/" . $filename;

// main header (multipart mandatory)
$headers = "From: name <test@test.com>" . $eol;
$headers .= "MIME-Version: 1.0" . $eol;
$headers .= "Content-Type: multipart/mixed; boundary=\"" . $separator . "\"" . $eol;
$headers .= "Content-Transfer-Encoding: 7bit" . $eol;
$headers .= "This is a MIME encoded message." . $eol;




$message = 'เคยได้ยินไหม ที่ใครเคยบอกว่ารัก....เป็นดั่งรองเท้าคู่หนึ่งฉันได้ลองหา เพื่อมีวันหนึ่งที่ฉัน....ได้เจอรองเท้าที่ถูกใจบางทีก็ดูคับเกินไป บางที่ไม่เหมาะสมกับฉัน... ซักเท่าไหร่จนได้มาพบได้เจอรองเท้าคู่หนึ่ง... ที่ดูแล้วเข้ากับฉันมาถึงวันนี้... ก้าวเดินด้วยกันก็นาน... และตัวฉันยังพอใจบางคนบอกไม่สวยเท่าไหร่ แต่นี่คือที่ฉันมั่นใจ* ว่าฉันไม่เคยจะเปลี่ยนใจจากรองเท้าที่ฉันใส่อาจจะดูว่าเก่าเกินไปแต่ฉันก็ผูกพัน ตื่นเช้าขึ้นมา ก็ใส่เดินไป ก้าวไปกับฉันได้ออกไปเจอกับสิ่งดีดี ที่มีด้วยกัน ..... ตลอดไปแม้หนทางที่เดินไป มันจะดูไม่ง่ายดาย แต่ฉันก็ยังจะก้าวไปกับรองเท้าคู่ใจของฉัน .... ต่อไปบางทีก็ดูคับเกินไป บางที่ไม่เหมาะสมกับฉันบางคนบอกไม่สวยเท่าไหร่ แต่นี่คือที่ฉันมั่นใจ(*) ได้ออกไปเจอกับสิ่งดีดี ที่มีด้วยกัน..... ตลอดไปเคยได้ยินไหมที่ใครเคยบอกว่ารักเป็นดั่งรองเท้าคู่หนึ่ง';
$subject = 'ความรักกับรองเท้า';
$to = 'phunsanit@gmail.com';

$content = file_get_contents($file);
$content = chunk_split(base64_encode($content));

// a random hash will be necessary to send mixed content
$separator = md5(time());

// carriage return type (RFC)
$eol = "\r\n";



// message
$message = "--" . $separator . $eol;
$message .= "Content-Type: text/plain; charset=\"iso-8859-1\"" . $eol;
$message .= "Content-Transfer-Encoding: 8bit" . $eol;
$message .= $message . $eol;

// attachment
$message .= "--" . $separator . $eol;
$message .= "Content-Type: application/octet-stream; name=\"" . $filename . "\"" . $eol;
$message .= "Content-Transfer-Encoding: base64" . $eol;
$message .= "Content-Disposition: attachment" . $eol;
$message .= $content . $eol;
$message .= "--" . $separator . "--";

if (mail($to, $subject, $message, $headers)) {
	echo 'ส่งอีเมล์แล้ว';
} else {
	echo 'ไม่สำเร็จ';
}