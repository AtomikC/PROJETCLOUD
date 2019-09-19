#!/bin/sh

# boucle de verification du passage d'un argument
if [ $# -gt 1 ]
then
{
	echo "Le script doit etre executé de la maniere suivante : ./question_10.sh [nom_fichier_text] (a definir comme bon vous semble)"
}
else
{
	#on recupere le nombre de ligne contenant inet (ipv6 et ipv4 confondu) dans un fichier texte
	ip a | grep 'inet' > $1


	# on recupere le nombre de ligne contenue dans ce fichier
	nbligne=`wc -l $1`

	# on recupere juste le chiffre
	nbip=$(echo $nbligne | grep -o '[[:digit:]]*')

	#on affiche le nombre de ligne
	echo "Il y a $nbip adresse ip V4 et V6 configurées sur cette machine"
}
fi
