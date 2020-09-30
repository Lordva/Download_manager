#!/bin/bash

DOWNLOAD_PATH=/home/user/Téléchargements

#LOG_FILE=/home/user/download_log

NUMBER_OF_FILES=$(ls ${DOWNLOAD_PATH}| wc -l)

# Chemins vers les differents dossiers
JAR_PATH=$DOWNLOAD_PATH"/java_files"
ZIP_PATH=$DOWNLOAD_PATH"/zip_files"
VIDEO_PATH=/home/user/Vidéos
GZ_PATH=$DOWNLOAD_PATH"/gz_files"
IMG_PATH=/home/user/Images
DOC_PATH=/home/user/Documents
DEB_PATH=$DOWNLOAD_PATH"/deb_files"
ISO_PATH=$DOWNLOAD_PATH"/iso_files"
MP3_PATH=/home/user/Musique
SERVICE_PATH=/etc/systemd/system
SERVICE_FILE=dlmanager.service
RAW_URL=https://raw.githubusercontent.com/Lordva/Download_manager/master/dlmanager.service
BIN_PATH=/bin/dlmanager
NO_SERVICE_ARG=--no-service
HELP_ARG=--help

PATHS=(JAR_PATH ZIP_PATH VIDEO_PATH GZ_PATH IMG_PATH DOC_PATH DEB_PATH ISO_PATH MP3_PATH)
PATH_LINKS=($DOWNLOAD_PATH/java_files $DOWNLOAD_PATH/zip_files /home/user/Vidéos $DOWNLOAD_PATH/gz_files /home/user/Images /home/user/Documents $DOWNLOAD_PATH/deb_files $DOWNLOAD_PATH/iso_files /home/user/Musique)


RED='\033[0;31m'
NC='\033[0m'
ORANGE='\033[1;33m'

# Checking for folder existance
if [ $DOWNLOAD_PATH = "/home/user/Téléchargements" ]; then
	echo -e "${ORANGE}[WARNING] ${NC}You haven't modified the path of your Download folder, it is curently set to default, ${RED}change it to your own${NC}"
	echo -e "The script wont work unless you modify all the path variables${NC}"
	sleep 3
	exit
fi

#help

if [[ $# != 0 ]] && [[ $1 != $NO_SERVICE_ARG ]] && [[ $1 !=$HELP_ARG ]]; then
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
#for f in *\ *; do mv "$f" "${f// /_}"; done


for ((i=0; i < ${PATHS[@]}; i++})) do
	if [ ! -d ${FULL_PATH[$i]} ]; then
		echo "le dossier ${FULL_PATH[$i]} n'existe pas, creation du dossier..."
		mkdir ${FULL_PATH[$i]}
	else
		echo "${FULL_PATH[$i]} existe"
	fi
done

echo "il y a $NUMBER_OF_FILES fichier dans $DOWNLOAD_PATH"

#for f in *\ *; do mv "$f" "${f// /_}"; done
while true; do

		for f in *\ *; do mv "$f" "${f// /_}"; done
		FILE_NAME=$(ls $DOWNLOAD_PATH | sed -n ${i}p)
		EXTENTION=$(ls $DOWNLOAD_PATH | sed -n ${i}p | grep -E -o ...$)
	
		if [[ $EXTENTION = jar ]]; then
			mv $DOWNLOAD_PATH"/"$FILE_NAME $JAR_PATH"/"$FILE_NAME
	
		elif [[ $EXTENTION = zip ]]; then
			mv $DOWNLOAD_PATH"/"$FILE_NAME $ZIP_PATH"/"$FILE_NAME
	
		elif [[ $EXTENTION = mp4 ]] || [[ $EXTENTION = "wav" ]] ; then
			mv $DOWNLOAD_PATH"/"$FILE_NAME $VIDEO_PATH"/"$FILE_NAME
		
		elif [[ $EXTENTION = .gz ]]; then
			mv $DOWNLOAD_PATH"/"$FILE_NAME $GZ_PATH"/"$FILE_NAME

		elif [[ $EXTENTION = jpg ]] || [[ $EXTENTION = png ]] || [[ $EXTENTION = gif ]] ; then
			mv $DOWNLOAD_PATH"/"$FILE_NAME $IMG_PATH"/"$FILE_NAME
		elif [[ $EXTENTION = pdf ]] || [[ $EXTENTION = odt ]] || [[ $EXTENTION = txt ]] ; then
			mv $DOWNLOAD_PATH"/"$FILE_NAME $DOC_PATH"/"$FILE_NAME
		elif [[ $EXTENTION = deb ]] ; then
                	mv $DOWNLOAD_PATH"/"$FILE_NAME $DEB_PATH"/"$FILE_NAME
		elif [[ $EXTENTION = iso ]] || [[ $EXTENTION = img ]] || [[ $EXTENTION = age ]] ; then
			mv $DOWNLOAD_PATH"/"$FILE_NAME $ISO_PATH"/"$FILE_NAME
		elif [[ $EXTENTION = mp3 ]] || [[ $EXTENTION = raw ]] ; then
			mv $DOWNLOAD_PATH"/"$FILE_NAME $MP3_PATH"/"$FILE_NAME
		fi
		
	done
	sleep 2
done
