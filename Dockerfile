FROM php:7.3-apache

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=. --filename=composer
RUN mv composer /usr/local/bin/

# Install modules
RUN buildDeps="git libpq-dev libzip-dev libicu-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev libmagickwand-6.q16-dev chromium xvfb" && \
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

# GeckoDriver v0.19.1
RUN wget -q "https://github.com/mozilla/geckodriver/releases/download/v0.19.1/geckodriver-v0.19.1-linux64.tar.gz" -O /tmp/geckodriver.tgz \
    && tar zxf /tmp/geckodriver.tgz -C /usr/bin/ \
    && rm /tmp/geckodriver.tgz

# chromeDriver v2.35
RUN wget -q "https://chromedriver.storage.googleapis.com/2.35/chromedriver_linux64.zip" -O /tmp/chromedriver.zip \
    && unzip /tmp/chromedriver.zip -d /usr/bin/ \
    && rm /tmp/chromedriver.zip

# xvfb - X server display
RUN ln -s /usr/bin/chromium /usr/bin/google-chrome \
    && chmod 777 /usr/bin/chromium

# create symlinks to chromedriver and geckodriver (to the PATH)
RUN ln -s /usr/bin/geckodriver /usr/bin/chromium-browser \
    && chmod 777 /usr/bin/geckodriver \
    && chmod 777 /usr/bin/chromium-browser
    
EXPOSE 80
    
# Set up the application directory. 
VOLUME ["/app"]
WORKDIR /app

# Set up the command arguments. 
ENTRYPOINT ["/usr/local/bin/phpunit"]
CMD ["--help"]
