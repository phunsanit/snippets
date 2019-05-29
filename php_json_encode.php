<<<<<<< HEAD
<!doctype html>
<html>
   <head>
      <meta charset="utf-8">
      <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet">
      <title>PHP: json_encode error</title>
      <meta content="Pitt Phunsanit" name="author" />
   </head>
   <body>
      <div class="container">
         <?php
            $datas = [
            	'ininfity' => -9e1000,
            	'title' => 'title',
            ];
            ?>
         <div class="row"><label class="col-md-2" for="">Datas Arrya:</label><textarea class="col-md-10" cols="100" rows="6"><?=var_dump($datas); ?></textarea></div>
         <div class="row"><label class="col-md-2" for="">Json Datas:</label><textarea class="col-md-10" cols="100" rows="6"><?=json_encode($datas); ?></textarea></div>
         <div class="row">
            <label class="col-md-2" for="">Json Error:</label>
            <div class="col-md-10"><?=json_last_error(); ?></div>
         </div>
         <table class="table table-striped">
            <caption><strong>JSON error codes</strong></caption>
            <thead>
               <tr>
                  <th>Code</th>
                  <th>Constant</th>
                  <th>Meaning</th>
                  <th>Availability</th>
               </tr>
            </thead>
            <tbody class="tbody">
               <tr>
                  <td><strong><code><?=JSON_ERROR_NONE; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_NONE</code></strong></td>
                  <td>No error has occurred</td>
                  <td class="empty">&nbsp;</td>
               </tr>
               <tr>
                  <td><strong><code><?=JSON_ERROR_DEPTH; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_DEPTH</code></strong></td>
                  <td>The maximum stack depth has been exceeded</td>
                  <td class="empty">&nbsp;</td>
               </tr>
               <tr>
                  <td><strong><code><?=JSON_ERROR_STATE_MISMATCH; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_STATE_MISMATCH</code></strong></td>
                  <td>Invalid or malformed JSON</td>
                  <td class="empty">&nbsp;</td>
               </tr>
               <tr>
                  <td><strong><code><?=JSON_ERROR_CTRL_CHAR; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_CTRL_CHAR</code></strong></td>
                  <td>Control character error, possibly incorrectly encoded</td>
                  <td class="empty">&nbsp;</td>
               </tr>
               <tr>
                  <td><strong><code><?=JSON_ERROR_SYNTAX; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_SYNTAX</code></strong></td>
                  <td>Syntax error</td>
                  <td class="empty">&nbsp;</td>
               </tr>
               <tr>
                  <td><strong><code><?=JSON_ERROR_UTF8; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_UTF8</code></strong></td>
                  <td>Malformed UTF-8 characters, possibly incorrectly encoded</td>
                  <td>PHP 5.3.3</td>
               </tr>
               <tr>
                  <td><strong><code><?=JSON_ERROR_RECURSION; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_RECURSION</code></strong></td>
                  <td>One or more recursive references in the value to be encoded</td>
                  <td>PHP 5.5.0</td>
               </tr>
               <tr>
                  <td><strong><code><?=JSON_ERROR_INF_OR_NAN; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_INF_OR_NAN</code></strong></td>
                  <td>
                     One or more
                     <a class="link" href="http://php.net/manual/de/language.types.float.php#language.types.float.nan" target="_blank"><strong><code>NAN</code></strong></a>
                     or <a class="link" href="http://php.net/manual/de/function.is-infinite.php" target="_blank"><strong><code>INF</code></strong></a>
                     values in the value to be encoded
                  </td>
                  <td>PHP 5.5.0</td>
               </tr>
               <tr>
                  <td><strong><code><?=JSON_ERROR_UNSUPPORTED_TYPE; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_UNSUPPORTED_TYPE</code></strong></td>
                  <td>A value of a type that cannot be encoded was given</td>
                  <td>PHP 5.5.0</td>
               </tr>
               <tr>
                  <td><strong><code><?=JSON_ERROR_INVALID_PROPERTY_NAME; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_INVALID_PROPERTY_NAME</code></strong></td>
                  <td>A property name that cannot be encoded was given</td>
                  <td>PHP 7.0.0</td>
               </tr>
               <tr>
                  <td><strong><code><?=JSON_ERROR_UTF16; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_UTF16</code></strong></td>
                  <td>Malformed UTF-16 characters, possibly incorrectly encoded</td>
                  <td>PHP 7.0.0</td>
               </tr>
            </tbody>
         </table>
      </div>
   </body>
