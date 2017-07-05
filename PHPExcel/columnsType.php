<?php

include '../vendor/phpoffice/phpexcel/Classes/PHPExcel.php';

set_time_limit(0);

$objPHPExcel = new PHPExcel();

/* Set default style */
$defaultStyle = $objPHPExcel->getDefaultStyle();

$defaultStyle->getFont()
    ->setName('Arial')
    ->setSize(11);

$defaultStyle->getNumberFormat()
    ->setFormatCode('yyyy-mm-dd');

/* Set document properties */
$title = 'columnsType_' . date('Y-m-d_H:i');
$objPHPExcel->getProperties()->setCreator('CMS')
    ->setCategory('Exports Datas')
    ->setDescription($title)
    ->setKeywords('Exports Datas ' . date('Y-m-d'))
    ->setSubject($title)
    ->setTitle($title);

/* create new sheet */
$objWorkSheet = $objPHPExcel->getActiveSheet();
$objWorkSheet->setTitle('Exports Datas');

$columns = [
    'row_number' => ['title' => 'No.', 'type' => 'row_number'],

    'price' => ['title' => 'ราคา', 'type' => 'currency'],

    'dateEnd' => ['title' => 'เริ่มจำหน่าย', 'type' => 'date'],
    'dateStart' => ['title' => 'เริ่มจำหน่าย', 'type' => 'date'],

    'dateApproved' => ['title' => 'เวลาอนุมัติ', 'type' => 'datetime'],

    'height' => ['title' => 'สูง (เมตร)', 'type' => 'float'],
    'width' => ['title' => 'กว้าง (เมตร)', 'type' => 'float'],

    'calculate' => ['title' => 'สูตรคํานวณหวย', 'type' => 'formula'],

    'image' => ['title' => 'ภาพ', 'type' => 'image'],

    'items' => ['title' => 'จำนวน', 'type' => 'integer'],

    'productName' => ['title' => 'ชื่อสินค้า', 'type' => 'string'],

    'timeEnd' => ['title' => 'เวลาขาย', 'type' => 'time'],
    'timeStart' => ['title' => 'เวลาปิดการขาย', 'type' => 'time'],

    'url' => ['title' => 'page', 'type' => 'url'],
];

/* header */
$colNo = -1;
$rowNo = 1;
$colStrings = [];
foreach ($columns as $fieldId => $field) {
    $colNo++;
    $colStrings[$colNo] = $colString = PHPExcel_Cell::stringFromColumnIndex($colNo);
    $objWorkSheet->setCellValue($colString . '1', $field['title']);
    $objWorkSheet->setCellValue($colString . '2', 'type = ' . $field['type']);
}
$headerHeight = $rowNo = 2;

$objPHPExcel->getActiveSheet()->freezePane($colString . ($headerHeight + 1));

