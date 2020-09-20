#!/bin/bash

DOWNLOAD_PATH=/home/louis/Téléchargements

LOG_FILE=/home/louis/dev/scripts/download_log

NUMBER_OF_FILES=$(ls ${DOWNLOAD_PATH}| wc -l)

# Chemins vers les differents dossiers
JAR_PATH=/home/louis/Téléchargements/java_files
ZIP_PATH=/home/louis/Téléchargements/zip_files
VIDEO_PATH=/home/louis/Vidéos
GZ_PATH=/home/louis/Téléchargements/gz_files
IMG_PATH=/home/louis/Images
DOC_PATH=/home/louis/Documents
DEB_PATH=/home/louis/Téléchargements/deb_files
ISO_PATH=/home/louis/Téléchargements/iso_files
MP3_PATH=/home/louis/Musique
SERVICE_PATH=/etc/systemd/system
SERVICE_FILE=dlmanager.service
RAW_URL=https://raw.githubusercontent.com/Lordva/Download_manager/master/dlmanager.service
BIN_PATH=/bin/dlmanager
NO_SERVICE_ARG=--noservice-install
HELP_ARG=--help
#verif is le service existe

if [ ! -f $SERVICE_PATH"/"$SERVICE_FILE ]; then
	echo "le service n'existe pas !"
	if [ "$1" -ne $NO_SERVICE_ARG]; then
		if [ "$EUID" -ne 0 ]; then
			echo "Vous devez être root pour effectuer cette action !"
			echo "Relancer le script -> sudo bash exec.sh"
			exit
		fi
		echo "recherche du fichier service"
		if [ ! -f $SERVICE_FILE ]; then
			echo "le fichier service n'existe pas ou a été déplacé"
			echo "Télechargement depuis GitHub..."
			wget $RAW_URL
			if [ "$?" != "0" ]; then
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

# Check si les dossiers existe et le créer sinon
if [ ! -d $JAR_PATH ]; then
	echo "le dossier $JAR_PATH n'existe pas, creation du dossier..."
	mkdir $JAR_PATH
else
	echo "$JAR_PATH existe"
fi

if [ ! -d $ZIP_PATH ]; then
	echo "le dossier $ZIP_PATH n'existe pas, creation du dossier..."
	mkdir $ZIP_PATH
else
	echo "$ZIP_PATH existe"
fi

if [ ! -d $VIDEO_PATH ]; then
	echo "le dossier $VIDEO_PATH n'existe pas, creation du dossier"
	mkdir $VIDEO_PATH
else
	echo "$VIDEO_PATH existe"
fi

if [ ! -d $GZ_PATH ]; then
        echo "le dossier $GZ_PATH n'existe pas, creation du dossier"
        mkdir $GZ_PATH
else
        echo "$GZ_PATH existe"

fi
if [ ! -d $IMG_PATH ]; then
        echo "le dossier $IMG_PATH n'existe pas, creation du dossier"
        mkdir $IMG_PATH
else
        echo "$IMG_PATH existe"
fi

if [ ! -d $DOC_PATH ]; then
	echo "le dossier $DOC_PATH n'exite pas, creation du dossier"
	mkdir $DOC_PATH
else
	echo "$DOC_PATH existe"
fi

if [ ! -d $DEB_PATH ]; then
	echo "le dossier $DEB_PATH n'existe pas, creation du dossier"
	mkdir $DEB_PATH
else
	echo "$DEB_PATH existe"
fi

if [ ! -d $ISO_PATH ]; then
	echo "le dossier $ISO_PATH n'existe pas, creation du dossier"
	mkdir $ISO_PATH
else
	echo "$ISO_PATH existe"
fi

echo "il y a $NUMBER_OF_FILES fichier dans $DOWNLOAD_PATH"

#for f in *\ *; do mv "$f" "${f// /_}"; done
while true; do
	#if [[ $NUMBER_OF_FILES != $OLD_NOF ]]; then
		#for f in *\ *; do mv "$f" "${f// /_}"; done
	#fi
	for ((i = 1 ; i <= $NUMBER_OF_FILES ; i++)); do

		if [[ -f *\ * ]]; then
			for f in *\ *; do mv "$f" "${f// /_}"; done
		fi
		FILE_NAME=$(ls $DOWNLOAD_PATH | sed -n ${i}p)
		EXTENTION=$(ls $DOWNLOAD_PATH | sed -n ${i}p | egrep -o ...$)
	
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
