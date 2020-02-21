#! /bin/bash
#
# Written by tiix
#
# 13/02/2019
#
# Create and set new client chroot


if [ $EUID -ne 0 ]; then
	echo "Please run as root"
	exit
fi


BASEHOME="/home/sftp-chroot"
PASSWORD=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
GROUP=sftp_chroot_$1
USER=$1-sftp


# Checking arguments

if [ $# -eq 0 ]; then
	echo "Please add client name"
	echo "e.g. $0 tiix"
	exit
fi




# Group creation
	
echo "Group creation"
addgroup $GROUP




# SSH config

echo "Adding group matching to ssh config"
printf "\n" >> /etc/ssh/sshd_config
printf "Match group $GROUP\n" >> /etc/ssh/sshd_config
printf "    ChrootDirectory $BASEHOME/$1\n" >> /etc/ssh/sshd_config
printf "    ForceCommand internal-sftp\n" >> /etc/ssh/sshd_config
printf "    AllowTcpForwarding no\n" >> /etc/ssh/sshd_config


systemctl restart sshd.service




# User configuration

echo "Adding user"
useradd $USER --gid $GROUP --groups $GROUP -m -d $BASEHOME/$1 --shell /bin/false




# Password configuration

echo "Configuring password"
echo $USER:$PASSWORD | chpasswd




# Set rights

echo "Configuring rights"

chown root:root $BASEHOME/$1
chmod 755 $BASEHOME/$1
mkdir $BASEHOME/$1/writeable
chown $USER:$GROUP $BASEHOME/$1/writeable
chmod 775 $BASEHOME/$1/writeable




# Clean skeleton

rm -rf $BASEHOME/$1/.zsh*




# Print creds
echo "Username : $USER"
echo "Password : $PASSWORD"



exit
