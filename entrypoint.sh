#!/bin/bash
set -e

if [ -f /.env ]; then
    export $(grep -v '^#' /.env | xargs)
fi

AUTO_INDEX=${AUTO_INDEX:-off}

echo "PHP-FPM starting with AUTO_INDEX=$AUTO_INDEX"

service php7.3-fpm start
echo "PHP-FPM started"

sleep 2

envsubst '$AUTO_INDEX' < /etc/nginx/sites-available/default.template > /etc/nginx/sites-available/default

rm /etc/nginx/sites-available/default.template

exec nginx -g "daemon off;"
