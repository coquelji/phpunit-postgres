FROM php:7-fpm
# Install modules
RUN buildDeps="libpq-dev libzip-dev libicu-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev libmagickwand-6.q16-dev" && \
    apt-get update && \
    apt-get install -y $buildDeps --no-install-recommends && \
    ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16/MagickWand-config /usr/bin && \
    pecl install imagick && \
    echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-install \
        opcache \
        pdo \
        pdo_pgsql \
        pgsql \
        sockets \
        intl
        
ENV PHPUNIT_VERSION 6.5.3
RUN mkdir -p /root/src \
    && cd /root/src \
    && wget https://phar.phpunit.de/phpunit-${PHPUNIT_VERSION}.phar \ 
    && chmod +x phpunit-${PHPUNIT_VERSION}.phar \ 
    && mv phpunit-${PHPUNIT_VERSION}.phar /usr/local/bin/phpunit \ 
    && rm -rf /root/src \
    && phpunit --version

CMD ["phpunit"]
