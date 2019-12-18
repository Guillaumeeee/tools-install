# ATTENTION : ceci n'est pas un script d'installation, mais un tutoriel.

# Run a openvpn tunnel
# Needed tools : openvpn
# Installation : repository

# Create easy_rsa folder to get all scripts to build keys
mkdir /etc/openvpn/easy_rsa/

# Copy all template files from embedded documentation
cp -r /usr/share/doc/openvpn/examples/easy-rsa/2.0/* /etc/openvpn/easy_rsa/

# If official, fill 'vars' file. If not, don't.
vim /etc/openvpn/easy_rsa/vars

export KEY_COUNTRY="FR"
export KEY_PROVINCE="FR"
export KEY_CITY="FR"
export KEY_ORG="exemple.com"
export KEY_EMAIL="exemple@exemple.com"

# Generate keys & cert for server
cd /etc/openvpn/easy_rsa
mkdir keys
source vars 	# refresh 'vars' file to get new infos
./clean-all	# Deletes all previously created keys/certs
./build-dh	# Creates diffie-helmann key
./build-ca
./build-key-server <servername>	# Creates server certificates
	commun-name = <servername>
	sign the certificate = yes
	1 out of 1 certificate requests certificated, commit : yes
./build-key <clientname>	# Creates client keys & certs

# Create folders for chroot & client config
sudo mkdir /etc/openvpn/jail 	# chroot folder
sudo mkdir /etc/openvpn/clientconf	# client conf folder

# Copy config files from documentationto openvpn folder
cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/

# Unzip server conf file
gunzip /etc/openvpn/server.conf.gz

# Configuration on server conf file
server
port <port>	# beware the port is open on firewall/router
proto tcp
dev tun		# tun is a routed vpn. tap is a bridged vpn. tap is used for local networks
ca /etc/openvpn/easy_rsa/keys/ca.crt
cert /etc/openvpn/easy_rsa/keys/n0x-vpn.crt
key /etc/openvpn/easy_rsa/keys/n0x-vpn.key # keep secret
dh /etc/openvpn/easy_rsa/keys/dh1024.pem
# You can add files directly in conf files (for example to connect a smartphone to the vpn tunnel)
<ca>
-----BEGIN CERTIFICATE-----
...........

...........
-----END CERTIFICATE-----
</ca>
<cert>
-----BEGIN CERTIFICATE-----
...........

...........
-----END CERTIFICATE-----
</cert>
<key>
-----BEGIN PRIVATE KEY-----
...........

...........
-----END PRIVATE KEY-----
<key>
server 10.10.10.0 255.255.255.248	# VPN ip range
push "redirect-gateway def1 bypass-dhcp"	# Route all client traffic through VPN
client-to-client	# Allow client to see each other
cipher AES-128-CBC	# AES cipher. Client's must be the same
max-clients 6
user nobody		# Reduce openvpn rights
group nogroup
status openvpn-status.log	# Logs file for current connections

# Start openvpn server
service openvpn start

# Enable ip forward 
echo 1 > /proc/sys/net/ipv4/ip_forward

# Persistant 
vim /etc/sysctl.conf
net.ipv4.ip_forward = 1

# Enable NAT on server 
iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -o venet0 -j MASQUERADE

# Persistant
echo "iptables-save > /etc/iptables.rules"

# Check if all's okay
ip a
14: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 100
    link/none 
    inet 10.10.10.1 peer 10.10.10.2/32 scope global tun0

# Configure client

# Client needs 4 files from server : ca.crt <clientname>.crt <clientname>.key client.conf
copywith scp, send by mail...

# Configure client.conf file
client
dev tun		# Same as server
proto tcp	# Same as server
remote 198.50.151.3 443		# Server ip & port
ca /etc/openvpn/easy_rsa/keys/ca.crt
cert /etc/openvpn/easy_rsa/keys/n0x.crt
key /etc/openvpn/easy_rsa/keys/n0x.key
cipher AES-128-CBC


# Connexion 
openvpn /etc/openvpn/config/client.conf
