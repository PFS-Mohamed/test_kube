#!/bin/bash


mkdir -p /var/www/public
cd /var/www

# Publish assets before caching
#php artisan storage:link && \
#php artisan optimize:clear && \
#php artisan config:cache && \
#php artisan route:cache && \
#php artisan view:cache && \
#php artisan event:cache && \
#php artisan queue:restart && \
#php artisan telescope:publish && \
#php artisan telescope:prune --hours=48 && \
#php artisan l5-swagger:generate


# Database migration
#php artisan migrate --force


# droit d'accès
#chown 0:48 /var/www/storage/ -R
#chmod g+rwX /var/www/storage/ -R


# bash
source /root/.bash_profile


# Supervisor (qui lance les services annexes)
/usr/bin/supervisord -n


exit 0
