<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Docker-LAMPW</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <header>
            <img src="lamp.svg" alt="Docker LAMP logo" />
        </header>
        <section>
<pre>
OS: <?php echo php_uname(); ?><br>
Apache version: <?php echo apache_get_version(); ?><br>
MariaDB version: <?php $b = exec('mysql -V'); echo substr($b, 10, 7); ?><br>
PHP version: <?php echo phpversion(); ?><br>
phpMyAdmin version: <?php echo getenv('PHPMYADMIN_VERSION'); ?><br>
Webmin version: 1.490<br>
Timezone: <?php echo getenv('TZ_AREA') . "/" . getenv('TZ_CITY'); ?><br>
</pre>
        </section>
        <section>
            <?php
            echo phpinfo();
            ?>
        </section>
    </div>
</body>

</html>