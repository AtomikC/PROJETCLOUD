#!/bin/sh
 
# Script de décompte des addresses IP sur une machine Linux
# Créé par Léo ACQUISTAPACE le 19/09/2019

#Première piste : hostname -I retourne toutes les IPs définies, séparées par un espace

search=$(hostname -I) #On récupère ces IPs dans une variable "search"
cpt=0 #On définit un compteur à 0 (Pour compter les IPs)
ips="" #On définir une chaîne vide pour stocker les IPs

for i in `echo $search | tr " " " "` #On parcours la variable, chaque espace = une donnée = une IP 
do 
	cpt=$(($cpt + 1)) #On incrémente le compteur
	ips="${ips} #- ${i}" #On incrémente la chaîne avec les IPs trouvées
	#echo $i 
done
echo "Cette machine Linux possede $cpt addresse(s) IP definie(s) : $ips"

#Seconde piste : "ip a" liste les cartes et leurs IPs

searchAll=$(ip a) #On récupère ces informations dans une variable "search"

echo $searchAll | grep "^\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}$" #On essaie de trier ce retour par une expression régulière ne gardant que les IPs

##-Plus de temps-##
