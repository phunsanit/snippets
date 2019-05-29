<<<<<<< HEAD
<dl>
  <dt>GET</dt>
  <dd><?=print_r($_GET, true);?></dd>
  <dt>POST</dt>
  <dd><?=print_r($_POST, true);?></dd>
</dl>
<?php
if (is_array($_REQUEST['items'])) {
    echo '<br>send items by array';
    $where = "WHERE id IN('" . implode("', '", $_REQUEST['items']) . "')";
} else {
    echo '<br>send items by string';
    $where = "WHERE id IN('" . str_replace(',', "', '", $_REQUEST['items']) . "')";
}

$query = "SELECT *
FROM table_name
$where;";

=======
<dl>
  <dt>GET</dt>
  <dd><?=print_r($_GET, true);?></dd>
  <dt>POST</dt>
  <dd><?=print_r($_POST, true);?></dd>
</dl>
<?php
if (is_array($_REQUEST['items'])) {
    echo '<br>send items by array';
    $where = "WHERE id IN('" . implode("', '", $_REQUEST['items']) . "')";
} else {
    echo '<br>send items by string';
    $where = "WHERE id IN('" . str_replace(',', "', '", $_REQUEST['items']) . "')";
}

$query = "SELECT *
FROM table_name
$where;";

>>>>>>> no message
echo '<br>example query = ' . $query;