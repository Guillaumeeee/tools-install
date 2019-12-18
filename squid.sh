#! /bin/bash
# http://marek.helion.pl/install/squid.html

# Install dependancies
apt-get update
apt-get -y install gcc make g++ libpcre3-dev zlib1g-dev libluajit-5.1-dev libpcap-dev openssl libnghttp2-dev libdumbnet-dev bison flex libdnet

# Download Squid 4.6 source code
wget http://www.squid-cache.org/Versions/v4/squid-4.6.tar.gz -O /opt/squid-4.6.tar.gz

# Download squidguard
wget http://www.squidguard.org/Downloads/squidGuard-1.3.tar.gz -O /opt/squidGuard-1.3.tar.gz

# Télécharger les blacklists de squidguard
wget ftp://ftp.univ-tlse1.fr/pub/reseau/cache/squidguard_contrib/blacklists.tar.gz -O /opt/blacklists.tar.gz

# Untar archive
tar xzf /opt/squid-4.6.tar.gz -C /opt
tar xzf /opt/squidGuard-1.3.tar.gz -C /opt
tar xzf blacklists.tar.gz -C /var/lib/squidguard/db/

# Configure the compiler with ssl options
cd /opt/squid-4.6
./configure --disable-ipv6

# Compile
make

# Install
make install

# Configure the compiler with ssl options
cd /opt/squidGuard-1.3.tar.gz
./configure

# Compile
make

# Install
make install

# Create squidguard configuration
cp config/squidGuard.conf /etc/squigduard
ln -s /etc/squidguard/squidGuard.conf /etc/squid3/

# Create squid user for file permissions (cache, certificates, logs...)
groupadd squid
useradd squid -r -s /sbin/nologin -g squid

# Create cache & logs directories
mkdir -p /var/squid/cache
mkdir -p /var/log/squid
chown -R squid:squid /var/squid/cache
chown -R squid:squid /var/log/squid

# Create squidguard database
squidGuard -C all

# Initialyze cache directory
/usr/local/squid/sbin/squid -z
