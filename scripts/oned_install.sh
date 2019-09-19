#!/bin/bash
#Non POSIX script
#LE CORRE Benoit - 17/09/2019
#Opennebula install script

###################
#      PARAMS     #
###################
#Database creation and configuration
mysql_user="oneadmin"
mysql_password="passwd"
mysql_database="opennebula"

#OpenNebula password
oned_passwd="passwd"
###################

#Download and install OpenNebula
apt install apt-transport-https -y
wget -q -O- https://downloads.opennebula.org/repo/repo.key | apt-key add -
echo "deb https://downloads.opennebula.org/repo/5.8/Debian/9 stable opennebula" > /etc/apt/sources.list.d/opennebula.list
apt update
apt-get install opennebula opennebula-sunstone opennebula-gate opennebula-flow -y
/usr/share/one/install_gems

# Install mariadb-server
apt install mariadb-server -y
# Chnage listen interface to any
sed -i 's/127.0.0.1/*/g' /etc/mysql/mariadb.conf.d/50-server.cnf
systemctl restart mariadb-server

# Create database an oneadmin MySQL user
mysql -u root -e "create database $mysql_database;"
mysql -u root -e "GRANT ALL PRIVILEGES ON $mysql_database.* TO "$mysql_user"@'localhost'IDENTIFIED BY "$mysql_password" WITH GRANT OPTION;"
mysql -u root -e "SET GLOBAL TRANSACTION ISOLATION LEVEL READ COMMITTED;"

# Comment default DB (sqlite)
sed -i 's/^DB/#DB/g' /etc/one/oned.conf

# UNCOMMENT MYSQL SERVEUR CONFIGURATION
sed -i 's/^#\sDB\s=/DB =/g' /etc/one/oned.conf
sed -i 's/^#\s\s\s\s\s\s\s\sSERVER/        SERVER/g' /etc/one/oned.conf
sed -i 's/^#\s\s\s\s\s\s\s\sPORT/        PORT/g' /etc/one/oned.conf
sed -i 's/^#\s\s\s\s\s\s\s\sUSER/        USER/g' /etc/one/oned.conf
sed -i 's/^#\s\s\s\s\s\s\s\sPASSWD/        PASSWD/g' /etc/one/oned.conf
sed -i 's/^#\s\s\s\s\s\s\s\sDB_NAME/        DB_NAME/g' /etc/one/oned.conf
sed -i 's/^#\s\s\s\s\s\s\s\sCONNECTIONS/        CONNECTIONS/g' /etc/one/oned.conf

# SET MYSQL PASSWORD
sed -i 's/PASSWD\s\s=\s"oneadmin"/PASSWD  = "$mysql_password"/g' /etc/one/oned.conf


# OpenNebula oneadmin Password
su -c "echo "oneadmin:$oned_passwd" > ~/.one/one_auth" - oneadmin

# Install OpenNebula Node
apt-get install opennebula-node -y
service libvirtd restart


# Start OpenNebula
systemctl enable opennebula
systemctl start opennebula
systemctl enable opennebula-sunstone
systemctl start opennebula-sunstone
