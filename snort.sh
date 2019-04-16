#! /bin/bash

# Installer les dépendances
apt-get install -y gcc make libpcre3-dev zlib1g-dev libluajit-5.1-dev libpcap-dev openssl libssl-dev libnghttp2-dev libdumbnet-dev bison flex libdnet

# Configurer le dossier de travail
mkdir /opt/snort_src && cd /opt/snort_src

# Télécharger la "Data Aquisition Library"
wget https://www.snort.org/downloads/snort/daq-2.0.6.tar.gz

# Décompresser l'archive
tar xvzf daq-2.0.6.tar.gz
cd daq-2.0.6

# Configurer, compiler, installer daq
./configure && make && sudo make install

# Retourner dans le répertoire de travail, télécharger snort
cd ../ && wget https://www.snort.org/downloads/snort/snort-2.9.13.tar.gz

# Décompresser l'archive 
tar xvzf snort-2.9.13.tar.gz 
cd snort-2.9.13

# Configurer avec l'option sourcefire, compiler et installer 
./configure --enable-sourcefire && make && sudo make install

# Mettre à jour les librairies
ldconfig

# Creer un lien symbolique pour ajouter le binaire dans le PATH
ln -s /usr/local/bin/snort /usr/sbin/snort

# Créer les utilsiateurs et groupes pour lancer snort
groupadd snort
useradd snort -r -s /sbin/nologin -g snort

# Créer les répertoires de configuration
mkdir -p /etc/snort/rules
mkdir /var/log/snort
mkdir /usr/local/lib/snort_dynamicrules

# Set permissions
chmod -R 5775 /etc/snort
chmod -R 5775 /var/log/snort
chmod -R 5775 /usr/local/lib/snort_dynamicrules
chown -R snort:snort /etc/snort
chown -R snort:snort /var/log/snort
chown -R snort:snort /usr/local/lib/snort_dynamicrules

# Créer des fichiers de configuration vides
touch /etc/snort/rules/white_list.rules
touch /etc/snort/rules/black_list.rules
touch /etc/snort/rules/local.rules

# Récupérer les fichiers de configuration depuis le répertoire initial
cp /opt/snort_src/snort-2.9.13/etc/*.conf* /etc/snort
cp /opt/snort_src/snort-2.9.13/etc/*.map /etc/snort

# We will use community rules
wget https://www.snort.org/rules/community -O /tmp/community.tar.gz
tar xvzf /tmp/community.tar.gz -C /tmp
cp /tmp/community-rules/* /etc/snort/rules

# Comment include lines in configuration
sed -i 's/include \$RULE\_PATH/#include \$RULE\_PATH/' /etc/snort/snort.conf

# edit configuration
sed -i 's/ipvar HOME_NET any/ipvar HOME_NET 192.168.122.0\/24/' /etc/snort/snort.conf
sed -i 's/ipvar EXTERNAL_NET any/ipvar EXTERNAL_NET !\$HOME_NET' /etc/snort/snort.conf
sed -i 's/ipvar DNS_SERVERS \$HOME_NET/ipvar DNS_SERVERS 8.8.8.8' /etc/snort/snort.conf

sed -i 's/var RULE_PATH ..\/rules/var RULE_PATH \/etc\/snort\/rules/' /etc/snort/snort.conf
sed -i 's/var SO_RULE_PATH ..\/so_rules/var SO_RULE_PATH \/etc\/snort\/so_rules/' /etc/snort/snort.conf
sed -i 's/var PREPROC_RULE_PATH ..\/preproc_rules/var PREPROC_RULE_PATH \/etc\/snort\/preproc_rules/' /etc/snort/snort.conf

sed -i 's/var WHITE_LIST_PATH ..\/rules/var WHITE_LIST_PATH \/etc\/snort\/rules/' /etc/snort/snort.conf
sed -i 's/var BLACK_LIST_PATH ..\/rules/var BLACK_LIST_PATH \/etc\/snort\/rules/' /etc/snort/snort.conf

sed -i 's/# output unified2: filename merged.log, limit 128, nostamp, mpls_event_types, vlan_event_types/output unified2: filename snort.log, limit 128/' /etc/snort/snort.conf

sed -i 's/#include \$RULE\_PATH\local.rules/include \$RULE\_PATH\/local.rules/' /etc/snort/snort.conf
echo "include \$RULE_PATH/community.rules" >> /etc/snort/snort.conf

# Test the configuration
#snort -T -c /etc/snort/snort.conf

# Run 
#snort -A console -i enp7s0 -u snort -g snort -c /etc/snort/snort.conf 

