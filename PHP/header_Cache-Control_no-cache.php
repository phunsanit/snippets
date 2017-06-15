<?php
if (isset($_GET['clearCache']) && $_GET['clearCache'] == true) {
    header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
    header('Cache-Control: post-check=0, pre-check=0', false);
    header('Pragma: no-cache');
}

$time = date('Y-m-d H:i:s');

$script = 'alert("last updated ' . $time . '");';

fwrite(fopen('header_Cache-Control_no-cache.js', 'w+'), $script);
?>

<!doctype html>
<html>

<head>
    <meta charset="utf-8">
    <title>Cache-Control: no-cache, must-revalidate</title>
</head>

<body>
    <?php echo '<h1>ขณะนี้เวลา ', $time, '</h1>'; ?>
    <script src="header_Cache-Control_no-cache.js"></script>
</body>

</html>