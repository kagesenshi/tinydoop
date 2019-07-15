#!/bin/bash

/usr/libexec/mysql-prepare-db-dir 
/usr/bin/mysqld_safe --basedir=/usr &
MY_PID=$$

until mysqladmin ping >/dev/null 2>&1; do
  echo -n "."; sleep 0.2
done

mysql -e "CREATE USER tinydoop@localhost IDENTIFIED BY 'password'"
mysql -e "CREATE DATABASE hive_metastore"
mysql -e "GRANT ALL ON hive_metastore.* TO tinydoop@localhost"

source /etc/profile.d/hadoop.sh

schematool -dbType mysql -initSchema

kill $$
