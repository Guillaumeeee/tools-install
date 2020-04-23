#! /bin/bash
# http://marek.helion.pl/install/squid.html

# Install dependancies
apt-get update
apt-get -y install gcc make g++ libpcre3-dev zlib1g-dev libluajit-5.1-dev libpcap-dev openssl libnghttp2-dev libdumbnet-dev bison flex libdnet libc-bin libssl1.1 libssl-dev

# Download Squid 4.6 source code
cd /opt && wget http://www.squid-cache.org/Versions/v4/squid-4.11.tar.gz

# Untar archive
tar xvzf squid-4.11.tar.gz -C /opt

# Configure the compiler with ssl options
cd squid-4.11
./configure --with-openssl --enable-ssl --enable-ssl-crtd --disable-ipv6

# Compile
make

# Install
make install

# Create squid user for file permissions (cache, certificates, logs...)
groupadd squid
useradd squid -r -s /sbin/nologin -g squid

# Create certificates directory
mkdir /usr/local/squid/ssl
cd /usr/local/squid/ssl

# Create CA certificate and private key
openssl req -new -newkey rsa:4096 -sha256 -days 3650 -nodes -x509 -extensions v3_ca -keyout proxyCA.pem -out proxyCA.pem -subj "/C=FR/ST=IDF/L=Paris/O=TIIX/OU=WTF/CN=proxy.tiix.lab"

# Export certificate to "der" format (importable into browser)
openssl x509 -in proxyCA.pem -outform DER -out proxyCA.der

# Configure permissions
chown -R squid:squid /usr/local/squid/ssl

# Create cache & logs directories
mkdir -p /var/squid/cache
mkdir -p /var/log/squid
chown -R squid:squid /var/squid/cache
chown -R squid:squid /var/log/squid

# Initialyze ssl cert database
/usr/local/squid/libexec/security_file_certgen -c -s /usr/local/squid/var/cache/squid/ssl_db -M 4MB

# Initialyze cache directory
/usr/local/squid/sbin/squid -z
