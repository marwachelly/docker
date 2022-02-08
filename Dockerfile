#FROM php:7.2-apache
FROM php:7.4-apache
#FROM php:7.1-apache
#XFrom php:7.1-fpm

# Add files to Apache directory
VOLUME ["/var/www/html"]

# install mysql driver
RUN docker-php-ext-install pdo pdo_mysql
# install php-gd extension
RUN apt-get update && apt-get install -y \
	libjpeg-dev\
	libpng-dev\
	libfreetype6-dev\
	zlib1g-dev\
    libicu-dev\
    g++

RUN apt-get update && apt-get install -y libzip-dev zlib1g-dev chromium && docker-php-ext-install zip
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ && docker-php-ext-install gd zip

RUN apt-get update
RUN apt-get update && apt-get install -my wget gnupg

RUN apt-get update && apt-get install -y netcat-openbsd

RUN php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/local/bin --filename=composer \
    && chmod +x /usr/local/bin/composer

#RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs build-essential
#RUN npm install --global gulp-cli

RUN apt-get update
RUN apt-get install -y zip
RUN apt-get install -y wget
RUN cd /root && wget  'https://phar.phpunit.de/phpunit-5.7.phar' && mv /root/phpunit-5.7.phar /usr/bin/phpunit && chmod +x /usr/bin/phpunit

RUN apt-get update
RUN apt-get --yes --force-yes install git
RUN apt-get install nano

# Installing JAVA
#RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
#RUN apt-get update -y
#RUN apt-get install software-properties-common python-software-properties -y
#RUN apt-get update -y
#
#RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list
#RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
#RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
#RUN apt-get update
#RUN apt-get install -y oracle-java8-installer

ENV PHP_CPPFLAGS="$PHP_CPPFLAGS -std=c++11"
#RUN docker-php-ext-configure intl --with-icu-dir=/usr/local \
# run configure and install in the same RUN line, they extract and clean up the php source to save space
 # && docker-php-ext-install intl
RUN docker-php-ext-configure intl && docker-php-ext-install intl

RUN a2enmod rewrite
RUN echo "short_open_tag=On" >> /usr/local/etc/php/php.ini
RUN echo "apc.enable_cli = On" >> /usr/local/etc/php/php.ini
RUN echo "apc.ttl = 3600" >> /usr/local/etc/php/php.ini
RUN echo "upload_max_filesize = 10000M" >> /usr/local/etc/php/php.ini
RUN echo "post_max_size = 10000M" >> /usr/local/etc/php/php.ini
RUN echo "max_input_vars = 5000" >> /usr/local/etc/php/php.ini
RUN echo "ini_set('max_execution_time', 0);" >> /usr/local/etc/php/php.ini
RUN echo "set_time_limit = 0" >> /usr/local/etc/php/php.ini
RUN echo "set_time_limit = Off" >> /usr/local/etc/php/php.ini
#error log
RUN echo "log_errors = On" >> /usr/local/etc/php/php.ini
RUN echo "error_reporting = E_ALL" >> /usr/local/etc/php/php.ini
RUN echo "error_log = /var/log/php_error_log.log" >> /usr/local/etc/php/php.ini
RUN echo "mbstring.http_output = pass" >> /usr/local/etc/php/php.ini
RUN echo "mbstring.internal_encoding = pass" >> /usr/local/etc/php/php.ini
RUN echo "output_buffering = ON" >> /usr/local/etc/php/php.ini
RUN echo "output_handler = mb_output_handler" >> /usr/local/etc/php/php.ini
RUN echo "php_value mbstring.func_overload 0" >> /usr/local/etc/php/php.ini



#xdebug
RUN yes | pecl install xdebug \
   && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
   && echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/xdebug.ini \
   && echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/xdebug.ini \
   && echo "xdebug.remote_port=9002" >> /usr/local/etc/php/conf.d/xdebug.ini \
   && echo "xdebug.remote_host=pagamac.docker.local" >> /usr/local/etc/php/conf.d/xdebug.ini

#imap
#RUN apt-get install php5-imap
#RUN php5enmod imap
#RUN docker-php-ext-configure imap --with-imap --with-imap-ssl \
#        && docker-php-ext-install imap
RUN apt-get update && apt-get install -y libc-client-dev libkrb5-dev && rm -r /var/lib/apt/lists/*
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap

#ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem -subj "/C=AT/ST=Vienna/L=Vienna/O=Security/OU=Development/CN=localhost"

RUN a2enmod rewrite
RUN a2ensite default-ssl
RUN a2enmod ssl

EXPOSE 80
EXPOSE 443

#install sonar scanner
#RUN apt-get update && apt-get install -y unzip
#RUN wget https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.0.3.778-linux.zip -O /tmp/sonar.zip && \
#    mkdir -p /root/.sonar/native-sonar-scanner && \
#    unzip /tmp/sonar.zip -d /root/.sonar/native-sonar-scanner && \
#    rm /tmp/sonar.zip

#memcached
##https://serverpilot.io/docs/how-to-install-the-php-memcache-extension
#RUN apt-get -y install gcc make autoconf libc-dev pkg-config
#RUN apt-get -y install zlib1g-dev
#RUN apt-get -y install libmemcached-dev
#RUN pecl install memcached -no --disable-memcached-sasl \
#&& echo "extension=memcached.so" >> /usr/local/etc/php/php.ini \
#&& echo "extension=memcached.so" >> /usr/local/etc/php/conf.d/memcached.ini

#Vhost
#RUN -d --name nginx -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy
#RUN -e test=myapp.dev

ADD entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
