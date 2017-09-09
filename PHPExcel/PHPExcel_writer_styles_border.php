<?php

/* http://stackoverflow.com/questions/27764204/how-to-do-the-phpexcel-outside-border */
/* PHPExcel_IOFactory - Reader */
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

/* add background */
$background = [
    'fill' => [
        'color' => [
            'rgb' => 'FF9',
        ],
        'type' => PHPExcel_Style_Fill::FILL_SOLID,
    ],
];

$borders = [
    'allborders' => [
        'borders' => [
            'allborders' => [
                'style' => PHPExcel_Style_Border::BORDER_HAIR,
            ],
        ],
    ],
    'bottom' => [
        'borders' => [
            'bottom' => [
                'style' => PHPExcel_Style_Border::BORDER_HAIR,
            ],
        ],
    ],
    'diagonal (both)' => [
        'borders' => [
            'diagonal' => [
                'style' => PHPExcel_Style_Border::BORDER_HAIR,
            ],
            'diagonaldirection' => PHPExcel_Style_Borders::DIAGONAL_BOTH,
        ],
    ],
    'diagonal (down)' => [
        'borders' => [
            'diagonal' => [
                'style' => PHPExcel_Style_Border::BORDER_HAIR,
            ],
            'diagonaldirection' => PHPExcel_Style_Borders::DIAGONAL_DOWN,
        ],
    ],
    'diagonal (none)' => [
        'borders' => [
            'diagonal' => [
                'style' => PHPExcel_Style_Border::BORDER_HAIR,
            ],
            'diagonaldirection' => PHPExcel_Style_Borders::DIAGONAL_NONE,
        ],
    ],
    'diagonal (up)' => [
        'borders' => [
            'diagonal' => [
                'style' => PHPExcel_Style_Border::BORDER_HAIR,
            ],
            'diagonaldirection' => PHPExcel_Style_Borders::DIAGONAL_UP,
        ],
    ],
    'horizontal' => [
        'borders' => [
            'horizontal' => [
                'style' => PHPExcel_Style_Border::BORDER_HAIR,
            ],
        ],
    ],
    'inside' => [
        'borders' => [
            'inside' => [
                'style' => PHPExcel_Style_Border::BORDER_HAIR,
            ],
        ],
    ],
    'left' => [
        'borders' => [
            'left' => [
                'style' => PHPExcel_Style_Border::BORDER_HAIR,
            ],
        ],
    ],
    'outline' => [
        'borders' => [
            'outline' => [
                'style' => PHPExcel_Style_Border::BORDER_HAIR,
            ],
        ],
    ],
    'right' => [
        'borders' => [
            'right' => [
                'style' => PHPExcel_Style_Border::BORDER_HAIR,
            ],
        ],
    ],
    'top' => [
        'borders' => [
            'top' => [
                'style' => PHPExcel_Style_Border::BORDER_HAIR,
            ],
        ],
    ],
    'vertical' => [
        'borders' => [
            'vertical' => [
                'style' => PHPExcel_Style_Border::BORDER_HAIR,
            ],
        ],
    ],
];

$bordersLine = [
    'BORDER_DASHDOT' => [
        'borders' => [
            'allborders' => [
                'style' => PHPExcel_Style_Border::BORDER_DASHDOT,
            ],
        ],
    ],
    'BORDER_DASHDOTDOT' => [
        'borders' => [
            'allborders' => [
                'style' => PHPExcel_Style_Border::BORDER_DASHDOTDOT,
            ],
        ],
    ],
    'BORDER_DASHED' => [
        'borders' => [
            'allborders' => [
                'style' => PHPExcel_Style_Border::BORDER_DASHED,
            ],
        ],
    ],
    'BORDER_DOTTED' => [
        'borders' => [
            'allborders' => [
                'style' => PHPExcel_Style_Border::BORDER_DOTTED,
            ],
        ],
    ],
    'BORDER_DOUBLE' => [
        'borders' => [
            'allborders' => [
                'style' => PHPExcel_Style_Border::BORDER_DOUBLE,
            ],
        ],
    ],
    'BORDER_HAIR' => [
        'borders' => [
            'allborders' => [
                'style' => PHPExcel_Style_Border::BORDER_HAIR,
            ],
        ],
    ],
    'BORDER_MEDIUM' => [
        'borders' => [
            'allborders' => [
                'style' => PHPExcel_Style_Border::BORDER_MEDIUM,
            ],
        ],
    ],
    'BORDER_MEDIUMDASHDOT' => [
        'borders' => [
            'allborders' => [
                'style' => PHPExcel_Style_Border::BORDER_MEDIUMDASHDOT,
            ],
        ],
    ],
    'BORDER_MEDIUMDASHDOTDOT' => [
        'borders' => [
            'allborders' => [
                'style' => PHPExcel_Style_Border::BORDER_MEDIUMDASHDOTDOT,
            ],
        ],
    ],
    'BORDER_MEDIUMDASHED' => [
        'borders' => [
            'allborders' => [
                'style' => PHPExcel_Style_Border::BORDER_MEDIUMDASHED,
            ],
        ],
    ],
    'BORDER_NONE' => [
        'borders' => [
            'allborders' => [
                'style' => PHPExcel_Style_Border::BORDER_NONE,
            ],
        ],
    ],
    'BORDER_SLANTDASHDOT' => [
        'borders' => [
            'allborders' => [
                'style' => PHPExcel_Style_Border::BORDER_SLANTDASHDOT,
            ],
        ],
    ],
    'BORDER_THICK' => [
        'borders' => [
            'allborders' => [
                'style' => PHPExcel_Style_Border::BORDER_THICK,
            ],
        ],
    ],
    'BORDER_THIN' => [
        'borders' => [
            'allborders' => [
                'style' => PHPExcel_Style_Border::BORDER_THIN,
            ],
        ],
    ],

];

$objWorkSheet->setCellValue('C1', 'Borders');
$objWorkSheet->getStyle('C1')->getFont()->setBold(true);
$rowNo = -1;
foreach ($borders as $name => $style) {
    $rowNo += 4;

    $objWorkSheet->setCellValue('A' . $rowNo, $name);

    /* merge background */
    $style = array_merge($background, $style);

    $objWorkSheet->getStyle('D' . $rowNo . ':F' . ($rowNo + 2))->applyFromArray($style);

}

$objWorkSheet->getStyle('G3:G53')->applyFromArray($borders['right']);

$objWorkSheet->setCellValue('M1', 'Line');
$objWorkSheet->getStyle('M1')->getFont()->setBold(true);
$rowNo = 1;
foreach ($bordersLine as $name => $style) {
    $rowNo += 2;

    $objWorkSheet->setCellValue('I' . $rowNo, $name);

    /* merge background */
    $style = array_merge($background, $style);

    $objWorkSheet->getStyle('N' . $rowNo)->applyFromArray($style);
}

/* write */
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel2007');
header('Cache-Control: max-age=0');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Cache-Control: post-check=0, pre-check=0', false);
header('Content-Disposition: attachment;filename="' . $title . '.xlsx"');
header('Content-Type: application/vnd.ms-excel');
header('Pragma: no-cache');
$objWriter->save('php://output');
