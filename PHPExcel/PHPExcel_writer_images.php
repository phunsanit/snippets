<?php

include '../vendor/phpoffice/phpexcel/Classes/PHPExcel.php';

$objPHPExcel = new PHPExcel();

/* Set default style */
$defaultStyle = $objPHPExcel->getDefaultStyle();

$defaultStyle->getFont()
    ->setName('Arial')
    ->setSize(11);

/* Set document properties */
$title = 'Exports_Datas_' . date('Y-m-d_H:i');
$objPHPExcel->getProperties()->setCreator('Pitt Phunsanit')
    ->setCategory('Exports Datas')
    ->setDescription($title)
    ->setKeywords('Exports Datas ' . date('Y-m-d'))
    ->setSubject($title)
    ->setTitle($title);

/* rename sheet */
$objWorkSheet = $objPHPExcel->getActiveSheet();
$objWorkSheet->setTitle('Exports Datas');

/* image path */
$images = [
    'https://raw.githubusercontent.com/PHPOffice/PHPExcel/1.8/Examples/images/officelogo.jpg',
    'https://raw.githubusercontent.com/PHPOffice/PHPExcel/1.8/Examples/images/paid.png',
    'https://raw.githubusercontent.com/PHPOffice/PHPExcel/1.8/Examples/images/phpexcel_logo.gif',
    'https://raw.githubusercontent.com/PHPOffice/PHPExcel/1.8/Examples/images/termsconditions.jpg',
    'vendor/phpoffice/phpexcel/Examples/images/officelogo.jpg',
    'vendor/phpoffice/phpexcel/Examples/images/paid.png',
    'vendor/phpoffice/phpexcel/Examples/images/phpexcel_logo.gif',
    'vendor/phpoffice/phpexcel/Examples/images/termsconditions.jpg',
];

$rowNo = 0;
foreach ($images as $image) {
    $rowNo++;

    $coordinate = 'A' . $rowNo;

    $objWorkSheet->getRowDimension($rowNo)->setRowHeight(90);
    $objWorkSheet->setCellValue($coordinate, $image);

    switch (strtolower(pathinfo($image, PATHINFO_EXTENSION))) {
        case 'gif':
            $gdImage = imagecreatefromgif($image);
            $mimetype = PHPExcel_Worksheet_MemoryDrawing::MIMETYPE_GIF;
            $render = PHPExcel_Worksheet_MemoryDrawing::RENDERING_GIF;
            break;

        case 'jpeg':
        case 'jpg':
            $gdImage = imagecreatefromjpeg($image);
            $mimetype = PHPExcel_Worksheet_MemoryDrawing::MIMETYPE_JPEG;
            $render = PHPExcel_Worksheet_MemoryDrawing::RENDERING_JPEG;
            break;

        case 'png':
            $gdImage = imagecreatefrompng($image);
            $mimetype = PHPExcel_Worksheet_MemoryDrawing::MIMETYPE_PNG;
            $render = PHPExcel_Worksheet_MemoryDrawing::RENDERING_PNG;
            break;
    }

    $objDrawing = new PHPExcel_Worksheet_MemoryDrawing();

    $objDrawing->setCoordinates($coordinate);
    $objDrawing->setImageResource($gdImage);
    $objDrawing->setWorksheet($objWorkSheet);

    /* optional */
    $objDrawing->setDescription($image);
    $objDrawing->setMimeType($mimetype);
    $objDrawing->setName(pathinfo($image, PATHINFO_FILENAME));
    $objDrawing->setRenderingFunction($render);
    $objDrawing->setResizeProportional(true);
    $objDrawing->setWidth(100);

}

$objWorkSheet->getColumnDimension('A')->setAutoSize(true);

/* write */
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel2007');
header('Content-Type: application/vnd.ms-excel');
header('Content-Disposition: attachment;filename="' . $title . '.xlsx"');
header('Cache-Control: max-age=0');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Cache-Control: post-check=0, pre-check=0', false);
header('Pragma: no-cache');
$objWriter->save('php://output');
