#!/bin/bash

#déclarations constantes
START_NAME='stack-test'


#déclarations de couleurs
VERT="\033[1;32m"
ROUGE="\033[1;31m"
JAUNE="\033[1;33m"
GRAS="\033[1;37m"
NORMAL="\033[0;39m"
OK="${VERT}OK${NORMAL}"
ECHEC="${ROUGE}Echec${NORMAL}"
WARNING="${JAUNE}En cours${NORMAL}"

# Ports de départ pour MariaDB centralisé
BASE_DIR="$(dirname "$(realpath "$0")")/.."

# Ports de départ
START_HTTPD_SSL_PORT=12000


# Vérification de l'existance du réseau php-builder
if docker network ls | grep -q "$START_NAME-network"; then
    echo -en "$GRAS Using RELEASE_DIR: $GRAS $VERT Le réseau '$START_NAME-network' existe déjà.. $NORMAL"
    echo ""
else
    # Crée le réseau 'builder-network'
    #docker network create $START_NAME-network
    docker network create stack-network
    echo -en "$GRAS Using RELEASE_DIR: $GRAS $VERT Le réseau '$START_NAME-network' a été créé. $NORMAL"
        echo ""
fi


# Générer le nom de la stack avec la date et l'heure actuelles
#STACK_NAME="stack-builder-$(date +'%Y%m%d_%H%M%S')"
if [[ "$2" != "" ]]
then
	STACK_NAME="$START_NAME-$2"
else
	STACK_NAME="$START_NAME-$(date +'%Y%m%d_%H%M%S')"
fi

export RELEASE_DIR="../releases/$STACK_NAME"

# afficher le nom de la stack
echo -en "$GRAS Using STACK_NAME: $GRAS $VERT $STACK_NAME $NORMAL"
    echo ""


# afficher le release_dir (dossier avec le nom de stack)pour les versions
    echo -en "$GRAS Using RELEASE_DIR: $GRAS $VERT $RELEASE_DIR $NORMAL"
    echo ""
    

if [ ! -d "$RELEASE_DIR" ]; then
    echo -en "$GRAS Directory: $GRAS $VERT $RELEASE_DIR created $NORMAL"
    echo ""
    
    # créer le dossier avec le nom de la stack
    RELEASE_DIR="../releases/$STACK_NAME"
    mkdir -p "$RELEASE_DIR"
    #echo "Directory $RELEASE_DIR created."

fi


# Fonction pour trouver le prochain ID disponible pour un service
find_next_id() {
    local service=$1
    local max_id=0
    for container in $(docker ps -a --format "{{.Names}}" | grep "$service"); do
        id=$(echo $container | awk -F'-' '{print $NF}')
        if [[ $id =~ ^[0-9]+$ ]] && [ $id -gt $max_id ]; then
            max_id=$id
        fi
    done
    echo $((max_id + 1))
}
find_next_port() {
    local service=$1
    local max_id=0
    for container in $(docker ps -a --format "{{.Ports}}"); do
        id=$(echo $container | awk -F':' '{print $NF}' | awk -F'-' '{print $1}')
        if [[ $id =~ ^[0-9]+$ ]] && [ $id -gt $max_id ]; then
            max_id=$id
        fi
    done
    echo $((max_id + 1))
}


# Trouver les prochains IDs disponibles pour chaque service
WEB_ID=$(find_next_id "$START_NAME")
HTTPD_ID=$(find_next_id "$START_NAME")

# Calculer les ports en fonction des IDs
#WEB_PORT=$((START_WEB_PORT + WEB_ID))
#HTTPD_PORT=$((START_HTTPD_PORT + HTTPD_ID))
HTTPD_SSL_PORT=$(find_next_port)
echo "port : $HTTPD_SSL_PORT --"

if [[ "$HTTPD_SSL_PORT" -le 1000 ]]
then
    HTTPD_SSL_PORT=$START_HTTPD_SSL_PORT
fi


# Export Web_ID for httpd configuration
export WEB_ID=$WEB_ID



# Debug: Afficher les informations de lancement
#echo "Lancement de la $STACK_NAME avec les configurations suivantes:"
echo -en "$GRAS $VERT Lancement de la $STACK_NAME avec les configurations suivantes::  $NORMAL"
echo ""


# Lancer la nouvelle stack avec des variables d'environnement
#WEB_PORT=$WEB_PORT \
#HTTPD_PORT=$HTTPD_PORT \
HTTPD_SSL_PORT=$HTTPD_SSL_PORT \
WEB_ID=$WEB_ID \
HTTPD_ID=$HTTPD_ID \
STACK_NAME=$STACK_NAME \
START_NAME=$START_NAME \
docker-compose -p $STACK_NAME up -d



####################################################################################################
# Modification de fichier de conf keepalived qui permet de pointer vers le dernier conteneur (PROD)
####################################################################################################

