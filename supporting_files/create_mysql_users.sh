#!/bin/bash

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

_user="admin"
_word="pass"
echo "=> Creating MySQL admin user with ${_word} password"

mysql -uroot -e "CREATE USER '${_user}'@'%' IDENTIFIED BY '${_word}'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '${_user}'@'%' WITH GRANT OPTION"
mysql -uroot -e "GRANT ALL PRIVILEGES ON phpmyadmin.* TO  'pma'@'localhost' IDENTIFIED BY ''"

mysqladmin -uroot shutdown
