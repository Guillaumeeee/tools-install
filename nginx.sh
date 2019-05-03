#! /bin/bash

apt-get install -y nginx
echo "Welcome on our default nginx site"  > /var/www/html/index.nginx-debian.html

mkdir /etc/nginx/ssl
chown 700 /etc/nginx/ssl
cd /etc/nginx/ssl

openssl req -new -newkey rsa:4096 -sha256 -days 3650 -nodes -x509 -extensions v3_ca -keyout webServ.key -out webServ.crt -subj "/C=FR/ST=IDF/L=Paris/O=TIIX/OU=WTF/CN=web.tiix.lab"
openssl dhparam 2048 > dh2048.pem

cd -
cp config/nginx.conf /etc/nginx/sites-available/webServ.cfg
ln -s /etc/nginx/sites-available/webServ.cfg /etc/nginx/sites-enabled/webServ.cfg
