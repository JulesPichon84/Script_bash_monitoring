#!/bin/bash

# On récipère le nom d'utilisateur passé en argument
echo "Entrer le nom de l'utilisateur:"
read username

# On définit le chemin du fichier où l'on va stocker toutes les informations
fichier_sortie=/root/linux/fichier.txt


# On affiche l'historique des connexions et deconnexions ainsi que des commandes passées en paramètre dans le fichier de sortie.
historique(){
        last "$username" | head -n -2 | sort > "$fichier_sortie"
        tail -n +$(wc -l < "$fichier_sortie") "$fichier_sortie"
	cat "/home/$username/.bash_history" >> "$fichier_sortie"
}


############################################################################################
############################################################################################


# On vérifie l'intégrité des fichiers critiques
verifier_fichiers(){
fichiers_critiques=(
	"/bin/bash"
	"/etc/shadow"
	"/etc/passwd"
	"/etc/hosts"
	"/etc/sudoers"
)

# On récupère les hash des fichiers critiques à l'aide de la commande sha256sum
hash_attendus=(
	"d86b21405852d8642ca41afae9dcf0f532e2d67973b0648b0af7c26933f1becb"
	"a677fc4506882e66290cdb321111a6c78f4feb619543d6bc2c069aeb2cb18892"
	"d3065637e105d31f82fdae446f3ec4128baa630a9d387e41a726d95cd8a819d1"
	"5c98a985d14de61e0918a342aafac6ef5c45f85c85122e444af7eabdf2b15278"
	"bdf5fecb6f3b1585954bcf9f6cbe6d5b59525ce87249570fff4a4972afdc000f"
)

# Comparaison des hashs attendus et des hashs obetnus
for ((i=0; i<${#fichiers_critiques[@]}; i++)); do
	fichier="${fichiers_critiques[$i]}"
	hash_attendu="${hash_attendus[$i]}"

	hash_obtenus=$(sha256sum "$fichier" | awk '{print $1}')

	if [[ $hash_obtenus == "$hash_attendu" ]]; then
		echo "Vérification de l'intégrité du fichier $fichier : SUCCES"
                echo "Le fichier $fichier est intact !" >> "$fichier_sortie"
	else
		echo "Vérification de l'intégrité du fichier $fichier : ECHEC"
                echo "Le fichier $fichier a été modifié ou est corrompu !" >> "$fichier_sortie"
	fi
done
}

#########################################################################################
#########################################################################################


# Fonction pour afficher l'état du réseau de la machine virtuelle
afficher_etat_reseau(){
	vnstat -m >> "$fichier_sortie"
	nmap -A 10.0.2.15 >> "$fichier_sortie"	# Scan du réseau
}



#########################################################################################
#########################################################################################


# Appeler les fonctions
historique
verifier_fichiers
afficher_etat_reseau


# On affiche un message de confirmation
echo "Le script a bien été exécuté !"


### Fin du script ###
 
