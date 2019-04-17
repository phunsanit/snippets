<?php

$cnn = new AMQPConnection();
$cnn->setLogin($rabbitcreds['guest']);
$cnn->setPassword($rabbitcreds['guest']);
$cnn->setHost($rabbitcreds['localhost']);
$cnn->setVhost($rabbitcreds['vhost']);
$cnn->connect();

print_r($cnn);