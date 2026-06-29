<?php
date_default_timezone_set("Europe/Berlin");

$appName = "StockScope";
$serverTime = date("Y-m-d H:i:s");
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><?php echo $appName; ?> PHP Info</title>

  <!-- Bootstrap 5 -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- Project CSS -->
  <link rel="stylesheet" href="css/style.css">
</head>
<body class="bg-dark text-light">
  <main class="container py-5">
    <div class="card bg-dark border-primary text-light p-4">
      <h1 class="mb-3"><?php echo $appName; ?> PHP Server Page</h1>

      <p>
        This page is generated with PHP on a server that supports PHP.
      </p>

      <p>
        Server time: <strong><?php echo $serverTime; ?></strong>
      </p>

      <p>
        The main web app uses HTML5, CSS3, Bootstrap 5, Vanilla JavaScript, Chart.js and Marketstack API.
      </p>

      <a href="index.html" class="btn btn-primary mt-3">Back to Web App</a>
    </div>
  </main>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>