/* random data */
$datas = [];
for ($a = 0; $a < 10; $a++) {
    $temp = [];

    $temp['calculate'] = '=RAND()';
    $temp['dateApproved'] = date(DATE_ISO8601, mt_rand(0, 1499291999));
    $temp['dateEnd'] = date('Y-m-d', mt_rand(0, 1499291999));
    $temp['dateStart'] = date('Y-m-d', mt_rand(0, 1499291999));
    $temp['height'] = mt_rand(0, 10) / 10;
    $temp['image'] = 'http://lorempixel.com/400/200/sports/?st=' . mt_rand(1, 500);
    $temp['items'] = mt_rand(999, 9999999);
    $temp['price'] = mt_rand(100, 10000);
    $temp['productName'] = substr(str_shuffle(str_repeat($x = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', ceil(10 / strlen($x)))), 1, 10);
    $temp['timeEnd'] = date('H:i:s', mt_rand(0, 1499291999));
    $temp['timeStart'] = date('H:i:s', mt_rand(0, 1499291999));
    $temp['url'] = 'https://plusmagi.com/?s=' . mt_rand(1, 500);
    $temp['width'] = mt_rand(0, 10) / 10;

    array_push($datas, $temp);
}

/* add data */
$row_number = 0;
foreach ($datas as $item) {
    $colNo = -1;
    $row_number++;
    $rowNo++;
    foreach ($columns as $fieldId => $field) {
        $colNo++;

        $coordinate = $colStrings[$colNo] . $rowNo;

        switch ($field['type']) {
            case 'date':
            case 'datetime':
            case 'time':{
                    $ts = strtotime($item[$fieldId]);
                    $value = PHPExcel_Shared_Date::PHPToExcel($ts);
                }break;

            case 'image':{
                    $value = $item[$fieldId];

                    $gdImage = imagecreatefromjpeg($value);
                    $objDrawing = new PHPExcel_Worksheet_MemoryDrawing(); /*create object for Worksheet drawing*/

                    $objDrawing->setCoordinates($coordinate); /*set image to cell*/
                    $objDrawing->setDescription('Customer Signature'); /*set description to image*/
                    $objDrawing->setHeight(50);
                    $objDrawing->setImageResource($gdImage);
                    $objDrawing->setName('Customer Signature'); /*set name to image*/
                    $objDrawing->setOffsetX(25); /*setOffsetX works properly*/
                    $objDrawing->setOffsetY(10); /*setOffsetY works properly*/
                    $objDrawing->setWidth(100); /*set width, height*/

                    $objDrawing->setWorksheet($objWorkSheet); /*save*/

                    $objWorkSheet->getRowDimension($rowNo)->setRowHeight(60); /* set row height*/
                }break;

            case 'row_number':{
                    $value = $row_number;
                }break;

            case 'url':{
                    $value = str_replace('http://', '', $item[$fieldId]);
                    $objWorkSheet->getCell($coordinate)
                        ->getHyperlink()
                        ->setTooltip('Click here to access page')
                        ->setUrl($item[$fieldId]);
                }break;

            default:{
                    $value = $item[$fieldId];
                }break;
        }

        $objWorkSheet->setCellValue($coordinate, $value);
    }
}

/* auto width column */
$cellIterator = $objWorkSheet->getRowIterator()->current()->getCellIterator();
$cellIterator->setIterateOnlyExistingCells(true);
foreach ($cellIterator as $cell) {
    $objWorkSheet->getColumnDimension($cell->getColumn())->setAutoSize(true);
}

/* format for columns */
$colNo = -1;
foreach ($columns as $fieldId => $field) {
    $colNo++;

    $coordinate = $colStrings[$colNo] . ($headerHeight + 1) . ':' . $colStrings[$colNo] . $rowNo;

    switch ($field['type']) {

        case 'currency':{
                $objWorkSheet->getStyle($coordinate)
                    ->getNumberFormat()
                    ->setFormatCode('#,##0.00');
                /*->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER);*/
            }break;

        case 'date':{
                $objWorkSheet->getStyle($coordinate)
                    ->getNumberFormat()
                    ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_DATE_DMYSLASH);
            }break;

        case 'datetime':{
                $objWorkSheet->getStyle($coordinate)
                    ->getNumberFormat()
                    ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_DATE_DATETIME);
                /*->setFormatCode('Y-m-d H:i:s');*/
            }break;

        case 'float':{
                $objWorkSheet->getStyle($coordinate)
                    ->getNumberFormat()
                    ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
            }break;

        case 'integer':
        case 'row_number':{
                $objWorkSheet->getStyle($coordinate)
                    ->getNumberFormat()
                    ->setFormatCode('#,##');
            }break;

        case 'time':{
                $objWorkSheet->getStyle($coordinate)
                    ->getNumberFormat()
                    ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_DATE_TIME4);
                /*->setFormatCode('Y-m-d H:i:s');*/
            }break;

        default:{
                $objWorkSheet->getStyle($coordinate)
                    ->getNumberFormat()
                    ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_GENERAL);
            }break;
    }

}

$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel2007');
header('Content-Type: application/vnd.ms-excel');
header('Content-Disposition: attachment;filename="' . $title . '.xlsx"');
header('Cache-Control: max-age=0');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Cache-Control: post-check=0, pre-check=0', false);
header('Pragma: no-cache');
$objWriter->save('php://output');
