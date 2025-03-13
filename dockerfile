# Utilisation d'une image officielle PHP Apache
FROM php:8.3-apache

# Copie ton fichier PHP dans le dossier d'Apache
COPY index.php /var/www/html/

# Exposition du port Apache
EXPOSE 80

