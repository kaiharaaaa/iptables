#!/bin/sh

PATH=/sbin

TCP_OPEN_PORTS=()

UDP_OPEN_PORTS=()

ALLOW_HOSTS=()

DENY_HOSTS=()

# initialize
iptables -F
iptables -X
iptables -Z
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

iptables -A INPUT -p tcp -s 192.168.0.0/24 -j ACCEPT
for allow_host in ${ALLOW_HOSTS[@]}; do
  iptables -A INPUT -p tcp -s $allow_host -j ACCEPT
done

for tcp_open_port in ${TCP_OPEN_PORTS[@]}; do
  iptables -A INPUT -p tcp -m multiport --dports $tcp_open_port -j ACCEPT
done
for udp_open_port in ${UDP_OPEN_PORTS[@]}; do
  iptables -A INPUT -p udp -m multiport --dports $udp_open_port -j ACCEPT
done

# Deny
for deny_host in ${DENY_HOSTS[@]}; do
  iptables -A INPUT -s $deny_host -j DROP
done

/etc/init.d/iptables save &&
/etc/init.d/iptables restart &&
exit 0
