#!/bin/bash
#Non POSIX script
#LE CORRE Benoit - 17/09/2019
#Opennebula Cluster deployment script for master node

###################
#      PARAMS     #
###################
#VIP configuration (Virtual IP for the cluster with his CIDR)
vip_address="192.168.50.10"
vip_cidr="24"
vip_interface="vmbr50"

#Database access for backup
mysql_user="oneadmin"
mysql_password="passwd"
mysql_database="opennebula"
###################

#Check if input variable is empty
if [ -z $1 ]
then
        echo "usage: ./oned_follower.sh [SERVER_ID]"
        echo "You nedd to edit oned_follower.sh for set VIP and mysql parameters."
        exit;
fi

#Stop opennebula
systemctl stop opennebula

#Restore opennebula database
su -c "onedb restore -f -u $mysql_user -p $mysql_password -d $mysql_database /tmp/mysql_localhost_opennebula_*.sql" - oneadmin

#Delete old .sql
rm /tmp/mysql_localhost_opennebula_*.sql

#Set SERVER_ID with input variable $1 for follower
sed -i "s/^\s\s\s\sSERVER_ID\s\s\s\s\s=\s-1,/    SERVER_ID     = $1,/g" /etc/one/oned.conf

#Set VIP configuration
sed -i 's/.*# Executed when a server transits from follower->leader.*/RAFT_LEADER_HOOK = [\n    COMMAND = "raft\/vip.sh",\n    ARGUMENTS = "leader '$vip_interface' '$vip_address'\/'$vip_cidr'"\n]\n\n&/' /etc/one/oned.conf
sed -i 's/.*# Executed when a server transits from follower->leader.*/RAFT_FOLLOWER_HOOK = [\n    COMMAND = "raft\/vip.sh",\n    ARGUMENTS = "follower '$vip_interface' '$vip_address'\/'$vip_cidr'"\n]\n\n&/' /etc/one/oned.conf

#Set Recovery Host fails (Resched VMs)
sed -i 's/^#HOST_HOOK\s=\s\[/HOST_HOOK = [/g' /etc/one/oned.conf
sed -i 's/^#\s\s\s\sNAME\s\s\s\s\s\s=\s"error",/    NAME      = "error",/g' /etc/one/oned.conf
sed -i 's/^#\s\s\s\sON\s\s\s\s\s\s\s\s=\s"ERROR",/    ON        = "ERROR",/g' /etc/one/oned.conf
sed -i 's/^#\s\s\s\sCOMMAND\s\s\s=\s"ft\/host_error.rb",/    COMMAND   = "ft\/host_error.rb",/g' /etc/one/oned.conf
sed -i 's/^#\s\s\s\sARGUMENTS\s=\s"$ID\s-m\s-p\s5",/    ARGUMENTS = "$ID -m -p 5",/g' /etc/one/oned.conf
sed -i 's/^#\s\s\s\sREMOTE\s\s\s\s=\s"no"\s]/    REMOTE    = "no" ]/g' /etc/one/oned.conf

#Start opennebula
systemctl start opennebula
