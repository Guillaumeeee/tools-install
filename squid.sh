#! /bin/bash
# http://marek.helion.pl/install/squid.html

# Install dependancies
apt-get update
apt-get -y install libssl1.0-dev gcc make g++

# Download Squid 4.6 source code
wget http://www.squid-cache.org/Versions/v4/squid-4.6.tar.gz -O /opt/squid-4.6.tar.gz

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

# Télécharger les blacklists de squidguard
wget ftp://ftp.univ-tlse1.fr/pub/reseau/cache/squidguard_contrib/blacklists.tar.gz -O /opt/blacklists.tar.gz

# Initialyze cache directory
/usr/local/squid/sbin/squid -z
