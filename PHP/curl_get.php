<!doctype html>
<html>

<head>
    <meta charset="utf-8">
    <title>CURL: send get variables</title>
    <link href="../vendor/twbs/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css">
</head>

<body>
    <div class="container">
        <?php
if (count($_GET)) {
    $queryString = http_build_query($_GET);
    $url = 'http://localhost/snippets/PHP/variables.php?' . $queryString;

    echo '<br>$url = ', $url;

    $ch = curl_init();

    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_URL => $url,
    ]);

    $result = curl_exec($ch);
    curl_close($ch);

    echo $result;
}
?>
            <form action="curl_get.php" method="get">
                <div class="form-group">
                    <label for="name">Name:</label>
                    <input class="form-control" id="name" name="name" type="text">
                </div>
                <div class="form-group">
                    <label for="avatar">Avatar:</label>
                    <input accept="image/gif, image/jpeg, image/x-png" class="form-control" id="avatar" name="avatar" type="file">
                </div>
                <div class="form-group">
                    <label for="address1">text address:</label>
                    <input class="form-control" id="address1" name="address[]" type="text">
                </div>
                <div class="form-group">
                    <label for="address2">text address 2:</label>
                    <input class="form-control" id="address2" name="address[]" type="text">
                </div>
                <button type="submit" class="btn btn-default">Submit</button>
            </form>
    </div>
</body>

</html>