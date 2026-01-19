FROM debian:buster

RUN echo "deb http://archive.debian.org/debian buster main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list && \
    apt-get update && apt-get install -y \
    nginx \
    php7.3-fpm \
    php7.3-mysql \
    php7.3-mbstring \
    php7.3-xml \
    php7.3-zip \
    php7.3-gd \
    php7.3-curl \
    php7.3-imagick \
    php7.3-json \
    wget \
    unzip \
    gettext-base \
    pwgen \
    default-mysql-server \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    wget https://getcomposer.org/installer -O - | php && \
    mv composer.phar /usr/local/bin/composer

RUN cd /tmp && \
    wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    mv wordpress /var/www/html/ && \
    rm -rf /tmp/* /var/www/html/wordpress/wp-content/* && \
    chown -R www-data:www-data /var/www/html

RUN cd /tmp && \
    wget https://files.phpmyadmin.net/phpMyAdmin/5.1.1/phpMyAdmin-5.1.1-all-languages.tar.gz && \
    tar xzf phpMyAdmin-5.1.1-all-languages.tar.gz && \
    mv phpMyAdmin-5.1.1-all-languages /usr/share/phpmyadmin && \
    mkdir -p /usr/share/phpmyadmin/tmp && \
    chown -R www-data:www-data /usr/share/phpmyadmin && \
    chmod 777 /usr/share/phpmyadmin/tmp && \
    rm -rf /tmp/*

COPY test/ /var/www/html/test/
COPY index.html /var/www/html/index.html
RUN chown -R www-data:www-data /var/www/html/test && \
    chmod 644 /var/www/html/test/test.php && \
    chmod 644 /var/www/html/index.html

COPY nginx.conf.template /etc/nginx/sites-available/default.template
COPY phpmyadmin.config.inc.php.template /usr/share/phpmyadmin/config.inc.php.template
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY init.sql /usr/local/bin/init.sql

RUN echo "cgi.fix_pathinfo=0" >> /etc/php/7.3/fpm/php.ini && \
    sed -i 's/listen = \/run\/php\/php7.3-fpm.sock/listen = 127.0.0.1:9000/' /etc/php/7.3/fpm/pool.d/www.conf

RUN chmod +x /usr/local/bin/entrypoint.sh && \
    chmod 644 /usr/local/bin/init.sql && \
    chmod 644 /usr/share/phpmyadmin/config.inc.php.template && \
    mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld /var/lib/mysql && \
    chmod 755 /var/run/mysqld

EXPOSE 80 3306

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
