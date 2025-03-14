FROM rockylinux:9

# Installation PHP + Apache + Supervisor + dépendances
RUN dnf install -y epel-release && \
    dnf install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm

COPY etc/bash/.bash_profile /root/.bashrc

# PHP 8.3
ENV PHP_VERSION=8.3
RUN dnf module reset php -y && \
    dnf module enable php:remi-8.3 -y && \
    dnf install -y \
        php php-common php-pdo php-cli php-fpm php-opcache \
        php-pecl-raphf php-xml oniguruma5php php-mbstring \
        php-sodium php-gd php-pecl-mcrypt php-pecl-geoip \
        php-imap php-pecl-http php-mysqlnd php-bcmath php-intl \
        php-maxminddb php-pecl-imagick-im7 php-pecl-inotify \
        php-pecl-redis php-soap

# Apache
RUN dnf install -y httpd httpd-tools mod_http2 mod_ssl

COPY etc/apache/httpd.conf /etc/httpd/conf/httpd.conf
COPY etc/apache/.htpasswd /etc/httpd/.htpasswd
COPY etc/apache/.docpasswd /etc/httpd/.docpasswd
COPY etc/certs/ /etc/letsencrypt/

# PHP config
COPY etc/php/php.ini /etc/php.ini
COPY etc/php/php-fpm.conf /etc/php-fpm.conf
COPY etc/php/php-fpm.d/ /etc/php-fpm.d/



# Supervisor (très important pour lancer plusieurs services proprement en Kubernetes)
RUN dnf install -y supervisor
COPY etc/supervisord/supervisord.conf /etc/supervisord.conf
COPY etc/supervisord/supervisord.d/ /etc/supervisord.d/

# Outils divers
RUN dnf install -y zip bzip2 unzip ImageMagick nano gettext ccze git wget bash-completion GeoIP GeoIP-GeoLite-data jpegoptim optipng hunspell-de hunspell-es-ES hunspell-nl hunspell-fr hunspell-it hunspell-en-GB iptables fail2ban whois monit pwgen telnet net-tools iputils procps-ng colordiff atop btop htop iotop dstat

# Init script
COPY etc/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# Répertoires nécessaires
RUN mkdir -p /run/php-fpm/ /var/log/php/ /var/www/public
RUN chown -R apache:apache /var/www/public

# INDEX.PHP
COPY releases/local/public/ /var/www/public/

# Exposition des ports requis pour Kubernetes
EXPOSE 80 443

# Lancement du script en mode foreground (super important pour Kubernetes !)
CMD ["/usr/local/bin/init.sh"]
