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

#------------------------------
#Implementation section
#------------------------------

#flush the firewall rules
iptables -F

#set the default policies to drop
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
