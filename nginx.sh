#! /bin/bash

# Install nginx from debian official repo
apt-get install -y nginx

# Create default page
echo "Welcome on our default nginx site"  > /var/www/html/index.html

# Create SSL work directory
mkdir /etc/nginx/ssl

# Change rights on SSL directory
chown 700 /etc/nginx/ssl

# Create Diffie-Helmann parameters
openssl dhparam 2048 > /etc/nginx/ssl/dh2048.pem

# Create CA certificate and key
# openssl req -new -newkey rsa:4096 -sha256 -days 3650 -nodes -x509 -extensions v3_ca -keyout /etc/nginx/ssl/webCA.key -out /etc/nginx/ssl/webCA.crt -subj "/C=FR/ST=IDF/L=Paris/O=TIIX/OU=WTF/CN=webCA.tiix.lab"
openssl genrsa -out /etc/nginx/ssl/webCA.key 2048
openssl req -x509 -new -nodes -key /etc/nginx/ssl/webCA.key -sha256 -days 3650 -out /etc/nginx/ssl/webCA.pem

# Create server certificate and key
openssl genrsa -out /etc/nginx/ssl/webServ.key 2048
openssl req -new -key /etc/nginx/ssl/webServ.key -out /etc/nginx/ssl/webServ.csr -subj "/C=FR/ST=IDF/L=Paris/O=TIIX/OU=WTF/CN=webCA.tiix.lab"
openssl x509 -req -in /etc/nginx/ssl/webServ.csr -CA /etc/nginx/ssl/webCA.pem -CAkey /etc/nginx/ssl/webCA.key -CAcreateserial -out /etc/nginx/ssl/webServ.crt -days 365 -sha256 

# Copy nginx site config to nginx directory
cp config/nginx.conf /etc/nginx/sites-available/webServ.cfg

# Create available-enabled symlink
ln -s /etc/nginx/sites-available/webServ.cfg /etc/nginx/sites-enabled/webServ.cfg

# Remove default config
rm /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
