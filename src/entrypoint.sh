#!/bin/bash
set -e

if [ -f /.env ]; then
    export $(grep -v '^#' /.env | xargs)
fi

AUTO_INDEX=${AUTO_INDEX:-off}
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-3306}
DB_NAME=${DB_NAME:-wordpress}
DB_USER=${DB_USER:-wpuser}
DB_PASSWORD=${DB_PASSWORD:-wppassword}
DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD:-rootpassword}
BLOWFISH_SECRET=${BLOWFISH_SECRET:-$(pwgen -s 32 1)}

rm -rf /var/lib/mysql/*

mysql_install_db --user=mysql --datadir=/var/lib/mysql &>/dev/null &

mysqld_safe --skip-networking &>/dev/null &
MYSQL_PID=$!

sleep 5

envsubst '$DB_ROOT_PASSWORD $DB_NAME $DB_USER $DB_PASSWORD' < /usr/local/bin/init.sql | mysql -u root

mysqladmin -u root shutdown &>/dev/null &
wait $MYSQL_PID

envsubst '$DB_HOST $DB_PORT $DB_USER $DB_PASSWORD $BLOWFISH_SECRET' < \
    /usr/share/phpmyadmin/config.inc.php.template > \
    /usr/share/phpmyadmin/config.inc.php

mysqld_safe &>/dev/null &

sleep 5

service php7.3-fpm start

sleep 2

envsubst '$AUTO_INDEX' < /etc/nginx/sites-available/default.template > /etc/nginx/sites-available/default

rm /etc/nginx/sites-available/default.template

echo "everything ok!"

exec nginx -g "daemon off;"
