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
    wget \
    unzip \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*


RUN cd /tmp && \
    wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    mv wordpress /var/www/html/ && \
    rm -rf /tmp/* /var/www/html/wp-content/* && \
    chown -R www-data:www-data /var/www/html

COPY test/ /var/www/html/test/
RUN chown -R www-data:www-data /var/www/html/test && \
    chmod 644 /var/www/html/test/test.php

COPY nginx.conf.template /etc/nginx/sites-available/default.template
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN echo "cgi.fix_pathinfo=0" >> /etc/php/7.3/fpm/php.ini && \
    sed -i 's/listen = \/run\/php\/php7.3-fpm.sock/listen = 127.0.0.1:9000/' /etc/php/7.3/fpm/pool.d/www.conf

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
