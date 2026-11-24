#!/bin/sh
set -e

service mariadb start

MYSQL_CMD="mysql"
MYSQLADMIN_CMD="mysqladmin"

if ! mysql -u root -e "SELECT 1;" >/dev/null 2>&1; then
	MYSQL_CMD="mysql -u root -p${SQL_ROOT_PASSWORD}"
	MYSQLADMIN_CMD="mysqladmin -u root -p${SQL_ROOT_PASSWORD}"
fi

sh -c "$MYSQL_CMD -e \"CREATE DATABASE IF NOT EXISTS ${SQL_DATABASE};\""
sh -c "$MYSQL_CMD -e \"CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';\""
sh -c "$MYSQL_CMD -e \"GRANT ALL PRIVILEGES ON ${SQL_DATABASE}.* TO '${SQL_USER}'@'%';\""
sh -c "$MYSQL_CMD -e \"ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';\""
sh -c "$MYSQL_CMD -e \"FLUSH PRIVILEGES;\""
sh -c "$MYSQLADMIN_CMD shutdown"

exec mysqld_safe
