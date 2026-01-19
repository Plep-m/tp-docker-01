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

if [ ! -f /var/www/html/wordpress/wp-config.php ]; then
    echo "Configuring WordPress..."
    
    WP_URL=${WP_URL:-http://localhost/wordpress}
    WP_TITLE=${WP_TITLE:-"My WordPress Site"}
    WP_ADMIN_USER=${WP_ADMIN_USER:-admin}
    WP_ADMIN_PASSWORD=${WP_ADMIN_PASSWORD:-admin}
    WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL:-admin@example.com}
    
    wp config create \
        --path=/var/www/html/wordpress \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$DB_HOST" \
        --allow-root
    
    wp core install \
        --path=/var/www/html/wordpress \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    wp theme install twentytwentyfive --activate \
        --path=/var/www/html/wordpress \
        --allow-root
    
    wp option update show_on_front page \
        --path=/var/www/html/wordpress \
        --allow-root
    
    wp option update page_on_front 1 \
        --path=/var/www/html/wordpress \
        --allow-root
    
    echo "WordPress installation completed!"
fi

service php7.3-fpm start

sleep 2

envsubst '$AUTO_INDEX' < /etc/nginx/sites-available/default.template > /etc/nginx/sites-available/default

rm /etc/nginx/sites-available/default.template

echo "everything ok!"

exec nginx -g "daemon off;"
