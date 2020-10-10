#!/bin/bash

USERNAME=louis
DOWNLOAD_PATH=/home/$USERNAME/Téléchargements

#LOG_FILE=/home/user/download_log


# Chemins vers les differents dossiers
JAR_PATH=$DOWNLOAD_PATH"/java_files"
ZIP_PATH=$DOWNLOAD_PATH"/zip_files"
VIDEO_PATH=/home/$USERNAME/Vidéos
GZ_PATH=$DOWNLOAD_PATH"/gz_files"
IMG_PATH=/home/$USERNAME/Images
DOC_PATH=/home/$USERNAME/Documents
DEB_PATH=$DOWNLOAD_PATH"/deb_files"
ISO_PATH=$DOWNLOAD_PATH"/iso_files"
MP3_PATH=/home/$USERNAME/Musique
SERVICE_PATH=/etc/systemd/system
SERVICE_FILE=dlmanager.service
RAW_URL=https://raw.githubusercontent.com/Lordva/Download_manager/master/dlmanager.service
BIN_PATH=/bin/dlmanager
NO_SERVICE_ARG=--no-service
HELP_ARG=--help
FOLDER_SAVE=.folders
DL_SAVE=.dl

PATHS=(jar zip VIDEOS .gz IMAGES DOCS deb iso mp3)
VIDEOS=(mp4 wav)
IMAGES=(jpg jpeg png gif)
DOCS=(pdf odt txt .md)


#PATH_LINKS=($DOWNLOAD_PATH/java_files $DOWNLOAD_PATH/zip_files /home/$USERNAME/Vidéos $DOWNLOAD_PATH/gz_files /home/$USERNAME/Images /home/$USERNAME/Documents $DOWNLOAD_PATH/deb_files $DOWNLOAD_PATH/iso_files /home/$USERNAME/Musique)


NUMBER_OF_FILES=$(ls ${DOWNLOAD_PATH}| wc -l)

RED='\033[0;31m'
NC='\033[0m'
ORANGE='\033[1;33m'

# Checking for folder existance
if [ $DOWNLOAD_PATH = "/home/user/Téléchargements" ]; then
	echo -e "${ORANGE}[WARNING] ${NC}You haven't modified the path of your Download folder, it is curently set to default, ${RED}change it to your own${NC}"
	echo -e "The script wont work unless you modify all the path variables${NC}"
fi

#help

if [[ $# != 0 ]] && [[ "$1" != "$NO_SERVICE_ARG" ]] && [[ "$1" != "$HELP_ARG" ]]; then
	echo -e "${RED}[ERROR]${NC} Unknow argument try --help"
	exit
fi

if [ "$1" = $HELP_ARG ]; then
	echo "Run the script using bash exec.sh"
	echo ""
	echo "--no-service	do not setup a service on your computer"
	echo "--help		this page"
	echo ""
	echo "Enjoy"
	exit
fi
#verif is le service existe


if [ ! -f $SERVICE_PATH"/"$SERVICE_FILE ]; then
	echo "le service n'existe pas !"
	if [ "$1" != "$NO_SERVICE_ARG" ]; then
		if [ "$EUID" -ne 0 ]; then
			echo "Vous devez être root pour effectuer cette action !"
			echo "Relancer le script -> sudo bash exec.sh"
			exit
		fi
		echo "recherche du fichier service"
		if [ ! -f $SERVICE_FILE ]; then
			echo "le fichier service n'existe pas ou a été déplacé"
			echo "Télechargement depuis GitHub..."
			#wget $RAW_URL
			if ! wget $RAW_URL
			then
				echo -e "[ERREUR] le telechargement a échoué !"
				echo "impossible d'accéder à $RAW_URL"
			else
				echo "Télechargement términé"
			fi
			cp $SERVICE_FILE $SERVICE_PATH
			ln -s exec.sh $SYMLINK_PATH
			systemctl start $SERVICE_FILE
			systemctl enable $SERVICE_FILE
		else
			echo "le fichier existe, activation du service"
			cp $SERVICE_FILE $SERVICE_PATH
			chown root:root $SERVICE_PATH"/"$SERVICE_FILE
			cp exec.sh $BIN_PATH
			systemctl daemon-reload
                	systemctl start $SERVICE_FILE
                	systemctl enable $SERVICE_FILE
		fi
		exit
	fi
else
	echo "Le service existe"
fi

# Enleve les espaces
cd $DOWNLOAD_PATH

echo ${PATH_LINKS[1]}
for ((i=0; i < ${#PATHS[@]}; i++)) do
	if [ ! -d "${PATH_LINKS[$i]}" ]; then
		echo "le dossier ${PATH_LINKS[$i]} n'existe pas, creation du dossier..."
		mkdir ${PATH_LINKS[$i]}
	else
		echo "${PATH_LINKS[$i]} existe"
	fi
done

echo "il y a $NUMBER_OF_FILES fichier dans $DOWNLOAD_PATH"

while true; do
	for ((i=1; i <= $NUMBER_OF_FILES; i++)); do
		FILE_NAME=$(ls $DOWNLOAD_PATH | sed -n ${i}p)
		FILE_TYPE=$(file $FILE_NAME)

		if [[ $FILE_NAME = *\ * ]]; then
			echo "renaming $FILE_NAME"
			mv "$FILE_NAME" "${FILE_NAME// /_}"
			FILE_NAME=$(ls $DOWNLOAD_PATH | sed -n ${i}p)
		fi
		#EXTENTION=$(ls $DOWNLOAD_PATH | sed -n ${i}p | grep -E -o ...$)
		for ((x=1; x <= ${#VIDEO[@]} ; x++)); do
			if [ "${VIDEO[$x]}" == "*$FILENAME*" ]; then
				mv $DOWNLOAD_PATH"/"$FILE_NAME "VIDEO_PATH/"$FILE_NAME
			fi	
		done
	done
	sleep 3
done
