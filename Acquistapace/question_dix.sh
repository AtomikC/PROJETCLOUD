#!/bin/sh
 
# Script de d�compte des addresses IP sur une machine Linux
# Cr�� par L�o ACQUISTAPACE le 19/09/2019

#Premi�re piste : hostname -I retourne toutes les IPs d�finies, s�par�es par un espace

search=$(hostname -I) #On r�cup�re ces IPs dans une variable "search"
cpt=0 #On d�finit un compteur � 0 (Pour compter les IPs)
ips="" #On d�finir une cha�ne vide pour stocker les IPs

for i in `echo $search | tr " " " "` #On parcours la variable, chaque espace = une donn�e = une IP 
do 
	cpt=$(($cpt + 1)) #On incr�mente le compteur
	ips="${ips} #- ${i}" #On incr�mente la cha�ne avec les IPs trouv�es
	#echo $i 
done
echo "Cette machine Linux possede $cpt addresse(s) IP definie(s) : $ips"

#Seconde piste : "ip a" liste les cartes et leurs IPs

searchAll=$(ip a) #On r�cup�re ces informations dans une variable "search"

echo $searchAll | grep "^\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}$" #On essaie de trier ce retour par une expression r�guli�re ne gardant que les IPs

##-Plus de temps-##
