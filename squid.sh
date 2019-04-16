#! /bin/bash

# Installer les dépendances
apt-get update
apt-get -y install libssl1.0-dev

# Télécharger la dernière version de squid
cd /opt && wget http://www.squid-cache.org/Versions/v4/squid-4.6.tar.gz

# Décompresser l'archive
tar xvzf squid-4.6.tar.gz

# Configurer le fichier de compilation
cd squid-4.6
./configure --with-openssl --enable-ssl --enable-ssl-crtd --disable-ipv6

# Compiler le code source
make

# Installer l'outil
make install

# Créer un utilisateur squid pour l'appartenance des fichiers (cache, certificats, logs...)
groupadd squid
useradd squid -r -s /sbin/nologin -g squid

# Créer le répertoire où placer les certificats
mkdir /usr/local/squid/ssl
cd /usr/local/squid/ssl

# Créer la clé privée et le certificat de la CA
openssl req -new -newkey rsa:4096 -sha256 -days 3650 -nodes -x509 -extensions v3_ca -keyout proxyCA.pem -out proxyCA.pem

# Générer le certificat au format der (import dans un navigateur)
openssl x509 -in proxyCA.pem -outform DER -out proxyCA.der

# Configurer les permissions
chown -R squid:squid /usr/local/squid/ssl

# Créer les répertoire de cache et de log
mkdir -p /var/squid/cache
mkdir -p /var/log/squid
chown -R squid:squid /var/squid/cache
chown -R squid:squid /var/log/squid

# Initialiser la base de certificats 
/usr/local/squid/libexec/security_file_certgen -c -s /usr/local/squid/var/cache/squid/ssl_db -M 4MB
