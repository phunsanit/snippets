<?php

/* https://datatables.net/manual/server-side */

if (isset($_REQUEST['draw'])) {
    $draw = (int) $_REQUEST['draw'];
} else {
    $draw = (int) 0;
}

if (isset($_REQUEST['length'])) {
    $pageLength = (int) $_REQUEST['length'];
} else {
    $pageLength = (int) 10;
}

if (isset($_REQUEST['page'])) {
    $page = (int) $_REQUEST['page'];
} else {
    $page = (int) 1;
}

if (isset($_REQUEST['start'])) {
    $start = (int) $_REQUEST['start'];
} else {
    $start = ($page - 1) * $pageLength;
}

$output = [
    'data' => [],
    'debug' => [
        'length' => $pageLength,
        'post' => $_REQUEST,
        'sqlCount' => '',
        'sqlResult' => '',
        'start' => $start,
    ],
    'draw' => $draw,
    'recordsFiltered' => $pageLength,
    'recordsTotal' => 0,

];

$dns = new PDO('mysql:host=localhost;dbname=snippets', 'root', '', [
    //PDO::ATTR_EMULATE_PREPARES => false,
    PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8',
]);

$condition = [];
$from = ' FROM district AS d LEFT JOIN province AS p ON d.PROVINCE_ID = p.PROVINCE_ID';
$parameters = [];
$where = '';

if (isset($_REQUEST['filters']) || isset($_REQUEST['search']['value'])) {

    if (isset($_REQUEST['search']['value'])) {
        if ($_REQUEST['search']['value'] != '') {

            $parameter = ':d_DISTRICT_NAME';

            $parameters[$parameter] = '%' . $_REQUEST['search']['value'] . '%';
            array_push($condition, 'd.DISTRICT_NAME LIKE ' . $parameter);
        }
    }

    if (isset($_REQUEST['filters'])) {
        foreach ($_REQUEST['filters'] as $tableAlias => $filter) {
            foreach ($filter as $field => $value) {
                if ($value != '') {
                    $parameter = ':' . $tableAlias . '_' . $field;

                    $parameters[$parameter] = '%' . $value . '%';
                    array_push($condition, $tableAlias . '.' . $field . ' LIKE ' . $parameter);
                }
            }
        }
    }

    if (count($parameters)) {
        $where = ' WHERE ' . implode("\n\t AND ", $condition);
    }

} else {
    $parameters = [];
    $where = '';
}

$output['debug']['parameters'] = $parameters;

$sql = 'SELECT COUNT(d.DISTRICT_ID)' . $from . $where;
try {
    $output['debug']['sqlCount'] = $sql;
    $stmt = $dns->prepare($sql);
    $stmt->execute($parameters);
    $output['recordsTotal'] = (int) $stmt->fetchColumn(0);
} catch (PDOException $e) {
    exit($e->getMessage());
}

if ($output['recordsTotal'] > 0 || 1 == 1) {
    $sql = 'SELECT d.DISTRICT_ID, d.DISTRICT_CODE, d.DISTRICT_NAME, p.PROVINCE_NAME' . $from . $where . " ORDER BY DISTRICT_NAME ASC LIMIT $start, $pageLength;";

    try {
        $output['debug']['sqlResult'] = $sql;
        $stmt = $dns->prepare($sql);
        $stmt->execute($parameters);
        $output['data'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $output['recordsFiltered'] = (int) $stmt->rowCount();
    } catch (PDOException $e) {
        exit($e->getMessage());
    }
}

/* for security */
unset($output['debug']);

header('Content-type: application/json; charset=utf-8');
echo json_encode($output);
