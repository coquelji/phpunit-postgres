FROM composer/composer:php7

# Install modules
RUN buildDeps="git httpd libpq-dev libzip-dev libicu-dev" && \
    apt-get update && \
    apt-get install -y $buildDeps --no-install-recommends && \
    xsel=1.2.0-2+b1 && \
    pecl install xdebug && \
    echo 'zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20151012/xdebug.so' > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    php -m | grep xdebug && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-install \
        opcache \
        pdo \
        pdo_pgsql \
        pgsql \
        sockets \
        intl 

RUN /sbin/service httpd start
EXPOSE 80

# Goto temporary directory. 
WORKDIR /tmp

# Run composer and phpunit installation. 
RUN composer selfupdate && \
    composer require "phpunit/phpunit: ^5.7" --prefer-source --no-interaction && \
    composer require "phpunit/phpunit-selenium: 3.0.3" --prefer-source --no-interaction && \
    composer require "mikey179/vfsStream: 1.1.*"  --prefer-source --no-interaction && \
    composer require "kenjis/ci-phpunit-test: ^0.16.1"  --prefer-source --no-interaction && \
    composer require "facebook/webdriver: ^1.7"  --prefer-source --no-interaction && \
    composer dump-autoload && \
    ln -s /tmp/vendor/bin/phpunit /usr/local/bin/phpunit
    
# Set up the application directory. 
VOLUME ["/app"]
WORKDIR /app

# Set up the command arguments. 
#ENTRYPOINT ["/usr/local/bin/phpunit"]
ENTRYPOINT ["/bin/bash"]
CMD ["--help"]
