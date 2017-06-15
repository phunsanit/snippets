<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Cache-Control: no-cache, must-revalidate</title>
</head>
<body>
<?php
$time = date('Y-m-d H:i:s');
echo '<h1>ขณะนี้เวลา ', $time, '</h1>'; 
if($this->input->get('clearCache') == true) {
	$script = 'alert("last updated ' . $time . '");'

	fwrite(fopen('header_Cache-Control_no-cache.js', 'w+'), $script);
}
?>
<script src="header_Cache-Control_no-cache.js"></script>
</body>
</html>