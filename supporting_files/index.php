<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Hello World from Docker-LAMP</title>

    <style>
        @import 'https://fonts.googleapis.com/css?family=Montserrat|Raleway|Source+Code+Pro';

        body { font-family: 'Raleway', sans-serif; }
        h2 { font-family: 'Montserrat', sans-serif; }
        pre {
            font-family: 'Source Code Pro', monospace;
            padding: 16px;
            overflow: auto;
            font-size: 85%;
            line-height: 1.45;
            background-color: #f7f7f7;
            border-radius: 3px;
            word-wrap: normal;
        }

        .container {
            max-width: 1024px;
            width: 100%;
            margin: 0 auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <img src="https://cdn.rawgit.com/mattrayner/docker-lamp/831976c022782e592b7e2758464b2a9efe3da042/docs/logo.svg" alt="Docker LAMP logo" />
        </header>
        <section>
            <pre>
            OS: <?php echo php_uname('s'); ?><br>
            Apache version: <?php echo apache_get_version(); ?><br>
            MariaDB version: <?php $b=exec('mysql -V');echo substr($b, 10, 7); ?><br>
            PHP version: <?php echo phpversion(); ?><br>
            phpMyAdmin version: <?php echo getenv('PHPMYADMIN_VERSION'); ?><br>
            Webmin version: 1.490<br>
            Timezone: <?php echo getenv('TZ_AREA') . "/" . getenv('TZ_CITY'); ?><br>
            </pre>
        </section>
    </div>
</body>
</html>