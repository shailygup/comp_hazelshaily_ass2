#!/bin/bash

#------------------------------
#User configurations
#------------------------------
NAME= #Name of the utility you are using to implement the firewall
LOCATION= #location of the utility you are using to implement the firewall
IPRANGE= #Internal network address space
NET=  #the network device
TCPALLOW= #TCP services that will be allowed.
UDPALLOW= #UDP services that will be allowed
ICMPALLOW=  #ICMP services that will be allowed.
PORTDROP= #Ports to be dropped
HIGHPORT= #High ports

#------------------------------
#Implementation section
#------------------------------

#flush the firewall rules
iptables -F

#set the default policies to drop
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

#define chains
iptables -N tcpin
iptables -N tcpout
iptables -N udpin
iptables -N udpout
iptables -N icmpin
iptables -N icmpout
iptables -N tfrwd
iptables -N ufrwd
iptables -N ifrwd

# Allow inbound traffic from established connections.
# This includes ICMP error returns.
iptables A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

#Do not accept any packets with a source address from the outside matching your internal network
iptables -A FORWARD -s $IPRANGE -i $LOCATION -j DROP #NOT SURE IF THIS IS CORRECT, PLEASE CHECK

#Drop traffic that are coming in from high ports (inbound SYN patchets to high ports)
iptables -A tcpin -i $LOCATION -p tcp -m multiport --dport $HIGHPORT -j DROP #TEST
iptables -A tfrwd -i $LOCATION -m multiport --dport $HIGHPORT -j DROP

#Drop all packets where the SYN and FIN bits are set

#DROP ALL TELNET PACKETS - Not allowed at all
iptables -A tcpin -p tcp -m multiport --dport $PORTDROP -j DROP
iptables -A tcpout -p tcp -m multiport --sport $PORTDROP -j DROP

#Block all external traffic to 32768 – 32775, 137 – 139, TCP ports 111 and 515.


#Accept fragments -- will have to check notes on how to do this

#Set Special "Minimum Delay" for FTP and SSH services

#Allow all inbound traffic, REMEMBER TO ALLOW ESTABLISHED CONNECTION -- Still needs to be done
iptables -A tcpin -i $LOCATION -p tcp -m multiport --dport $TCPALLOW -m state --state NEW -j ACCEPT
iptables -A udpin -i $LOCATION -p tcp -m multiport --dport $UDPALLOW -m state --state NEW -j ACCEPT
iptables -A tfrwd

# Allow ping.
iptables -A icmpin -p icmp -m state --state NEW --icmp-type $ICMPALLOW -j ACCEPT


#Allow all outbound traffic
iptables -A tcpout -i $LOCATION -p tcp -m multiport --sport $TCPALLOW -m state --state NEW -j ACCEPT
iptables -A udpout -i $LOCATION -p tcp -m multiport --sport $UDPALLOW -m state --state NEW -j ACCEPT
iptables -A icmpout -i $LOCATION -p icmp -m state --icmp-type $ICMPALLOW -j ACCEPT

#Correlating tcpin/tcpout/udpin/udpout with the INPUT/OUTPUT rules
iptables -A INPUT -p tcp -j tcpin
iptables -A OUTPUT -p tcp -j tcpout
iptables -A INPUT -p udp -j udpin
iptables -A OUTPUT -p udp -j udpout
iptables -A INPUT -p icmp -j icmpin
iptables -A OUTPUT -p icmp -j icmpout
iptables -A FORWARD -p tcp -j tfrwd
iptables -A FORWARD -p udp -j ufrwd
iptables -A FORWARD -p icmp -j ifrwd
