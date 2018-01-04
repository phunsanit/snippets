<?php

$url = 'http://localhost:8080/jw/web/json/workflow/assignment/list/pending';

$ch = curl_init();

curl_setopt_array($ch, [
	CURLOPT_ENCODING => 'UTF-8',
	CURLOPT_POST => 1,
	CURLOPT_POSTFIELDS => http_build_query([
		"j_hash" => "0BFE8A96A38E8CD3A20F40947631F568",
		"j_username" => "admin",
	]),
	CURLOPT_RETURNTRANSFER => true,
	CURLOPT_URL => $url,
]);

$result = curl_exec($ch);
curl_close($ch);

echo $result;
