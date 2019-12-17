#! /bin/bash

# Install dependancies
apt-get update
apt-get install -y gcc make libpcre3-dev zlib1g-dev libpcap-dev openssl libssl-dev build-essential libpcre3-dev zlib1g-dev 


# Download archives
wget http://nginx.org/download/nginx-1.16.1.tar.gz -O /opt/nginx.tar.gz
wget https://github.com/nbs-system/naxsi/archive/0.56.tar.gz -O /opt/naxsi.tar.gz

# Extract archives
tar -xzf /opt/nginx.tar.gz -C /opt
tar -xzf /opt/naxsi.tar.gz -C /opt

# Configure compilation options
cd /opt/nginx-1.16.1
./configure \
    --conf-path=/etc/nginx/nginx.conf \
    --add-module=../naxsi-0.56/naxsi_src \
    --error-log-path=/var/log/nginx/error.log \
    --http-client-body-temp-path=/var/lib/nginx/body \
    --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
    --http-log-path=/var/log/nginx/access.log \
    --http-proxy-temp-path=/var/lib/nginx/proxy \
    --lock-path=/var/lock/nginx.lock \
    --pid-path=/var/run/nginx.pid \
    --user=www-data \
    --group=www-data \
    --with-http_ssl_module \
    --without-mail_pop3_module \
    --without-mail_smtp_module \
    --without-mail_imap_module \
    --without-http_uwsgi_module \
    --without-http_scgi_module \
    --prefix=/usr


# Patch temporary gcc problem in Makefile 
sed -i 's/Werror/Wno-error/g' objs/Makefile

# Compile nginx with naxsi options
make -j 2

# Install binaries
make install 

# Configure naxsi
cp /opt/naxsi-0.56/naxsi_config/naxsi_core.rules /etc/nginx/


