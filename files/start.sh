#!/bin/sh
mkdir -p /site/logs/nginx
mkdir -p /site/logs/supervisor

chown -R nginx: /var/lib/nginx  /site

if [ ! -f /nginx/nginx_config/ssl/dhparam.pem ]; then
    openssl dhparam -out /nginx/nginx_config/ssl/dhparam.pem 2048
fi

/usr/bin/supervisord -n -c /nginx/supervisord.conf
