# ![Docker-LAMPW][logo]
Docker-LAMPW is based on mattrayner/lamp (18.04), eg a LAMP stack ([Apache][apache], [MySQL][mysql] and [PHP][php]).

Component | `latest-1804`
---|---
[Apache][apache] |`2.4.29`
[MySQL][mysql] |`5.7.26`
[PHP][php] | `7.3.6`
[phpMyAdmin][phpmyadmin] | `4.9.0.1`
[Webmin][webmin] | `1.930`

## Using the image
### On the command line
```bash
# Launch the image with autostart when docker start
docker run -d --restart unless-stopped -p 8000:80 -p 10000:10000 -v /github/app:/app --name lamp karye/lampw
# View log
docker logs lamp
# Attach to console
docker exec -it lamp bash
# View running containers
docker ps -a
# Pull latest image from https://hub.docker.com/repository/docker/karye/lampw
docker pull karye/lampw
```

## Project layout
The website in '/app/' is available from `http://localhost:8000`.\
```
/ (project root)
/app/ (your PHP files live here)
```

## Administration
### webmin
Docker-LAMPW comes pre-installed with webmin available from `https://localhost:10000`.\
Login in with user 'root' and password 'pass'.
Local timezone is 'Europe/Stockholm'. You may change timezone in webmin.

### PHPMyAdmin
Docker-LAMPW comes pre-installed with phpMyAdmin available from `http://localhost:8000/phpmyadmin`.\
Login in with user 'admin' and password 'pass'.

### Volumes
4 volumes are used for persistent storage: "/etc/mysql", "/etc/webmin", "/var/lib/mysql", "/app".

## License
Docker-LAMPW is licensed under the [Apache 2.0 License][info-license].

[logo]: https://cdn.rawgit.com/mattrayner/docker-lamp/831976c022782e592b7e2758464b2a9efe3da042/docs/logo.svg

[apache]: http://www.apache.org/
[mysql]: https://www.mysql.com/
[php]: http://php.net/
[phpmyadmin]: https://www.phpmyadmin.net/
[Webmin]: http://www.webmin.com/

[end-of-life]: http://php.net/supported-versions.php

[info-docker-hub]: https://hub.docker.com/r/mattrayner/lamp
[info-license]: LICENSE