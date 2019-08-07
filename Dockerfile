FROM composer/composer:php7

# Install modulesapt-transport-https ca-certificates software-properties-common
RUN buildDeps="git apache2 apache2-doc apache2-mpm-prefork apache2-utils libexpat1 libapache2-mod-php5 php5-mcrypt php5-cli php5-pgsql php5-gd php5-recode php5-tidy php5-xmlrpc ssl-cert curl libpq-dev libzip-dev libicu-dev" && \
    apt-get update && \
    apt-get -y --no-install-recommends install apt-transport-https ca-certificates software-properties-common && \
    apt-add-repository ppa:ondrej/php && \
    apt search php7 && \
    apt-get install -y $buildDeps --no-install-recommends && \
    xsel=1.2.0-2+b1 && \
    pecl install xdebug && \
    echo 'zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20151012/xdebug.so' > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    php -m | grep xdebug && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite
RUN a2enmod php5

RUN docker-php-ext-install \
        opcache \
        pdo \
        pdo_pgsql \
        pgsql \
        sockets \
        intl 

# On cré les variables d'environement pour les utiliser plus facilement
ENV APACHE_CONF_FILE /etc/apache2/apache2.conf

# On ajoute localhost comme nom de serveur
RUN echo "ServerName localhost" >> $APACHE_CONF_FILE


# On cache la signature du serveur
RUN echo "ServerSignature Off" >> $APACHE_CONF_FILE
RUN echo "ServerTokens Prod" >> $APACHE_CONF_FILE
RUN echo "ServerTokens Prod" >> $APACHE_CONF_FILE


# On active HTTP2
#RUN echo "Protocols h2 http/1.1" >> $APACHE_CONF_FILE


# On supprime les configurations par defaut
RUN rm -f /etc/apache2/sites-enabled/*
RUN rm -f /etc/apache2/sites-available/*

RUN mkdir /var/www/html/app

RUN echo "<VirtualHost *:80> \nServerName localhost \nServerAlias localhost  \nDocumentRoot /var/www/html/app  \n<Directory /var/www/html/app>\nAllowOverride All \n</Directory>\n</VirtualHost>" > /etc/apache2/sites-enabled/app.conf
RUN echo "<VirtualHost *:80> \nServerName localhost \nServerAlias localhost  \nDocumentRoot /var/www/html/app  \n<Directory /var/www/html/app>\nAllowOverride All \n</Directory>\n</VirtualHost>" > /etc/apache2/sites-available/app.conf

# Redirection d'un port local vers l'exterieur
EXPOSE 80
EXPOSE 443
EXPOSE 8443

RUN /etc/init.d/apache2 restart

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
