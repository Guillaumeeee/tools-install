#!/bin/sh

IPT="/sbin/iptables"
PORT_SSH=22

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

## NULL-SCAN
iptables -t filter -A INPUT -p tcp --tcp-flags ALL NONE -j LOG --log-prefix "[IPTABLES NULL-SCAN DROP] : "
iptables -t filter -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

## XMAS-SCAN
iptables -t filter -A INPUT -p tcp --tcp-flags ALL ALL -j LOG --log-prefix "[IPTABLES XMAS-SCAN DROP] : "
iptables -t filter -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

## SYNFIN-SCAN
iptables -t filter -A INPUT -p tcp --tcp-flags ALL SYN,FIN -j LOG --log-prefix "[IPTABLES SYNFIN-SCAN DROP] : "
iptables -t filter -A INPUT -p tcp --tcp-flags ALL SYN,FIN -j DROP

## NMAP-XMAS-SCAN
iptables -t filter -A INPUT -p tcp --tcp-flags ALL URG,PSH,FIN -j LOG --log-prefix "[IPTABLES NMAP-XMAS-SCAN DROP] : "
iptables -t filter -A INPUT -p tcp --tcp-flags ALL URG,PSH,FIN -j DROP

## FIN-SCAN
iptables -t filter -A INPUT -p tcp --tcp-flags ALL FIN -j LOG --log-prefix "[IPTABLES FIN-SCAN DROP] : "
iptables -t filter -A INPUT -p tcp --tcp-flags ALL FIN -j DROP

## NMAP-ID
iptables -t filter -A INPUT -p tcp --tcp-flags ALL URG,PSH,SYN,FIN -j LOG --log-prefix "[IPTABLES NMAP-ID DROP] : "
iptables -t filter -A INPUT -p tcp --tcp-flags ALL URG,PSH,SYN,FIN -j DROP

## SYN-RST
iptables -t filter -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j LOG --log-prefix "[IPTABLES SYN-RST DROP] : "
iptables -t filter -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP

## SYN-FLOOD
iptables -t filter -N SYN_FLOOD
iptables -t filter -A INPUT -p tcp --syn -j SYN_FLOOD
iptables -t filter -A SYN_FLOOD -m limit --limit 1/sec --limit-burst 4 -j RETURN
iptables -t filter -A SYN_FLOOD -j LOG --log-prefix "[IPTABLES SYN-FLOOD DROP] : "
iptables -t filter -A SYN_FLOOD -j DROP

## Make sure NEW tcp connections are SYN packets
iptables -t filter -A INPUT -p tcp ! --syn -m conntrack --ctstate NEW -j LOG --log-prefix "[IPTABLES SYN-FLOOD DROP] : "
iptables -t filter -A INPUT -p tcp ! --syn -m conntrack --ctstate NEW -j DROP

## port scaner
iptables -t filter -N PORT_SCAN
iptables -t filter -A INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RST -j PORT_SCAN
iptables -t filter -A PORT_SCAN -m limit --limit 1/s --limit-burst 4 -j RETURN
iptables -t filter -A PORT_SCAN -j LOG --log-prefix "[IPTABLES PORT-SCAN DROP] : "
iptables -t filter -A PORT_SCAN -j DROP

# SSH
/sbin/iptables -t filter -A INPUT -p tcp -m conntrack --ctstate NEW --dport ${SSH_PORT} -j LOG
/sbin/iptables -t filter -A INPUT -p tcp --dport ${SSH_PORT} -m recent --rcheck --seconds 60 --hitcount 4 --name SSH -j LOG 
/sbin/iptables -t filter -A INPUT -p tcp --dport 22 -m recent --update --seconds 160 --hitcount 2 --name SSH -j DROP
/sbin/iptables -t filter -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH -j ACCEPT
# Allow established sessions to go through
${IPT} -t filter -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

## Allow loopback
/sbin/iptables -t filter -I INPUT -i lo -j ACCEPT

## Allow ICMP
/sbin/iptables -t filter -A INPUT -p icmp -j ACCEPT

exit 0

# Log
${IPT} -t filter -A INPUT -j LOG --log-prefix "[IPTABLES INPUT DEFAULT DROP] : "
/sbin/iptables -t filter -A FORWARD -j LOG --log-prefix "[IPTABLES FORWARD DEFAULT DROP] : "
