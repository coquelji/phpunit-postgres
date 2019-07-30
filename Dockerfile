FROM php:7.3-apache

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=. --filename=composer
RUN mv composer /usr/local/bin/

# Install modules
RUN buildDeps="git" && \
    apt-get update && \
    apt-get install -y $buildDeps --no-install-recommends && \
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
    composer require "phpunit/phpunit: ^5.7" --prefer-source --no-interaction && \
    composer require "phpunit/phpunit-selenium: 3.0.3" --prefer-source --no-interaction && \
    composer require "mikey179/vfsStream: 1.1.*"  --prefer-source --no-interaction && \
    composer require "kenjis/ci-phpunit-test: ^0.16.1"  --prefer-source --no-interaction && \
    composer require "facebook/webdriver: ^1.7"  --prefer-source --no-interaction && \
    composer dump-autoload && \
    ln -s /tmp/vendor/bin/phpunit /usr/local/bin/phpunit
    
EXPOSE 80
    
# Set up the application directory. 
VOLUME ["/app"]
WORKDIR /app

# Set up the command arguments. 
ENTRYPOINT ["/usr/local/bin/phpunit"]
CMD ["--help"]
