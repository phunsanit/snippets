<?php

include 'RabbitMQConnection.php';

set_time_limit(0);

$exchange_name = 'customers';
$queue_name = 'invoices';

/**
 * Declares exchange
 *
 * @param string $exchange_name
 * @param string $type
 * @param bool $passive
 * @param bool $durable
 * @param bool $auto_delete
 * @param bool $internal
 * @param bool $nowait
 * @param array $arguments
 * @param int $ticket
 * @return mixed|null
 */
$channel->exchange_declare($exchange_name, 'fanout', false, true, false);

/**
 * Declares queue, creates if needed
 *
 * @param string $queue
 * @param bool $passive
 * @param bool $durable
 * @param bool $exclusive
 * @param bool $auto_delete
 * @param bool $nowait
 * @param array $arguments
 * @param int $ticket
 * @return mixed|null
 */
list($queueName, $message_count, $consumer_count) = $channel->queue_declare('', false, false, true, false);
$channel->queue_bind($queue_name, $exchange_name);

$callback = function ($msg) {

    $datas = json_decode($msg->body, true);
    fwrite(fopen('pp.txt', 'a+'), print_r($datas, true));

    sleep(substr_count($msg->body, '.'));

    /* delete message */
    $msg->delivery_info['channel']->basic_ack($msg->delivery_info['delivery_tag']);
};

/**
 * Starts a queue consumer
 *
 * @param string $queue_name
 * @param string $consumer_tag
 * @param bool $no_local
 * @param bool $no_ack
 * @param bool $exclusive
 * @param bool $nowait
 * @param callback|null $callback
 * @param int|null $ticket
 * @param array $arguments
 * @return mixed|string
 */
$channel->basic_consume($queue_name, '', false, false, false, false, $callback);

while (count($channel->callbacks)) {
    /**
     * Wait for some expected AMQP methods and dispatch to them.
     * Unexpected methods are queued up for later calls to this PHP
     * method.
     *
     * @param array $allowed_methods
     * @param bool $non_blocking
     * @param int $timeout
     * @throws \PhpAmqpLib\Exception\AMQPOutOfBoundsException
     * @throws \PhpAmqpLib\Exception\AMQPRuntimeException
     * @return mixed
     */

    $channel->wait();
}

$channel->close();
$connection->close();