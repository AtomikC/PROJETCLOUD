#!/bin/bash

# Script créé par Florian LEAU (florian.leau@gmail.com) le 18/09/2019
# Nom du script : auto-build-img-packer
# Version : 0.9.3
# Dernière modification le 19/09/2019 par FL
# Description du script : Mise en place et exploitation des recettes Packer nécessaire pour la génération automatique d'images système et de leur importation dans le datastore d'OpenNebula

# --- Brique de code restant à développer :
# Vérification du noeud maitre OpenNebula        ==> OK
# Vérification présence de l'applicatif packer   ==> OK
# Vérification/import des recettes depuis Git    ==> OK
# Fonction de création des images système pour les templates VM OpenNebula   ==> En cours / A deboguer
# Import et remplacement des images système d'exploitation dans les templates VM actuels d'OpenNebula   ==> A faire
# Débogage code v0.9.1 ==> OK
# logger -t $0 "Erreur"
# oneimage create --name Alpine_IMG_OS_VirtIO_2 --path /var/tmp/alpine-virt-3.9-diiage.img --disk_type OS --prefix vd --driver qcow2 --datastore cluster_default
# ---

main_function()
{
    # --- Variables-paramètres pour les fonctions :
    url_dl_packer="https://releases.hashicorp.com/packer/1.4.3/packer_1.4.3_linux_amd64.zip"
    repo_recipes_packer="/opt/packer/recipes/"
    url_git_recipes_packer="https://github.com/AtomikC/PROJETCLOUD/archive/master.zip"
    # ---

    # Vérification que la machine exécutant ce script est le noeud maître du cluster OpenNebula
    # Si la machine est bien le noeud maître, func_verif_leader retourne 1 indiquant qu'il faut poursuivre l'exécution du script de génération des images des systèmes d'exploitation
    # Sinon, func_verif_leader retourne 0 et on arrête le script

    func_verif_leader2
    result_verif_leader=$?
    if [ "$result_verif_leader" -eq "1" ]; then
        logger -t $0 "Le serveur actuel est le noeud maître OpenNebula. Poursuite du script."

        # Vérification de l'existence de l'exécutable packer
        func_verif_packer $url_dl_packer

        # Création du dossier local de réception des recettes Packer
        func_verif_recipes $repo_recipes_packer

        # Import des recettes depuis Git
        func_recup_recipes $url_git_recipes_packer $repo_recipes_packer

        # Création des images système issu des recettes Packer
        #func_build_packer_img $repo_recipes_packer
    else
        # Arrêt du script
        logger -t $0 "Le serveur actuel n'est pas le noeud maître OpenNebula. Arrêt du script."
    fi
}

func_get_path_json()
{
    # l2=$(echo `find /opt/packer/recipes/ -name "*.json"`)
    # IFS=', ' read -r -a array <<< "$string"

    list_path_json=(echo `find $1 -name "*.json"`)
    echo "$list_path_json"
    # A REVOIR
    #array_path_json=()
    #IFS=' ' read -r -a array_path_json <<< "$list_path_json"
    #echo "1=$array_path_json"
    #echo "2=${array_path_json[*]}"
    #echo "3=${array_path_json[0]}"
    #echo "4=${array_path_json[1]}"
}

func_build_packer_img()
{
    ##### CODAGE EN COURS #####
    # Récupération des emplacements des fichiers .JSON nécessaire à la création des images systèmes avec Packer depuis l'emplacement des recettes ($1)
    func_get_path_json $1
    result_func_get_path_json=$?
    
    # Ajout du droit d'éxécution de l'applicatif packer
    chmod +x /opt/packer/packer

    # Création des images systèmes à partir des chemins de recettes Packer
    cd /opt/packer/
    # A AMELIORER POUR PRENDRE EN COMPTE PLUSIEURS CHEMINS
    ./packer build $result_func_get_path_json
}

