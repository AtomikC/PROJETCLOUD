#!/bin/bash
#Non POSIX script
#LE CORRE Benoit - 17/09/2019
#Opennebula Cluster deployment script for master node

###################
#      PARAMS     #
###################
#Opennebula nodes list (3 nodes)
server0=$HOSTNAME
server1="SRV2"
server2="SRV3"

#VIP configuration (Virtual IP for the cluster with his CIDR)
vip_address="192.168.50.10"
vip_cidr="24"
vip_interface="vmbr50"

#Database access for backup
mysql_user="oneadmin"
mysql_password="passwd"
mysql_database="opennebula"
###################


#Scan SSH KEY and copy to other nodes
su -c "ssh-keyscan $server0 $server0 $server1 $server2 >> /var/lib/one/.ssh/known_hosts" - oneadmin
scp -rp /var/lib/one/.ssh $server0:/var/lib/one/
scp -rp /var/lib/one/.ssh $server1:/var/lib/one/
scp -rp /var/lib/one/.ssh $server2:/var/lib/one/

#Start opennebula service
systemctl start opennebula
sleep 5

#Add nodes to HA zone 0
onezone server-add 0 --name $server0 --rpc http://SRV1:2633/RPC2
onezone server-add 0 --name $server1 --rpc http://SRV2:2633/RPC2
onezone server-add 0 --name $server2 --rpc http://SRV3:2633/RPC2

#After 5 seconds, stop opennebula service
sleep 5
systemctl stop opennebula

#Set SERVER_ID = 0 for master server
sed -i 's/^\s\s\s\sSERVER_ID\s\s\s\s\s=\s-1,/    SERVER_ID     = 0,/g' /etc/one/oned.conf

#Backup opennebula database
su -c "onedb backup -u $mysql_user -p $mysql_password -d $mysql_database" - oneadmin

#Send database backup to other nodes
su -c "scp /var/lib/one/mysql_localhost_opennebula_*.sql $server1:/tmp" - oneadmin
su -c "scp /var/lib/one/mysql_localhost_opennebula_*.sql $server2:/tmp" - oneadmin

#Delete old .sql
rm /tmp/mysql_localhost_opennebula_*.sql

#Replace .one directory to other nodes
su -c "ssh $server1 rm -rf /var/lib/one/.one" - oneadmin
su -c "scp -r /var/lib/one/.one/ $server1:/var/lib/one/" - oneadmin
su -c "ssh $server2 rm -rf /var/lib/one/.one" - oneadmin
su -c "scp -r /var/lib/one/.one/ $server2:/var/lib/one/" - oneadmin

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
sleep 10


