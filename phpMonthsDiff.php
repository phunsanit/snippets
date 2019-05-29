<<<<<<< HEAD
<?php

$dateRanges = [
    ['01/02/2016', '01/03/2016'],
    ['01/02/2016', '01/04/2016'],
    ['01/11/2013', '30/11/2013'],
    ['01/01/2013', '31/12/2013'],
    ['31/01/2011', '28/02/2011'],
    ['01/09/2009', '01/05/2010'],
    ['01/01/2013', '31/03/2013'],
    ['15/02/2013', '15/04/2013'],
    ['01/02/1985', '31/12/2013'],
];

foreach ($dateRanges as $range) {
    list($dateStart, $dateEnd) = $range;

    $timeStart = DateTime::createFromFormat('d/m/Y', $dateStart);
    $timeEnd = DateTime::createFromFormat('d/m/Y', $dateEnd);

    $months = $timeStart->diff($timeEnd)->format('%m');

    echo '<br>', $dateStart, ' => ', $dateEnd, ' = ', $months, ' months';
}
echo '<hr>';
foreach ($dateRanges as $range) {
    list($dateStart, $dateEnd) = $range;

    $timeStart = DateTime::createFromFormat('d/m/Y', $dateStart);
    $timeEnd = DateTime::createFromFormat('d/m/Y', $dateEnd);

    $months = abs(($timeEnd->format('Y') - $timeStart->format('Y')) * 12 + ($timeEnd->format('m') - $timeStart->format('m')));

    echo '<br>', $dateStart, ' => ', $dateEnd, ' = ', $months, ' months';
}
=======
<?php

$dateRanges = [
    ['01/02/2016', '01/03/2016'],
    ['01/02/2016', '01/04/2016'],
    ['01/11/2013', '30/11/2013'],
    ['01/01/2013', '31/12/2013'],
    ['31/01/2011', '28/02/2011'],
    ['01/09/2009', '01/05/2010'],
    ['01/01/2013', '31/03/2013'],
    ['15/02/2013', '15/04/2013'],
    ['01/02/1985', '31/12/2013'],
];

foreach ($dateRanges as $range) {
    list($dateStart, $dateEnd) = $range;

    $timeStart = DateTime::createFromFormat('d/m/Y', $dateStart);
    $timeEnd = DateTime::createFromFormat('d/m/Y', $dateEnd);

    $months = $timeStart->diff($timeEnd)->format('%m');

    echo '<br>', $dateStart, ' => ', $dateEnd, ' = ', $months, ' months';
}
echo '<hr>';
foreach ($dateRanges as $range) {
    list($dateStart, $dateEnd) = $range;

    $timeStart = DateTime::createFromFormat('d/m/Y', $dateStart);
    $timeEnd = DateTime::createFromFormat('d/m/Y', $dateEnd);

    $months = abs(($timeEnd->format('Y') - $timeStart->format('Y')) * 12 + ($timeEnd->format('m') - $timeStart->format('m')));

    echo '<br>', $dateStart, ' => ', $dateEnd, ' = ', $months, ' months';
}
>>>>>>> no message
