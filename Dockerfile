FROM composer/composer:php7

# Install modules
RUN buildDeps="git libpq-dev libzip-dev libicu-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev libmagickwand-6.q16-dev" && \
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

# Goto temporary directory. 
WORKDIR /tmp

# Run composer and phpunit installation. 
RUN composer selfupdate && \
    composer require "phpunit/phpunit:~5.3.4" --prefer-source --no-interaction && \
    ln -s /tmp/vendor/bin/phpunit /usr/local/bin/phpunit
    
# Set up the application directory. 
VOLUME ["/app"]
WORKDIR /app

# Set up the command arguments. 
ENTRYPOINT ["/usr/local/bin/phpunit"]
CMD ["--help"]
