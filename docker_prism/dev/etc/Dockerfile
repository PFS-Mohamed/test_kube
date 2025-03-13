FROM rockylinux:9

# Installation de PHP et Apache
RUN dnf install -y epel-release && \
    dnf install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm

# config bash
COPY bash/.bash_profile /root/.bashrc


#######
# PHP #
#######

# Activer le module PHP du dépôt Remi
ENV PHP_VERSION=8.3
RUN dnf module reset php -y && \
    dnf module enable php:remi-8.3 -y


# Installer PHP et les extensions nécessaires
RUN dnf install -y \
    php \
    php-common \
    php-pdo \
    php-cli \
    php-fpm \
    php-opcache \
    php-pecl-raphf \
    php-xml \
    oniguruma5php \
    php-mbstring \
    php-sodium \
    php-gd \
    php-pecl-mcrypt \
    php-pecl-geoip \
    php-imap \
    php-pecl-http \
    php-mysqlnd \
    php-bcmath \
    php-intl \
    php-maxminddb \
    php-pecl-imagick-im7 \
    php-pecl-inotify \
    php-pecl-redis \
    php-soap


# Config
COPY php/php.ini /etc/php.ini
COPY php/php-fpm.conf/ /etc/php-fpm.conf
COPY php/php-fpm.d/* /etc/php-fpm.d/



#########
# REDIS #
#########

#RUN yum install redis
#COPY redis.conf /etc/redis.conf


#########
# Mysql #
#########

#RUN dnf install -y \
#    mariadb.x86_64 \
#    mariadb-backup.x86_64


##########
# Apache #
##########

RUN dnf install -y \
    httpd \
    httpd-tools \
    mod_http2 \
    mod_ssl

COPY apache/httpd.conf /etc/httpd/conf/httpd.conf
COPY apache/.htpasswd /etc/httpd/.htpasswd
COPY apache/.docpasswd /etc/httpd/.docpasswd
COPY certs/ /etc/letsencrypt/


#######
# LPR #
#######

#RUN dnf install -y \
#    cups \
#    cups-client \
#    cups-filesystem


##################
# Package addons #
##################

RUN dnf install -y \
    zip \
    bzip2 \
    unzip \
    #curl \
    ImageMagick \
    nano \
    gettext \
    ccze \
    git \ 
    wget \
    bash-completion \
    GeoIP \
    GeoIP-GeoLite-data \
    jpegoptim \
    optipng \
    hunspell-de \
    hunspell-es-ES \
    hunspell-nl \
    hunspell-fr \
    hunspell-it \
    hunspell-en-GB


############
# Security #
############

RUN dnf install -y \
    iptables \
    fail2ban \
    whois \
    monit \
    pwgen \
    supervisor.noarch

# config
COPY supervisord/supervisord.conf /etc/supervisord.conf
COPY supervisord/supervisord.d/* /etc/supervisord.d/



#########
# Debug #
#########

RUN dnf install -y \
    telnet \
    net-tools \
    iputils \
    procps-ng \
    ccze \
    colordiff \
    #lscolors.x86_64 \
    atop \
    btop \
    htop \
    iotop \
    dstat


##########
# System #
##########

COPY init.sh /usr/local/bin/init.sh


# Installer les dépendances nécessaires pour utiliser NodeSource
#RUN curl -sL https://rpm.nodesource.com/setup_18.x | bash -
#RUN dnf install -y nodejs
#RUN npm install -g npm@latest
#RUN npm install -g yarn


# Composer
#RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
#RUN php composer-setup.php
#RUN php -r "unlink('composer-setup.php');"
#RUN mv composer.phar /usr/local/bin/composer

#ENV COMPOSER_ALLOW_SUPERUSER 1
#ENV COMPOSER_HOME /composer
#ENV PATH $PATH:/composer/vendor/bin
#RUN composer config --global process-timeout 3600
#RUN composer global require "laravel/installer"


# Exposer le port pour le serveur si nécessaire
#EXPOSE 80


# Répertoire mandatory
RUN mkdir -p /run/php-fpm/
RUN mkdir -p /var/log/php/
RUN mkdir -p /var/www/public


# Commande de démarrage pour PHP-FPM (ajustez si nécessaire pour Apache ou Nginx)
RUN chmod +x /usr/local/bin/init.sh
CMD ["/usr/local/bin/init.sh"]
