#! /bin/bash

apt-get install -y nginx
echo "Welcome on our default nginx site"  > /var/www/html/index.nginx-debian.html

mkdir /etc/nginx/ssl
chown 700 /etc/nginx/ssl
cd /etc/nginx/ssl

openssl req -new -newkey rsa:4096 -sha256 -days 3650 -nodes -x509 -extensions v3_ca -keyout webCA.key -out webCA.crt -subj "/C=FR/ST=IDF/L=Paris/O=TIIX/OU=WTF/CN=web.tiix.lab"

