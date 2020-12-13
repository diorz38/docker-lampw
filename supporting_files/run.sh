#!/bin/bash

echo "=> Setting PHP filesizes"
if [ -e /etc/php/5.6/apache2/php.ini ]
then
    sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
        -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php/5.6/apache2/php.ini
else
    sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
        -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php/${PHP_VERSION}/apache2/php.ini
fi

sed -i "s/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=www-data/" /etc/apache2/envvars

sed -i -e "s/cfg\['blowfish_secret'\] = ''/cfg['blowfish_secret'] = '`date | md5sum`'/" /var/phpmyadmin/config.inc.php

echo "=> Setting directories permissions and owners"
if [ -n "$VAGRANT_OSX_MODE" ];then
    usermod -u $DOCKER_USER_ID www-data
    groupmod -g $(($DOCKER_USER_GID + 10000)) $(getent group $DOCKER_USER_GID | cut -d: -f1)
    groupmod -g ${DOCKER_USER_GID} www-data
    chmod -R 770 /var/lib/mysql
    chmod -R 770 /var/run/mysqld
    chown -R www-data:www-data /var/lib/mysql
    chown -R www-data:www-data /var/run/mysqld
else
    # Tweaks to give Apache/PHP write permissions
    #chown -R www-data:www-data /var/www
    chown -R www-data:www-data /var/phpmyadmin
    chown -R www-data:www-data /var/lib/mysql
    chown -R www-data:www-data /var/run/mysqld
    chmod -R 770 /var/lib/mysql
    chmod -R 770 /var/run/mysqld
fi

#rm /var/run/mysqld/mysqld.sock*

sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i "s/user.*/user = www-data/" /etc/mysql/my.cnf

/usr/bin/touch /var/webmin/miniserv.log

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    #mysql -uroot -e "status" > /dev/null 2>&1
    ps aux | grep mysql
    RET=$?
done

_user="admin"
_word="pass"
echo "=> Creating MySQL admin user with ${_word} password"

mysql -uroot -e "GRANT ALL ON *.* TO '${_user}'@'localhost' IDENTIFIED BY '${_word}' WITH GRANT OPTION"
mysql -uroot -e "FLUSH PRIVILEGES"

echo "========================================================================"
echo "You can now connect to this MySQL Server with $PASS"
echo ""
echo "    mysql -uadmin -p$PASS -h<host> -P<port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "MySQL user 'root' has no password but only allows local connections"
echo ""

mysqladmin -uroot shutdown
echo "=> Shutting down MySQL"

exec supervisord -n
