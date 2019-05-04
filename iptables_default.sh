#!/bin/sh

IPT="/sbin/iptables"


# Flush all tables
${IPT} -t filter -F
${IPT} -t nat -F
${IPT} -t mangle -F
${IPT} -t raw -F 

# Delete non-builtin chains
${IPT} -t filter -X
${IPT} -t nat -X
${IPT} -t mangle -X
${IPT} -t raw -X

# Set policies to DROP by default / Let output frreeeeeee
${IPT} -t filter -P INPUT DROP
${IPT} -t filter -P FORWARD DROP
${IPT} -t filter -P OUTPUT ACCEPT

# ---

# Allow established sessions to go through
${IPT} -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Allow loopback
${IPT} -t filter -A INPUT -i lo -j ACCEPT

# ICMP
${IPT} -t filter -A INPUT -p icmp -j ACCEPT

# SSH
${IPT} -t filter -A INPUT -p tcp --dport 22 -j ACCEPT
