#!/bin/sh

# Script de comptage du nombre d'adresses IP configurées sur une machine GNU/Linux
# Script créé par Florian LEAU (florian.leau@gmail.com) le 19/09/2019
# Nom du script : question_10.sh
# Version 0.1
# Dernière modification le 19/09/2019 par FL

# AXES D'AMELIORATION :
# Non utilisation des net-tools
# Exploiter "ip a" ou "/sbin/ip"
# Débugger ligne 29 -> fonctionne en ligne de commande

func_verif_packet_install()
{
    # Vérification si le paquet $1 est déjà installé. Si ce n'est pas le cas, installation de $1.
    verif_install=`dpkg --list '$1' | grep "un "`
    if [ "$verif_install" != "" ]; then
        apt update && apt install $1 -y
    fi
}

func_compt_ip_config()
{
    # Vérification si les paquets net-tools sont installés
    func_verif_packet_install net-tools

    # Comptage du nombre d'adresses IP configurées sur la machine GNU/Linux
    #d2=(`ifconfig | grep -o -E '((inet )(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))'`)
    count_ip=(`ifconfig | grep -o -E -c '((inet )(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))'`)
    echo "Il y a $count_ip adresses IP configurées sur cette machine. "
}

main_function()
{
    func_compt_ip_config
}

# Lancement de la fonction principale main_function
main_function
