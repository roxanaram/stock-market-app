<?php
date_default_timezone_set("Europe/Berlin");

header("Content-Type: application/json");

echo json_encode([
    "app" => "StockScope",
    "php" => "enabled",
    "timezone" => "Europe/Berlin",
    "serverTime" => date("Y-m-d H:i:s"),
    "message" => "PHP server is working"
]);
?>