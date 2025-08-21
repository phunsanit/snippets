<?php

include 'RabbitMQConnection.php';

use PhpAmqpLib\Message\AMQPMessage;

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
 list($queueName, $message_count, $consumer_count) = $channel->queue_declare($queue_name, false, true, false, false);

$properties = [
    'content_type' => 'application/json',
    'delivery_mode' => AMQPMessage::DELIVERY_MODE_PERSISTENT,
];

for ($a = 1; $a <= 1000; $a++) {
    $datas = [
        'id' => str_pad($a, 4, '0', STR_PAD_LEFT),
        'rand' => rand(0, 100),
        'time' => date('Y-m-d H:m:s'),
    ];

	$msg_body = json_encode($datas);

	$msg = new AMQPMessage($msg_body, $properties);

	/**
	 * Publishes a message
	 *
	 * @param AMQPMessage $msg
	 * @param string $exchange
	 * @param string $routing_key
	 * @param bool $mandatory
	 * @param bool $immediate
	 * @param int $ticket
	 */
	$channel->basic_publish($msg, $exchange_name, $queue_name);

    /**
     * Publishes a message
     *
     * @param AMQPMessage $msg
     * @param string $exchange
     * @param string $routing_key
     * @param bool $mandatory
     * @param bool $immediate
     * @param int $ticket
     */
    $channel->basic_publish($msg, $exchange_name, $queue_name);

    echo '<br>' . $msg_body;
}

/**
 * Publish batch
 *
 * @return void
 */
$channel->publish_batch();

$channel->close();
$connection->close();