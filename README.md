# ![Docker-LAMPW][logo]
Docker-LAMPW is a LAMP stack ([Apache][apache], [MariaDB][mariadb] and [PHP][php]).

Component | `latest-1804`
---|---
[Apache][apache] |`2.4.29`
[MariaDB][mariadb] |`15.1`
[PHP][php] | `7.2`
[Composer][composer] | `1.6.3`
[phpMyAdmin][phpmyadmin] | `4.9.5`
[Webmin][webmin] | `1.941`

## Using the image
### Launching in Linux
```bash
# For datapersistens two volumes are used:
# /var/www i mapped to /home/user/github
# Launch the image with autostart when docker start
docker run --restart unless-stopped -d -p 8080:80 -p 10000:10000 \
-v /home/user/github:/var/www \
--name lamp karye/lampw
```

### Launching in Windows
```powershell
# For datapersistens two volumes are used:
# /var/www i mapped to C:\github
# Launch the image with autostart when docker start
docker run -d --restart unless-stopped -p 8080:80 -p 10000:10000 `
-v "C:\github:/var/www" `
--name lamp karye/lampw
```

## Useful Docker commands
```shell
# View logg
docker logs lamp

# Attach to console
docker exec -it lamp bash

# View running containers
docker ps -a

# Updating to latest image
# Pull latest image from https://hub.docker.com/repository/docker/karye/lampw
docker stop karye/lampw
docker rm karye/lampw
docker pull karye/lampw
```

## Project layout
The website `http://localhost:8080` is mapped to '/var/www/' in the docker container.
```
/ (project root)
/var/www/ (your folders and files live here)
```

## Administration
### webmin
Docker-LAMPW comes pre-installed with Webmin available from `https://localhost:10000`.\
Login in with user **root** and password **pass**.\
Local timezone is 'Europe/Stockholm'. You may change timezone in Webmin.

### PHPMyAdmin
Docker-LAMPW comes pre-installed with phpMyAdmin available from `http://localhost:8000/phpmyadmin`.\
Login in with user **admin** and password **pass**.

## License
Docker-LAMPW is licensed under the [Apache 2.0 License][info-license].

[logo]: https://cdn.rawgit.com/mattrayner/docker-lamp/831976c022782e592b7e2758464b2a9efe3da042/docs/logo.svg

[apache]: http://www.apache.org/
[mariadb]: https://mariadb.org/
[php]: http://php.net/
[composer]: https://getcomposer.org/
[phpmyadmin]: https://www.phpmyadmin.net/
[Webmin]: http://www.webmin.com/

[end-of-life]: http://php.net/supported-versions.php

[info-docker-hub]: https://hub.docker.com/r/mattrayner/lamp
[info-license]: LICENSE