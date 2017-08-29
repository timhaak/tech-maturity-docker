#!/bin/sh
echo "Making sure directories exist"
mkdir -p /site/logs/nginx
mkdir -p /site/logs/supervisor
mkdir -p /site/db/techdb.db

echo "Making sure files have correct ownership"
chown -R nginx: /site/tech-maturity/dist /site/logs/nginx &

echo "Link db directory to correct location"
ln -sf /site/db/techdb.db /site/tech-maturity-api/src/database/techdb.db

#if [ ! -f /site/nginx_config/ssl/dhparam.pem ]; then
#    openssl dhparam -out /site/nginx_config/ssl/dhparam.pem 2048
#fi

echo "Initialise db if it doesn't exist"
if [ ! -f /site/tech-maturity-api/src/database/techdb.db/CURRENT ]; then
    echo "Initialising Data"
    babel-node /site/tech-maturity-api/src --presets env &
    sleep 2
    curl http://localhost:8080/api/initialise
    pkill -f tech-maturity-api
fi

TEST_DATA=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' http://localhost/api/asset_type)

if [ "${TEST_DATA}" = "404" ]; then
    echo "Initialising Data"
    babel-node /site/tech-maturity-api/src --presets env &
    sleep 2
    curl http://localhost:8080/api/initialise
    pkill -f tech-maturity-api
fi

echo "Starting servers"
/usr/bin/supervisord -n -c /supervisord.conf
