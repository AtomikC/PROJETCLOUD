#!/bin/sh

# Script de visualisation du remplacement d'une chaine de caractère dans un fichier par une autre chaine de caractère
# Script créé par Florian LEAU (florian.leau@gmail.com) le 16/09/2019
# Nom du script : show-replace-carac.sh
# Version 1.1
# Dernière modification le 19/09/2019 par FL

# AXES D'AMELIORATION :
# Prise en compte du paramètre espace/tab
# Différenciation du sed utilisé lorsque les paramètres recherché/à remplacer sont des caractères spéciaux (/ & : $)

func_script_usage()
{
    echo "Usage : $0 [chemin du fichier à modifier] [caractère à remplacer] [caractère de remplacement]"
}

func_visu_modif()
{
    #echo "$@"
    # Vérification du nombre de paramètres au lancement de la fonction
    if [ $# -gt 0 -a $# -lt 4 ]
    then
        # Vérification que le premier paramètre est un chemin de fichier
        if [ -f "$1" ]
        then
            # Test si les caractères de remplacement sont définis en entrée de la fonction
            if [ ! -z "$2" ];then
                # Le paramètre $2 a été renseigné par l'utilisateur. La variable recherché $var2 prend la valeur de $2
                var2=$2
            else
                # Déclaration du caractère par défaut à rechercher pour le remplacement dans le fichier $1
                var2=" "
            fi
            if [ ! -z "$3" ];then
                # Le paramètre $3 a été renseigné par l'utilisateur. La variable a remplacé $var3 prend la valeur de $3
                var3=$3
            else
                # Déclaration du caractère par défaut qui remplace le caractère recherché $2/$var2 dans le fichier $1
                var3=" "
            fi

            # Remplacement du caractère $2 dans le fichier $1 par le caractère $3
            #if [ "$2" -neq ":" ];then
            #	echo "coucou51"
            #	# Traitement du cas où le caractère recherché est un /
            #	sed -e "s:$var2:$var3:g" $1
            #else
            #	echo "coucou52"
            #	# Sinon, dans tous les autres cas, on utilise cette écriture de sed
            #	sed -e "s/$var2/$var3/g" $1
            sed -e "s/$var2/$var3/g" $1
            #fi
        else
            # Si le chemin du fichier $1 n'existe pas, on appelle la fonction func_script_usage comment utiliser le script
            func_script_usage
        fi
    else
        # Si le nombre d'argument est invalide, on appelle la fonction func_script_usage pour indiquer comment utiliser le script
        func_script_usage
    fi
}

main_function()
{
    func_visu_modif $1 $2 $3
}

# Lancement de la fonction principale main_function
main_function $1 $2 $3