=======
<!doctype html>
<html>
   <head>
      <meta charset="utf-8">
      <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet">
      <title>PHP: json_encode error</title>
      <meta content="Pitt Phunsanit" name="author" />
   </head>
   <body>
      <div class="container">
         <?php
            $datas = [
            	'ininfity' => -9e1000,
            	'title' => 'title',
            ];
            ?>
         <div class="row"><label class="col-md-2" for="">Datas Arrya:</label><textarea class="col-md-10" cols="100" rows="6"><?=var_dump($datas); ?></textarea></div>
         <div class="row"><label class="col-md-2" for="">Json Datas:</label><textarea class="col-md-10" cols="100" rows="6"><?=json_encode($datas); ?></textarea></div>
         <div class="row">
            <label class="col-md-2" for="">Json Error:</label>
            <div class="col-md-10"><?=json_last_error(); ?></div>
         </div>
         <table class="table table-striped">
            <caption><strong>JSON error codes</strong></caption>
            <thead>
               <tr>
                  <th>Code</th>
                  <th>Constant</th>
                  <th>Meaning</th>
                  <th>Availability</th>
               </tr>
            </thead>
            <tbody class="tbody">
               <tr>
                  <td><strong><code><?=JSON_ERROR_NONE; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_NONE</code></strong></td>
                  <td>No error has occurred</td>
                  <td class="empty">&nbsp;</td>
               </tr>
               <tr>
                  <td><strong><code><?=JSON_ERROR_DEPTH; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_DEPTH</code></strong></td>
                  <td>The maximum stack depth has been exceeded</td>
                  <td class="empty">&nbsp;</td>
               </tr>
               <tr>
                  <td><strong><code><?=JSON_ERROR_STATE_MISMATCH; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_STATE_MISMATCH</code></strong></td>
                  <td>Invalid or malformed JSON</td>
                  <td class="empty">&nbsp;</td>
               </tr>
               <tr>
                  <td><strong><code><?=JSON_ERROR_CTRL_CHAR; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_CTRL_CHAR</code></strong></td>
                  <td>Control character error, possibly incorrectly encoded</td>
                  <td class="empty">&nbsp;</td>
               </tr>
               <tr>
                  <td><strong><code><?=JSON_ERROR_SYNTAX; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_SYNTAX</code></strong></td>
                  <td>Syntax error</td>
                  <td class="empty">&nbsp;</td>
               </tr>
               <tr>
                  <td><strong><code><?=JSON_ERROR_UTF8; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_UTF8</code></strong></td>
                  <td>Malformed UTF-8 characters, possibly incorrectly encoded</td>
                  <td>PHP 5.3.3</td>
               </tr>
               <tr>
                  <td><strong><code><?=JSON_ERROR_RECURSION; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_RECURSION</code></strong></td>
                  <td>One or more recursive references in the value to be encoded</td>
                  <td>PHP 5.5.0</td>
               </tr>
               <tr>
                  <td><strong><code><?=JSON_ERROR_INF_OR_NAN; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_INF_OR_NAN</code></strong></td>
                  <td>
                     One or more
                     <a class="link" href="http://php.net/manual/de/language.types.float.php#language.types.float.nan" target="_blank"><strong><code>NAN</code></strong></a>
                     or <a class="link" href="http://php.net/manual/de/function.is-infinite.php" target="_blank"><strong><code>INF</code></strong></a>
                     values in the value to be encoded
                  </td>
                  <td>PHP 5.5.0</td>
               </tr>
               <tr>
                  <td><strong><code><?=JSON_ERROR_UNSUPPORTED_TYPE; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_UNSUPPORTED_TYPE</code></strong></td>
                  <td>A value of a type that cannot be encoded was given</td>
                  <td>PHP 5.5.0</td>
               </tr>
               <tr>
                  <td><strong><code><?=JSON_ERROR_INVALID_PROPERTY_NAME; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_INVALID_PROPERTY_NAME</code></strong></td>
                  <td>A property name that cannot be encoded was given</td>
                  <td>PHP 7.0.0</td>
               </tr>
               <tr>
                  <td><strong><code><?=JSON_ERROR_UTF16; ?></code></strong></td>
                  <td><strong><code>JSON_ERROR_UTF16</code></strong></td>
                  <td>Malformed UTF-16 characters, possibly incorrectly encoded</td>
                  <td>PHP 7.0.0</td>
               </tr>
            </tbody>
         </table>
      </div>
   </body>
>>>>>>> no message
</html>