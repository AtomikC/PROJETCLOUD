#!/bin/bash
#Non POSIX script
#LAMY Thomas
#Script de configuration réseau


sleep 15
#VMBR adress DIIAGE DMZ
ifdown vmbr60
ip addr add 10.5.60.1/16 dev vmbr60
ifup vmbr60

#VMBR address SERVEUR
ifdown vmbr50
ip addr add 192.168.50.1/24 dev vmbr50
ifup vmbr50

#Default route
ip route add default via 192.168.50.254

#Restart Nebula Front-End
systemctl restart opennebula-sunstone.service

