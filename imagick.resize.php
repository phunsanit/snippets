<?php
$original = 'D:/xampp/htdocs/snippets/assets/output.png';



$im = new Imagick();
 
/* Read the image file */
$im->readImage($original);
 
/* Thumbnail the image ( width 100, preserve dimensions ) */
$im->thumbnailImage( 100, null );
 
/* Write the thumbail to disk */
$im->writeImage( 'D:/xampp/htdocs/snippets/assets/th_test.png' );
 
/* Free resources associated to the Imagick object */
$im->destroy();
exit();

function createThumbnail($originalImage)
{
    $originalInfo = getimagesize($originalImage);
print_r($originalInfo);
    $originalWidth = $originalInfo[0];
    $originalHeight = $originalInfo[1];

    $originalRatio = $originalWidth / $originalHeight;

    echo '$originalRatio = ' . $originalRatio;

    $imagick = new Imagick(realpath($originalImage));
    $imagick->scaleImage($originalWidth, $originalHeight, true);
    header('Content-Type: ' . $originalInfo['mime']);
    echo $imagick->getImageBlob();

}

createThumbnail($original);

exit();
//Array ( [0] => 960 [1] => 720 [2] => 2 [3] => width="960" height="720" [bits] => 8 [channels] => 3 [mime] => image/jpeg )
// /Fatal error: Uncaught ImagickException: NoDecodeDelegateForThisImageFormat `JPEG' @ error/constitute.c/ReadImage/501

if ($mime['mime'] == 'image/png') {
    $src_img = imagecreatefrompng($path);
}
if ($mime['mime'] == 'image/jpg' || $mime['mime'] == 'image/jpeg' || $mime['mime'] == 'image/pjpeg') {
    $src_img = imagecreatefromjpeg($path);
}

$old_x = imageSX($src_img);
$old_y = imageSY($src_img);

if ($old_x > $old_y) {
    $thumb_w = $new_width;
    $thumb_h = $old_y * ($new_height / $old_x);
}

if ($old_x < $old_y) {
    $thumb_w = $old_x * ($new_width / $old_y);
    $thumb_h = $new_height;
}

if ($old_x == $old_y) {
    $thumb_w = $new_width;
    $thumb_h = $new_height;
}

$dst_img = ImageCreateTrueColor($thumb_w, $thumb_h);

imagecopyresampled($dst_img, $src_img, 0, 0, 0, 0, $thumb_w, $thumb_h, $old_x, $old_y);

// New save location
$new_thumb_loc = $moveToDir . $image_name;

if ($mime['mime'] == 'image/png') {
    $result = imagepng($dst_img, $new_thumb_loc, 8);
}
if ($mime['mime'] == 'image/jpg' || $mime['mime'] == 'image/jpeg' || $mime['mime'] == 'image/pjpeg') {
    $result = imagejpeg($dst_img, $new_thumb_loc, 80);
}

imagedestroy($dst_img);
imagedestroy($src_img);

return $result;
