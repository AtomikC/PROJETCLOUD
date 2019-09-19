#!/bin/sh

# Script créé par Florian LEAU (florian.leau@gmail.com) le 18/09/2019
# Nom du script : auto-build-img-packer
# Version : 0.9.1
# Dernière modification le 19/09/2019 par FL
# Description du script : Mise en place et exploitation des recettes Packer nécessaire pour la génération automatique d'images système et de leur importation dans le datastore d'OpenNebula

# --- Brique de code restant à développer :
# Vérification du noeud maitre OpenNebula        ==> OK
# Vérification présence de l'applicatif packer   ==> OK
# Vérification/import des recettes depuis Git    ==> OK
# Création des images système pour les templates VM OpenNebula   ==> En cours
# Import et remplacement des images système d'exploitation dans les templates VM actuels d'OpenNebula   ==> A faire
# Débogage code v0.9.1
# logger -t $0 "Erreur"
# ---

main_function()
{
    # --- Variables-paramètres pour les fonctions :
    url_dl_packer="https://releases.hashicorp.com/packer/1.4.3/packer_1.4.3_linux_amd64.zip"
    repo_recipes_packer="/opt/packer/recipes/"
    url_git_recipes_packer=""
    # ---

    # Vérification que la machine exécutant ce script est le noeud maître du cluster OpenNebula
    # Si la machine est bien le noeud maître, func_verif_leader retourne 1 indiquant qu'il faut poursuivre l'exécution du script de génération des images des systèmes d'exploitation
    # Sinon, func_verif_leader retourne 0 et on arrête le script

    ########## A REMODIFIER
    result_verif_leader=func_verif_leader2
    if [ "$result_verif_leader" == "1" ]; then
        logger -t $0 "Le serveur actuel est le noeud maître OpenNebula. Poursuite du script."
        
        # Vérification de l'existence de l'exécutable packer
        func_verif_packer $url_dl_packer
    
        # Création du dossier local de réception des recettes Packer
        func_verif_recipes $repo_recipes_packer

        # Import des recettes depuis Git
        func_recup_recipes $url_git_recipes_packer $repo_recipes_packer

        # Création des images système issu des recettes Packer
        func_build_packer_img $repo_recipes_packer
    else
        # Arrêt du script
        logger -t $0 "Le serveur actuel n'est pas le noeud maître OpenNebula. Arrêt du script."
    fi
}

func_build_packer_img()
{
    #################### A CODER
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
    # Récupération du fichier zip depuis une URL Git ($1)
    func_recup_git_zip $1

    # Vérification de l'installation du paquet unzip
    func_verif_packet_install unzip

    # Décompression du fichier zip issu de Git
    unzip /tmp/master.zip -d /tmp/

    # Déplacement du contenu du dossier packer issu de Git dans $2 (le dossier /opt/packer/recipes)
    mv /tmp/*-master/packer/* $2
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
    
    ########## A TESTER
    grep_result=`echo "\`onezone show 0 | grep $HOSTNAME | grep 'leader'\`"`
    #grep_result=`echo "\`onezone show 0 | grep '$HOSTNAME            leader'\`"`
    #grep_result=`echo "\`onezone show 0 | grep '$HOSTNAME leader'\`"`
    #grep_result=`echo "\`echo " 1 SRV2            leader     91         12531      12531      1     -1" | grep 'SRV2            leader'\`"`
    #grep_result=`echo "\`echo " 1 SRV2            leader     91         12531      12531      1     -1" | grep 'SRV2 leader'\`"`
    ########## 
    
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
    verif_install=`dpkg --list '$1' | grep "un "`
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