func_recup_git_zip()
{
    # Vérification si un fichier master.zip existe déjà
    if [ -f "/tmp/master.zip" ]; then
        # Le fichier master.zip existe déjà, on le supprime
        rm /tmp/master.zip
    fi

    # Récupération du fichier zip issu de Git via l'adresse URL $1 et stockage dans le dossier /tmp
    wget $1 -P /tmp
}

func_recup_recipes()
{
    # Destruction d'un potentiel dossier dézippé provenant de Git issu d'un précédent lancement du script. 
    # Il n'y a pas de message d'erreur s'il n'y a aucun dossier présent
    rm -r /tmp/*-master* 2> /dev/null

    # Récupération du fichier zip depuis une URL Git ($1)
    func_recup_git_zip $1

    # Vérification de l'installation du paquet unzip
    func_verif_packet_install unzip

    # Décompression du fichier zip issu de Git
    unzip /tmp/master.zip -d /tmp/

    # Déplacement du contenu du dossier packer issu de Git dans le dossier /opt/packer/recipes ($2)
    mv /tmp/*-master/packer/* $2

    # Destruction du dossier dézippé et du fichier zip encore présent dans /tmp
    rm -r /tmp/*-master
    rm /tmp/master.zip
}

func_verif_recipes()
{
    # Vérification de l'existence du dossier /opt/packer/recipes. Si le dossier existe, mise en archive des fichiers et dossiers actuels.
    if [ -d "$1" ]; then
        # Le dossier existe, mise en archive des fichiers et dossiers actuels de $1 dans /opt/packer
        tar -zcvf /opt/packer/recipes-$(date +%F).tar.gz $1

        # Destruction du dossier $1
        rm -R $1
    fi

    # Création du dossier existant
    mkdir -p $1
}

func_verif_leader2()
{
    return 1
}

func_verif_leader()
{
    # Récupération du résultat si le nom de la machine actuelle est présent dans la liste des noeuds OpenNebula et si il est le noeud maître
    grep_result=`echo "\`onezone show 0 | grep $HOSTNAME | grep 'leader'\`"`

    # Vérification que la machine exécutant ce script est le noeud maître du cluster OpenNebula
    if [ "$grep_result" != "" ];then
        # Il y a un résultat dans la variable $grep_result, cela indique que la machine actuelle est le noeud maître 
        # On retourne à la fonction principale de poursuivre le script
        return 1
    else
        # Il n'y avait pas de résultat dans la variable $grep_result, cela indique que la machine actuelle n'est pas le noeud maître 
        # On retourne à la fonction principale d'arrêter le script
        return 0
    fi
}

func_verif_packet_install()
{
    # Vérification si le paquet $1 est déjà installé. Si ce n'est pas le cas, installation de $1.
    #verif_install=`dpkg --list "$1" | grep "un "`
    verif_install=`echo "\`dpkg --list $1 | grep "un "\`"`
    if [ "$verif_install" != "" ]; then
        apt update && apt install $1 -y
    fi
}

func_verif_packer()
{
    # Vérification de l'existence de l'exécutable packer
    if [ ! -f "/opt/packer/packer" ]; then
        # Vérification de l'existence du dossier /opt/packer
        if [ ! -d "/opt/packer/" ]; then
            mkdir /opt/packer/
        fi

        # Téléchargement du fichier zip packer et dépôt dans le dossier /opt/packer
        wget $1 -P /opt/packer

        # Vérification si le paquet unzip est installé puis décompression du fichier packer
        func_verif_packet_install unzip
        unzip /opt/packer/packer_*_linux_amd64.zip -d /opt/packer
    fi
}

# Lancement de la fonction principale main_function
logger -t $0 "Lancement du script d'auto-construction et intégration d'images système dans le datastore d'OpenNebula."
main_function
logger -t $0 "Fin du script d'auto-construction et intégration d'images système dans le datastore d'OpenNebula."
