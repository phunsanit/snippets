<?php
ini_set('max_execution_time', 0);
ini_set('memory_limit', '-1');

include '../vendor/autoload.php';

use PhpOffice\PhpWord;

$title = 'Template Render ' . date('Y-m-d H:i:s');

$templateProcessor = new \PhpOffice\PhpWord\TemplateProcessor('template.docx');

/* fill data */
$templateProcessor->setValue('header', $title);

/* random data */
$scores = [];
for ($a = 0; $a < 10; $a++) {
    $scores[$a + 1] = rand(0, 100);
}

/* clone table row and fill */
$templateProcessor->cloneRow('student_id', count($scores));
foreach ($scores as $key => $value) {
    $templateProcessor->setValue('score#' . $key, htmlspecialchars($value, ENT_COMPAT, 'UTF-8'));
    $templateProcessor->setValue('student_id#' . $key, htmlspecialchars($key, ENT_COMPAT, 'UTF-8'));
}

/* add html */
$html = '<h1>Adding element via HTML</h1>';
$html .= '<p>Some well formed HTML snippet needs to be used</p>';
$html .= '<p>With for example <strong>some<sup>1</sup> <em>inline</em> formatting</strong><sub>1</sub></p>';
$html .= '<p>Unordered (bulleted) list:</p>';
$html .= '<ul><li>Item 1</li><li>Item 2</li><ul><li>Item 2.1</li><li>Item 2.1</li></ul></ul>';
$html .= '<p>Ordered (numbered) list:</p>';
$html .= '<ol><li>Item 1</li><li>Item 2</li></ol>';

\PhpOffice\PhpWord\Shared\Html::addHtml($section, $html);

header("Content-Description: File Transfer");
header('Content-Disposition: attachment; filename="' . $title . '.docx"');
header('Content-Type: application/vnd.openxmlformats-officedocument.wordprocessingml.document');
header('Content-Transfer-Encoding: binary');
header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
header('Expires: 0');
$templateProcessor->saveAs('php://output');
