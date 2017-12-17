#!/bin/bash

stop_iptables(){
    iptables -F
    iptables -X
    iptables -Z
    iptables -P INPUT ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -F -t nat
    iptables -X -t nat
    iptables -Z -t nat
    iptables -t nat -P PREROUTING ACCEPT
    iptables -t nat -P POSTROUTING ACCEPT
    iptables -t nat -P OUTPUT ACCEPT
#    echo "0" > /proc/sys/net/ipv4/ip_forward
}

if [ $# -ne 1 ]
then
    echo "Usage `basename $0` : [start|stop]"
    exit 1
fi

case "x$1" in 
    "xstop")
        stop_iptables
        exit 0
        ;;
    "xstart")
        ;;
esac

# set policy
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

## user defined chain
iptables -N allowed
iptables -N tcp_packet
iptables -N udp_packet
iptables -N icmp_packet
iptables -N bad_tcp_packet

# bad tcp_packets chain
iptables -A bad_tcp_packet -p tcp --tcp-flags SYN,ACK SYN,ACK -m state --state NEW -j REJECT --reject-with tcp-reset
iptables -A bad_tcp_packet -p tcp ! --syn -m state --state NEW -j DROP

# allowed chain
iptables -A allowed -p tcp --syn -j ACCEPT
iptables -A allowed -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A allowed -p tcp -j DROP

# tcp rules
ports="9999 443 80" 
#开放的服务端口号
for i in $ports
do
    iptables -A tcp_packet -p tcp --dport $i -j allowed
done

# udp rules
iptables -A udp_packet -p udp --dport 53 -j ACCEPT

# icmp rules
iptables -A icmp_packet -p icmp --icmp-type 8 -j ACCEPT

# tcp packet will check first by bad_tcp_packet chain
iptables -A INPUT -p tcp -j bad_tcp_packet

# for loopback interface
iptables -A INPUT -i lo -j ACCEPT

# rules for packet from internet
iptables -A INPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -j tcp_packet
iptables -A INPUT -p udp -j udp_packet
iptables -A INPUT -p icmp -j icmp_packet