if [ "$1" == "main" ]; then
    echo "Mode production détecté. Modification d'un fichier de configuration keepalived."
    echo ""
    CONFIG_FILE="/etc/keepalived/keepalived.conf"

    if [ -f "$CONFIG_FILE" ]; then
        echo -en "\r$GRAS $VERT modification du fichier $CONFIG_FILE . $NORMAL"
        echo -en " [ $WARNING ]"
        echo -en "\r$GRAS $VERT modification du fichier $CONFIG_FILE . $NORMAL"
        echo -en " [ $OK ]          "
        echo ""

        # Obtenir le dernier conteneur apache en cours d'exécution
        HTTPD_CONTAINER_NAME=$(docker ps -a --filter "name=httpd-builder" --format "{{.Names}} {{.CreatedAt}}" | sort -k2,3 | tail -n 1 | awk '{print $1}')

        # Vérifier si un conteneur apache a été trouvé
        if [ -z "$HTTPD_CONTAINER_NAME" ]; then
            echo "Aucun conteneur apache trouvé."
            exit 0
        fi

        # Attendre que le conteneur apache soit en cours d'exécution
        while true; do
            CONTAINER_STATUS=$(docker inspect -f '{{.State.Running}}' "$HTTPD_CONTAINER_NAME" 2>/dev/null)
            if [ "$CONTAINER_STATUS" == "true" ]; then
                break
            else
                echo "Waiting for the Apache container to be running..."
                sleep 1
            fi
        done

        # Obtenir l'adresse IP du conteneur apache
        HTTPD_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$HTTPD_CONTAINER_NAME")
        if [ -z "$HTTPD_IP" ]; then
            echo "Impossible d'obtenir l'adresse IP du conteneur Apache."
            exit 1
        else
            echo -en "\r$GRAS Apache container IP obtained: $GRAS $VERT $HTTPD_IP $NORMAL"
            echo -en " [ $WARNING ]"
            echo -en "\r$GRAS Apache container IP obtained: $GRAS $VERT $HTTPD_IP $NORMAL"
            echo -en " [ $OK ]          "
            echo ""
        fi

        # Définir le port SSL (assurez-vous que la variable $SSL_PORT est définie)
        SSL_PORT=443 

IP_PUBLIC=$(hostname -I | awk '{print $1}')
IP_DOCKER=$(ifconfig docker0 | grep 'inet ' | awk '{print $2}')

##############################################################################
# Ecriture dans le fichier keepalived.com
##############################################################################

echo "
vrrp_instance VI_1 {
    state MASTER
    interface eth0  # ou docker0 si vous utilisez cela pour le pont réseau
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1234
    }
    virtual_ipaddress {
        10.0.0.1  # Adresse IP virtuelle partagée
    }
}

virtual_server $IP_PUBLIC 443{
    delay_loop 6
    lb_algo rr  # Algorithme de load balancing: round-robin
    lb_kind NAT  # Load balancing de type Direct Routing

    persistence_timeout 30
    protocol TCP
        real_server $IP_DOCKER $HTTPD_SSL_PORT {
            weight 100  # Poids du serveur réel
            
            TCP_CHECK {
                connect_timeout 3  # Délai d'attente avant d'abandonner la tentative de connexion
                delay_before_retry 3  # Délai entre deux tentatives de connexion

            }
        }
}
 " > $CONFIG_FILE


        echo -en "\r$GRAS Le fichier $CONFIG_FILE a été mis à jour avec le bloc real_server pour l'adresse IP $GRAS $VERT 172.17.0.1 $NORMAL et le port $GRAS $VERT $HTTPD_SSL_PORT $NORMAL."
        echo -en " [ $WARNING ]"
        echo -en "\r$GRAS Le fichier $CONFIG_FILE a été mis à jour avec le bloc real_server pour l'adresse IP $GRAS $VERT 172.17.0.1 $NORMAL et le port $GRAS $VERT $HTTPD_SSL_PORT $NORMAL."
        echo -en " [ $OK ]          "
        echo ""

    else
        echo "Le fichier $CONFIG_FILE n'existe pas."
    fi
else
    echo "Aucun paramètre de production spécifié, lancement dans le mode par défaut."
fi

###############################
### redemarrage du service ####
###############################
#systemctl restart keepalived


#####################################
# Nettoyage des anciens contenaires #
#####################################

DOCKER_NB_KEEP_ONLINE=4
DOCKER_NB_KEEP_OFFLINE=10
DOCKER_NB_IMG=`docker ps | grep '0.0.0.0' | wc -l`

if [ "$DOCKER_NB_IMG" -ge "$DOCKER_NB_KEEP_ONLINE" ]
then
    
    # suppression des contenaires qui commence par "le nom de la stack"
    DOCKER_NB_KEEP=$DOCKER_NB_KEEP_ONLINE
    CONTAINERS_TO=$(docker ps -a --format '{{.ID}} {{.Names}} {{.CreatedAt}}' | sort -r -k3 | tail -n +$DOCKER_NB_KEEP | awk -v stack_name="$STACK_NAME" '$2 ~ "^" stack_name {print $1}')

      if [ -n "$CONTAINERS_TO" ]; then
          echo "$CONTAINERS_TO" | xargs docker stop
      fi

fi


if [ "$DOCKER_NB_IMG" -ge "$DOCKER_NB_KEEP_OFFLINE" ]
then

      # suppression des contenaires qui commence par "le nom de la stack"
      DOCKER_NB_KEEP=$DOCKER_NB_KEEP_OFFLINE
      CONTAINERS_TO=$(docker ps -a --format '{{.ID}} {{.Names}} {{.CreatedAt}}' | sort -r -k3 | tail -n +$DOCKER_NB_KEEP | awk -v stack_name="$STACK_NAME" '$2 ~ "^" stack_name {print $1}')

      if [ -n "$CONTAINERS_TO" ]; then
          echo "$CONTAINERS_TO" | xargs docker rm
      fi
      
 fi
