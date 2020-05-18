FROM ubuntu:18.04

ENV REFRESHED_AT 2020-05-16
# Inspired on fauria/lamp
# Based on https://github.com/783872453/docker-ubuntu-unattended-upgrades

ENV DOCKER_USER_ID 501 
ENV DOCKER_USER_GID 20
ENV BOOT2DOCKER_ID 1000
ENV BOOT2DOCKER_GID 50
ENV PHPMYADMIN_VERSION=4.9.5
ENV TZ_AREA="Europe"
ENV TZ_CITY="Stockholm"

# Tweaks to give Apache/PHP write permissions
RUN usermod -u ${BOOT2DOCKER_ID} www-data && \
    usermod -G staff www-data && \
    useradd -r mysql && \
    usermod -G staff mysql

RUN groupmod -g $(($BOOT2DOCKER_GID + 10000)) $(getent group $BOOT2DOCKER_GID | cut -d: -f1)
RUN groupmod -g ${BOOT2DOCKER_GID} staff

ENV DEBIAN_FRONTEND noninteractive

# Upgrade to latest packages
RUN apt update && apt -y upgrade

# Set environment variables
RUN echo debconf debconf/frontend select Noninteractive | debconf-set-selections
RUN echo tzdata tzdata/Areas select ${TZ_AREA} | debconf-set-selections
RUN echo tzdata tzdata/Zones/Europe select ${TZ_CITY} | debconf-set-selections

# Install packages
RUN apt -y install nano supervisor wget git apache2 php php-xdebug pwgen \
    php-apcu php-gd php-xml php-mbstring php-gettext zip unzip php-zip curl \
    php-curl pwgen php-apcu libapache2-mod-php php-mysql mariadb-server \
    composer

# Needed for phpMyAdmin
RUN phpenmod mbstring

RUN apt -y autoremove && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Add image configuration and scripts
COPY supporting_files/run.sh /run.sh
RUN chmod 755 /*.sh
COPY supporting_files/supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
COPY supporting_files/supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
COPY supporting_files/supervisord-webmin.conf /etc/supervisor/conf.d/supervisord-webmin.conf

# config to enable .htaccess
COPY supporting_files/apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add phpmyadmin
RUN wget -O /tmp/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz
RUN tar xfvz /tmp/phpmyadmin.tar.gz -C /var
RUN mv /var/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages /var/phpmyadmin
RUN mv /var/phpmyadmin/config.sample.inc.php /var/phpmyadmin/config.inc.php

# Add webmin
RUN echo root:pass | chpasswd
RUN echo "Acquire::GzipIndexes \"false\"; Acquire::CompressionTypes::Order:: \"gz\";" >/etc/apt/apt.conf.d/docker-gzip-indexes
RUN apt update && apt install -y
RUN wget http://www.webmin.com/jcameron-key.asc && \
    apt-key add jcameron-key.asc
RUN echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list && \
    echo "deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib" >> /etc/apt/sources.list
RUN apt update && apt install -y webmin && apt clean

# Add volume for the webroot
VOLUME  ["/var/www"]

# Add homepage
RUN mkdir /var/lamp
COPY supporting_files/index.php /var/lamp

EXPOSE 80 10000

CMD ["/run.sh"]