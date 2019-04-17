<!doctype html>
<html>

<head>
    <meta charset="utf-8">
    <title>CURL: send file</title>
    <link href="../vendor/twbs/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css">
</head>

<body>
    <div class="container">
        <?php
if (count($_FILES) || count($_POST)) {
    $url = 'http://localhost/snippets/PHP/variables.php';

    if (count($_FILES)) {
        $file_name_with_full_path = $_FILES['avatar']['tmp_name'];

        if (function_exists('curl_file_create')) {
            /* php 5.5+ */
            $_POST['avatar'] = curl_file_create($file_name_with_full_path);
        } else {
            $_POST['avatar'] = '@' . realpath($file_name_with_full_path);
        }
    }

    $ch = curl_init();

    curl_setopt_array($ch, [
        CURLOPT_ENCODING => 'UTF-8',
        CURLOPT_POST => 1,
        CURLOPT_POSTFIELDS => $_POST,
        //CURLOPT_POSTFIELDS => http_build_query($_POST),
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_URL => $url,
    ]);

    $result = curl_exec($ch);
    curl_close($ch);

    echo $result;
}
?>
            <form action="curl_file.php" enctype="multipart/form-data" method="post">
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
                    <input class="form-control" id="address1" name="address[d]" type="text">
                </div>
                <div class="form-group">
                    <label for="address2">text address 2:</label>
                    <input class="form-control" id="address2" name="address[f]" type="text">
                </div>
                <button type="submit" class="btn btn-default">Submit</button>
            </form>
    </div>
</body>

</html>