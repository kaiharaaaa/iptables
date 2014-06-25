#!/bin/sh

PATH=/sbin

HTTP=

iptables -N HTTP_DOS
iptables -A HTTP_DOS -p tcp -m multiport --dports $HTTP \
  -m hashlimit \
  --hashlimit 1/s \
  --hashlimit-burst 100 \
  --hashlimit-htable-expire 300000 \
  --hashlimit-mode srcip \
  --hashlimit-name t_HTTP_DOS \
  -j RETURN
iptables -A HTTP_DOS -j DROP

iptables -A INPUT -p tcp -m multiport --dports $HTTP -j HTTP_DOS

/etc/init.d/iptables save &&
/etc/init.d/iptables restart &&
exit 0
