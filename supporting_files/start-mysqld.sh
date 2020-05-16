#!/bin/bash
rm /var/run/mysqld/mysqld.sock.lock
exec mysqld_safe
