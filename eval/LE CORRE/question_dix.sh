#!/bin/sh
#Script POSIX

#Fonction count_ip permettant de renvoyer le nombre d'IPv4 & 6 configurée(s) sur l OS
count_ip () {
	#Nous listons le résultat de la commande ip a et nous comptons le nombre de lignes inet qui correspondent a une ip configurée sur le système (2 appels système)
	ip a | grep -c "inet"
	#Nous n avons pas besoin d une gestion d'erreur car si nous n avons pas d IP nous avons 0 comme retour nous comptons bien le nombre d IP
}

#Appel de la fonction pour afficher le résultat
count_ip