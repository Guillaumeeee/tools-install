#! /bin/bash
# http://marek.helion.pl/install/squid.html

# Install dependancies
apt-get update
apt-get -y install libssl1.0-dev gcc make g++

# Download Squid 4.6 source code
cd /opt && wget http://www.squid-cache.org/Versions/v4/squid-4.6.tar.gz

# Untar archive
tar xvzf squid-4.6.tar.gz

# Configure the compiler with ssl options
cd squid-4.6
./configure --disable-ipv6

# Compile
make

# Install
make install

# Create squid user for file permissions (cache, certificates, logs...)
groupadd squid
useradd squid -r -s /sbin/nologin -g squid

# Create cache & logs directories
mkdir -p /var/squid/cache
mkdir -p /var/log/squid
chown -R squid:squid /var/squid/cache
chown -R squid:squid /var/log/squid

# Initialyze cache directory
/usr/local/squid/sbin/squid -z
