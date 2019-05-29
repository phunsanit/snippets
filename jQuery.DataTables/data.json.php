<<<<<<< HEAD
<?php
/* https://datatables.net/manual/server-side */

$output = [
    'data' => [],
    'debug' => [
        'length' => $_REQUEST['length'],
        'post' => $_REQUEST,
        'sqlCount' => '',
        'sqlResult' => '',
        'start' => $_REQUEST['start'],
    ],
    'draw' => $_REQUEST['draw'],
    'recordsFiltered' => $_REQUEST['length'],
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

}

if (isset($_REQUEST['geo_id']) && $_REQUEST['geo_id'] != '') {
    $parameter = ':d_geo_id';

    $parameters[$parameter] = $_REQUEST['geo_id'];
    array_push($condition, 'd.GEO_ID = ' . $parameter);
}

if (count($parameters)) {
    $where = ' WHERE ' . implode("\n\t AND ", $condition);
}

if (isset($_REQUEST['order']) && isset($_REQUEST['order'][0])) {
    $columns = [
        0 => 'DISTRICT_NAME',
        3 => 'DISTRICT_CODE',
        4 => 'DISTRICT_NAME',
        5 => 'PROVINCE_NAME',
    ];

    $order = ' ORDER BY ' . $columns[$_REQUEST['order'][0]['column']] . ' ' . strtoupper($_REQUEST['order'][0]['dir']);
} else {
    $order = ' ORDER BY DISTRICT_NAME ASC';
}

$output['debug']['parameters'] = $parameters;

/* Total records, before filtering */
$sql = 'SELECT COUNT(d.DISTRICT_ID)' . $from;
try {
    $output['debug']['sqlCount'] = $sql;
    $stmt = $dns->prepare($sql);
    $stmt->execute($parameters);
    $output['recordsTotal'] = (int) $stmt->fetchColumn(0);
} catch (PDOException $e) {
    exit($e->getMessage());
}

/* Total records, after filtering */
$sql = 'SELECT COUNT(d.DISTRICT_ID)' . $from . $where;
try {
    $output['debug']['sqlCount'] = $sql;
    $stmt = $dns->prepare($sql);
    $stmt->execute($parameters);
    $output['recordsFiltered'] = (int) $stmt->fetchColumn(0);
} catch (PDOException $e) {
    exit($e->getMessage());
}

/* data */
if ($output['recordsTotal'] > 0) {
    $sql = 'SELECT d.enable, d.DISTRICT_ID, d.DISTRICT_CODE, d.DISTRICT_NAME, p.PROVINCE_NAME' . $from . $where . $order . " LIMIT " . $_REQUEST['start'] . ", " . $_REQUEST['length'] . ";";

    try {
        $output['debug']['sqlResult'] = $sql;
        $stmt = $dns->prepare($sql);
        $stmt->execute($parameters);
        $output['data'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        exit($e->getMessage());
    }
}

/* unset debug for security */
unset($output['debug']);

header('Content-type: application/json; charset=utf-8');
echo json_encode($output);
=======
<?php
/* https://datatables.net/manual/server-side */

$output = [
    'data' => [],
    'debug' => [
        'length' => $_REQUEST['length'],
        'post' => $_REQUEST,
        'sqlCount' => '',
        'sqlResult' => '',
        'start' => $_REQUEST['start'],
    ],
    'draw' => $_REQUEST['draw'],
    'recordsFiltered' => $_REQUEST['length'],
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

}

if (isset($_REQUEST['geo_id']) && $_REQUEST['geo_id'] != '') {
    $parameter = ':d_geo_id';

    $parameters[$parameter] = $_REQUEST['geo_id'];
    array_push($condition, 'd.GEO_ID = ' . $parameter);
}

if (count($parameters)) {
    $where = ' WHERE ' . implode("\n\t AND ", $condition);
}

if (isset($_REQUEST['order']) && isset($_REQUEST['order'][0])) {
    $columns = [
        0 => 'DISTRICT_NAME',
        3 => 'DISTRICT_CODE',
        4 => 'DISTRICT_NAME',
        5 => 'PROVINCE_NAME',
    ];

    $order = ' ORDER BY ' . $columns[$_REQUEST['order'][0]['column']] . ' ' . strtoupper($_REQUEST['order'][0]['dir']);
} else {
    $order = ' ORDER BY DISTRICT_NAME ASC';
}

$output['debug']['parameters'] = $parameters;

/* Total records, before filtering */
$sql = 'SELECT COUNT(d.DISTRICT_ID)' . $from;
try {
    $output['debug']['sqlCount'] = $sql;
    $stmt = $dns->prepare($sql);
    $stmt->execute($parameters);
    $output['recordsTotal'] = (int) $stmt->fetchColumn(0);
} catch (PDOException $e) {
    exit($e->getMessage());
}

/* Total records, after filtering */
$sql = 'SELECT COUNT(d.DISTRICT_ID)' . $from . $where;
try {
    $output['debug']['sqlCount'] = $sql;
    $stmt = $dns->prepare($sql);
    $stmt->execute($parameters);
    $output['recordsFiltered'] = (int) $stmt->fetchColumn(0);
} catch (PDOException $e) {
    exit($e->getMessage());
}

/* data */
if ($output['recordsTotal'] > 0) {
    $sql = 'SELECT d.enable, d.DISTRICT_ID, d.DISTRICT_CODE, d.DISTRICT_NAME, p.PROVINCE_NAME' . $from . $where . $order . " LIMIT " . $_REQUEST['start'] . ", " . $_REQUEST['length'] . ";";

    try {
        $output['debug']['sqlResult'] = $sql;
        $stmt = $dns->prepare($sql);
        $stmt->execute($parameters);
        $output['data'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        exit($e->getMessage());
    }
}

/* unset debug for security */
unset($output['debug']);

header('Content-type: application/json; charset=utf-8');
echo json_encode($output);
>>>>>>> no message
