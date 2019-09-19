#!/bin/sh

##############################################################################################################
# Script de création d'une version "Human Readable" d'un Fichier donné en paramètre
# L'utilisateur donne un fichier, un caractère à rechercher, un caractère de remplacement
# On lui fournit en résultat le contenu du fichier avec le caractère recherché remplacé par le caractère dédié
##############################################################################################################
# Créé par Léo ACQUISTAPACE le 19/09/2019
#Ce script semble POSIX

######################  TEST AVEC UNE FONCTION & AWK ###############################
#On donne le contenu de "src" à un fichier "result.txt", version Human Readable

#GivanHR() #Fichier source en paramètre
#{
#	if [ -f $1] #Si le paramètre est un FICHIER
#	then
#		echo $1 "est un fichier"
#		#$1 = Login => $6 = HomePath => $7 =  shell
#		#awk -F "\:" '{print $1" => "$6" => "$7}' $1 > result.txt
#	else
#		echo $1 "n'est pas un fichier"
#	fi
#}
#GivanHR

#findReplace()
#{
	if [ $# -gt 0 ] #S'il y à plus d'un  paramètre
	then
		if [ -f $1 ] #Si le premier paramètre est un fichier
		then
			if [ ! -z $2 ] #Si le second paramètre n'est pas vide
			then
				if [ ! -z $3 ] #Si le troisième paramètre n'est pas vide
				then
					search=$2 #On définit le caractère cherché par l'utilisateur
					replace=$3 #On définit le caractère de remplacement donné par l'utilisateur
				fi
			else #Sinon, si l'utilisateur ne donne aucun paramètre
				search=":" #On recherche :, par défaut
				replace=" " #On remplace par ESPACE, par défaut
			fi
			#On remplace le cractère cherché par le remplacement dans le fichier $1
			sed -i "s/$search/$replace/g" $1  > result.txt #on enregistre le résultat dans le fichier
			echo "OK, le résultat devrait de trouver dans result.txt mais le fichier en paramètre à été directement modifié" #On confirme que c'est fait
		fi
	else
        	echo "Usage : ./script.sh [chemin du fichier à modifier] [caractère à chercher] [caractère de remplacement]"
		echo "Une utilisation du script sans paramètres utilisera les valeurs par défauts : $search & $replace"
	fi
#}

#findReplace
#Passer les paramètres à la fonction, dans un script ...


