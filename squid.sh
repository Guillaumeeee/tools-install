#! /bin/bash
# http://marek.helion.pl/install/squid.html

# Install dependancies
apt-get update
apt-get -y install gcc make g++ libpcre3-dev zlib1g-dev libluajit-5.1-dev libpcap-dev openssl libnghttp2-dev libdumbnet-dev bison flex libdnet libc-bin libssl1.1 libssl-dev

# Download Squid 4.6 source code
wget http://www.squid-cache.org/Versions/v4/squid-4.11.tar.gz -O /opt/squid-4.11.tar.gz

# Download squidguard
wget http://www.squidguard.org/Downloads/squidGuard-1.3.tar.gz -O /opt/squidGuard-1.3.tar.gz

# Télécharger les blacklists de squidguard
wget http://squidguard.mesd.k12.or.us/blacklists.tgz -O /opt/blacklists.tar.gz

# Download berkeley db needed for squidguard
wget https://www.tiix.wtf/public_share/berkeley_db_18.1.32.tar.gz -O /opt/berkeley_db_18.1.32.tar.gz

# Untar archive
tar xzf /opt/squid-4.11.tar.gz -C /opt
tar xzf /opt/squidGuard-1.3.tar.gz -C /opt
tar xzf /opt/blacklists.tar.gz -C /opt
tar xzf /opt/berkeley_db_18.1.32.tar.gz -C /opt

# Configure the compiler with ssl options
cd /opt/squid-4.11
./configure --disable-ipv6
make
make install

cd /opt/db-18.1.32/build_unix
../dist/configure --prefix=/usr/local/berkeleydb
make
make install 
echo “/usr/local/berkeleydb/lib” >> /etc/ld.so.conf
/usr/sbin/ldconfig

# Configure the compiler with ssl options
cd /opt/squidGuard-1.3 
./configure --with-db=/usr/local/berkeleydb
make
make install

# Create squidguard configuration
cp config/squidGuard.conf /usr/local/squigduard
ln -s /usr/local/squidguard/squidGuard.conf /usr/local/squid

# Copy config
cp /usr/local/squid/etc/squid.conf /usr/local/squid/etc/squid.conf.dist
cp config/squid.conf /usr/local/squid/etc/

# Create squid user for file permissions (cache, certificates, logs...)
/usr/sbin/groupadd squid
/usr/sbin/useradd squid -r -s /sbin/nologin -g squid

# Create cache & logs directories
mkdir -p /var/squid/cache
mkdir -p /var/log/squid
chown -R squid:squid /var/squid/cache
chown -R squid:squid /var/log/squid

# Create squidguard database
squidGuard -C all

# Initialyze cache directory
/usr/local/squid/sbin/squid -z
