#FROM phusion/baseimage:0.11
FROM ubuntu:18.04
ENV REFRESHED_AT 2020-05-16
# Based on mattrayner/lamp and dgraziotin/lamp
# Based on https://github.com/783872453/docker-ubuntu-unattended-upgrades

ENV DOCKER_USER_ID 501 
ENV DOCKER_USER_GID 20
ENV BOOT2DOCKER_ID 1000
ENV BOOT2DOCKER_GID 50
ENV PHPMYADMIN_VERSION=4.9.5
ENV TZ_AREA="Europe"
ENV TZ_CITY="Stockholm"

# Set timezone
#RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
#    dpkg-reconfigure -f noninteractive tzdata

# Tweaks to give Apache/PHP write permissions
RUN usermod -u ${BOOT2DOCKER_ID} www-data && \
    usermod -G staff www-data && \
    useradd -r mysql && \
    usermod -G staff mysql

RUN groupmod -g $(($BOOT2DOCKER_GID + 10000)) $(getent group $BOOT2DOCKER_GID | cut -d: -f1)
RUN groupmod -g ${BOOT2DOCKER_GID} staff

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN add-apt-repository -y ppa:ondrej/php && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
    apt update && \
    apt -y upgrade && \
    echo debconf debconf/frontend select Noninteractive | debconf-set-selections && \
    echo tzdata tzdata/Areas select ${TZ_AREA} | debconf-set-selections && \
    echo tzdata tzdata/Zones/Europe select ${TZ_CITY} | debconf-set-selections && \
    apt -y install nano supervisor wget git apache2 php-xdebug libapache2-mod-php mysql-server php-mysql pwgen php-apcu php7.1-mcrypt php-gd php-xml php-mbstring php-gettext zip unzip php-zip curl php-curl && \
    apt -y autoremove && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Needed for phpMyAdmin
RUN ln -s /etc/php/7.1/mods-available/mcrypt.ini /etc/php/7.3/mods-available/ && \
    phpenmod mcrypt

# Add image configuration and scripts
#COPY supporting_files/start-apache2.sh /start-apache2.sh
#COPY supporting_files/start-mysqld.sh /start-mysqld.sh
#COPY supporting_files/start-webmin.sh /start-webmin.sh
COPY supporting_files/run.sh /run.sh
RUN  chmod 755 /*.sh
COPY supporting_files/supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
COPY supporting_files/supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
COPY supporting_files/supervisord-webmin.conf /etc/supervisor/conf.d/supervisord-webmin.conf
COPY supporting_files/mysqld_innodb.cnf /etc/mysql/conf.d/mysqld_innodb.cnf

# Allow mysql to bind on 0.0.0.0
RUN sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf && \
    sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql

# Add MySQL utils
COPY supporting_files/create_mysql_users.sh /create_mysql_users.sh
RUN chmod 755 /*.sh

# Add phpmyadmin
RUN wget -O /tmp/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz
RUN tar xfvz /tmp/phpmyadmin.tar.gz -C /var
RUN mv /var/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages /var/phpmyadmin
RUN mv /var/phpmyadmin/config.sample.inc.php /var/phpmyadmin/config.inc.php

# Add composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

ENV MYSQL_PASS:-$(pwgen -s 12 1)

# config to enable .htaccess
COPY supporting_files/apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add webmin
RUN echo root:pass | chpasswd && \
    echo "Acquire::GzipIndexes \"false\"; Acquire::CompressionTypes::Order:: \"gz\";" >/etc/apt/apt.conf.d/docker-gzip-indexes && \
    apt update && \
    apt install -y
RUN wget http://www.webmin.com/jcameron-key.asc && \
    apt-key add jcameron-key.asc
RUN echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list && \
    echo "deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib" >> /etc/apt/sources.list && \
    apt update && \
    apt install -y webmin && \
    apt clean

# Add volume for the webroot
VOLUME  ["/var/www"]

# Add homepage
COPY supporting_files/index.php /var/www

EXPOSE 80 10000

CMD ["/run.sh"]
