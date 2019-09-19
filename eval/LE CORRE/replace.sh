#!/bin/sh
#Script POSIX


replace_text () {
	#Si notre $1 est vide, nous affichons comment utiliser le script
	if [ -z $1 ]
	then
		echo "Usage: ./replace.sh [File path] or Usage: ./replace.sh [search string] [replace string] [File path]"
		#Paramétre manquant on quitte le script
		exit
	fi

	#Nous vérifions que notre premier paramétre est un fichier
	if [ -f $1 ]
	then
		#Si c'est un fichier nous réalisons une action standard (remplacer les : par un espace)
		sed "s/:/ /g" $1
	else
		#Si notre premier argument n'est pas un fichier il s agit du paramétre [search string]
		sed "s/$1/$2/g" $3
	fi
}

replace_text $1 $2 $3
