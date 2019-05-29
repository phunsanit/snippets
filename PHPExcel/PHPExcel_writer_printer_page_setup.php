<<<<<<< HEAD
<?php

include '../vendor/phpoffice/phpexcel/Classes/PHPExcel.php';

$objPHPExcel = new PHPExcel();

/* Set default style */
$defaultStyle = $objPHPExcel->getDefaultStyle();

$defaultStyle->getFont()
    ->setName('Arial')
    ->setSize(11);

$defaultStyle->getNumberFormat()
    ->setFormatCode('yyyy-mm-dd');

/* Set document properties */
$title = 'Exports_Datas_' . date('Y-m-d_H:i');
$objPHPExcel->getProperties()->setCreator('Pitt Phunsanit')
    ->setCategory('Exports Datas')
    ->setDescription($title)
    ->setKeywords('Exports Datas ' . date('Y-m-d'))
    ->setSubject($title)
    ->setTitle($title);

/* create new sheet */
$objWorkSheet = $objPHPExcel->getActiveSheet();
$objWorkSheet->setTitle('Exports Datas');

/*
printer page setup
https://github.com/PHPOffice/PHPExcel/blob/develop/Documentation/markdown/Overview/08-Recipes.md
 */

/* print header and footer of a worksheet */
$objWorkSheet->getHeaderFooter()->setOddFooter('&L&B' . $objPHPExcel->getProperties()->getTitle() . '&RPage &P of &N');
$objWorkSheet->getHeaderFooter()->setOddHeader('&C&HPlease treat this document as confidential!');

/* page margins */
$objWorkSheet->getPageMargins()->setBottom(1);
$objWorkSheet->getPageMargins()->setLeft(0.75);
$objWorkSheet->getPageMargins()->setRight(0.75);
$objWorkSheet->getPageMargins()->setTop(1);

/* Setting a worksheet's page orientation and size */
$objWorkSheet->getPageSetup()->setFitToPage(true);
$objWorkSheet->getPageSetup()->setFitToWidth(true);
$objWorkSheet->getPageSetup()->setHorizontalCentered(true);
$objWorkSheet->getPageSetup()->setOrientation(PHPExcel_Worksheet_PageSetup::ORIENTATION_LANDSCAPE);
$objWorkSheet->getPageSetup()->setPaperSize(PHPExcel_Worksheet_PageSetup::PAPERSIZE_A4);

/* Specify printing area */
$objWorkSheet->getPageSetup()->setPrintArea('A1:E11');

/* add demo data */
for ($rowNo = 1; $rowNo < 10; $rowNo++) {
    for ($colNo = 0; $colNo < 5; $colNo++) {

        $colString = PHPExcel_Cell::stringFromColumnIndex($colNo);

        $coordinate = $colString . $rowNo;

        $objWorkSheet->setCellValue($coordinate, 'Add Data To ' . $coordinate);
    }
}

/* auto width column */
$cellIterator = $objWorkSheet->getRowIterator()->current()->getCellIterator();
$cellIterator->setIterateOnlyExistingCells(true);
foreach ($cellIterator as $cell) {
    $objWorkSheet->getColumnDimension($cell->getColumn())->setAutoSize(true);
}

/* write */
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel2007');
header('Content-Type: application/vnd.ms-excel');
header('Content-Disposition: attachment;filename="' . $title . '.xlsx"');
header('Cache-Control: max-age=0');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Cache-Control: post-check=0, pre-check=0', false);
header('Pragma: no-cache');
$objWriter->save('php://output');
=======
<?php

include '../vendor/phpoffice/phpexcel/Classes/PHPExcel.php';

$objPHPExcel = new PHPExcel();

/* Set default style */
$defaultStyle = $objPHPExcel->getDefaultStyle();

$defaultStyle->getFont()
    ->setName('Arial')
    ->setSize(11);

$defaultStyle->getNumberFormat()
    ->setFormatCode('yyyy-mm-dd');

/* Set document properties */
$title = 'Exports_Datas_' . date('Y-m-d_H:i');
$objPHPExcel->getProperties()->setCreator('Pitt Phunsanit')
    ->setCategory('Exports Datas')
    ->setDescription($title)
    ->setKeywords('Exports Datas ' . date('Y-m-d'))
    ->setSubject($title)
    ->setTitle($title);

/* create new sheet */
$objWorkSheet = $objPHPExcel->getActiveSheet();
$objWorkSheet->setTitle('Exports Datas');

/*
printer page setup
https://github.com/PHPOffice/PHPExcel/blob/develop/Documentation/markdown/Overview/08-Recipes.md
 */

/* print header and footer of a worksheet */
$objWorkSheet->getHeaderFooter()->setOddFooter('&L&B' . $objPHPExcel->getProperties()->getTitle() . '&RPage &P of &N');
$objWorkSheet->getHeaderFooter()->setOddHeader('&C&HPlease treat this document as confidential!');

/* page margins */
$objWorkSheet->getPageMargins()->setBottom(1);
$objWorkSheet->getPageMargins()->setLeft(0.75);
$objWorkSheet->getPageMargins()->setRight(0.75);
$objWorkSheet->getPageMargins()->setTop(1);

/* Setting a worksheet's page orientation and size */
$objWorkSheet->getPageSetup()->setFitToPage(true);
$objWorkSheet->getPageSetup()->setFitToWidth(true);
$objWorkSheet->getPageSetup()->setHorizontalCentered(true);
$objWorkSheet->getPageSetup()->setOrientation(PHPExcel_Worksheet_PageSetup::ORIENTATION_LANDSCAPE);
$objWorkSheet->getPageSetup()->setPaperSize(PHPExcel_Worksheet_PageSetup::PAPERSIZE_A4);

/* Specify printing area */
$objWorkSheet->getPageSetup()->setPrintArea('A1:E11');

/* add demo data */
for ($rowNo = 1; $rowNo < 10; $rowNo++) {
    for ($colNo = 0; $colNo < 5; $colNo++) {

        $colString = PHPExcel_Cell::stringFromColumnIndex($colNo);

        $coordinate = $colString . $rowNo;

        $objWorkSheet->setCellValue($coordinate, 'Add Data To ' . $coordinate);
    }
}

/* auto width column */
$cellIterator = $objWorkSheet->getRowIterator()->current()->getCellIterator();
$cellIterator->setIterateOnlyExistingCells(true);
foreach ($cellIterator as $cell) {
    $objWorkSheet->getColumnDimension($cell->getColumn())->setAutoSize(true);
}

/* write */
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel2007');
header('Content-Type: application/vnd.ms-excel');
header('Content-Disposition: attachment;filename="' . $title . '.xlsx"');
header('Cache-Control: max-age=0');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Cache-Control: post-check=0, pre-check=0', false);
header('Pragma: no-cache');
$objWriter->save('php://output');
>>>>>>> no message
