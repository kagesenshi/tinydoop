#!/bin/bash

# /usr/libexec/mysql-prepare-db-dir 
/usr/bin/mysqld_safe --basedir=/usr &
MY_PID=$!

until mysqladmin ping >/dev/null 2>&1; do
  echo -n "."; sleep 0.2
done

#mysql -e "CREATE USER tinydoop@localhost IDENTIFIED BY 'password'"
mysql -e "CREATE DATABASE airflow"
mysql -e "GRANT ALL ON airflow.* TO tinydoop@localhost"

source /etc/profile.d/99-airflow.sh

airflow initdb

kill $MY_PID

exit 0
