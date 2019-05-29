<<<<<<< HEAD
<?php

$dbh = new PDO('mysql:host=172.22.216.57;dbname=true_select', 'trueselect', 'w<C1tm(NMjb8', [
	PDO::ATTR_EMULATE_PREPARES => false,
]);

/* $dbh->setAttribute(PDO::ATTR_EMULATE_PREPARES, false); */

echo '<dl>';

$sql = "SELECT custom_page_id, title
FROM `custom_page`
WHERE `slug` LIKE '%test%'
LIMIT :start, :max";

echo '<dt>SQL Original</dt><dd>'.$sql,'</dd>';

$sql = "SELECT custom_page_id, title
FROM `custom_page`
WHERE `slug` LIKE :slug
LIMIT :start, :max";

echo '<dt>SQL statement</dt><dd>'.$sql,'</dd>';

$sth = $dbh->prepare($sql);

$sth->execute([
	':max' => 20,
	':slug' => '%test%',
	':start' => 0,
]);

echo '<dt>queryString</dt><dd>', $sth->queryString,'</dd>';

echo '<dt>params</dt><dd>', $sth->debugDumpParams(false),'</dd>';

$result = $sth->fetchAll(PDO::FETCH_ASSOC);

echo '<dt>query result</dt><dd><pre>', print_r($result, true),'</pre></dd>';

$sql = "SELECT * FROM  mysql.general_log  WHERE command_type ='Query' LIMIT total;";
$dbh->query($sql);
$result = $sth->fetchAll(PDO::FETCH_ASSOC);
echo '<dt>query result</dt><dd><pre>', print_r($result, true),'</pre></dd>';

=======
<?php

$dbh = new PDO('mysql:host=172.22.216.57;dbname=true_select', 'trueselect', 'w<C1tm(NMjb8', [
	PDO::ATTR_EMULATE_PREPARES => false,
]);

/* $dbh->setAttribute(PDO::ATTR_EMULATE_PREPARES, false); */

echo '<dl>';

$sql = "SELECT custom_page_id, title
FROM `custom_page`
WHERE `slug` LIKE '%test%'
LIMIT :start, :max";

echo '<dt>SQL Original</dt><dd>'.$sql,'</dd>';

$sql = "SELECT custom_page_id, title
FROM `custom_page`
WHERE `slug` LIKE :slug
LIMIT :start, :max";

echo '<dt>SQL statement</dt><dd>'.$sql,'</dd>';

$sth = $dbh->prepare($sql);

$sth->execute([
	':max' => 20,
	':slug' => '%test%',
	':start' => 0,
]);

echo '<dt>queryString</dt><dd>', $sth->queryString,'</dd>';

echo '<dt>params</dt><dd>', $sth->debugDumpParams(false),'</dd>';

$result = $sth->fetchAll(PDO::FETCH_ASSOC);

echo '<dt>query result</dt><dd><pre>', print_r($result, true),'</pre></dd>';

$sql = "SELECT * FROM  mysql.general_log  WHERE command_type ='Query' LIMIT total;";
$dbh->query($sql);
$result = $sth->fetchAll(PDO::FETCH_ASSOC);
echo '<dt>query result</dt><dd><pre>', print_r($result, true),'</pre></dd>';

>>>>>>> no message
echo '</dl>';