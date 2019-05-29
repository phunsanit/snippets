<<<<<<< HEAD
<?php

$cnn = new AMQPConnection();
$cnn->setLogin($rabbitcreds['guest']);
$cnn->setPassword($rabbitcreds['guest']);
$cnn->setHost($rabbitcreds['localhost']);
$cnn->setVhost($rabbitcreds['vhost']);
$cnn->connect();

=======
<?php

$cnn = new AMQPConnection();
$cnn->setLogin($rabbitcreds['guest']);
$cnn->setPassword($rabbitcreds['guest']);
$cnn->setHost($rabbitcreds['localhost']);
$cnn->setVhost($rabbitcreds['vhost']);
$cnn->connect();

>>>>>>> no message
print_r($cnn);