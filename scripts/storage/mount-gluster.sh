#!/bin/bash
#Script non posix
#LEAU Florian
#Script de montage des volumes

sleep 10

# Nom du serveur local glusterfs
serveur=gluster1

# Montage des volumes
su -c "mount -t glusterfs $serveur:/vol1 /mnt/vol1" - root
su -c "mount -t glusterfs $serveur:/vol2 /mnt/vol2" - root
