#!/bin/bash


USERNAME=user
DOWNLOAD_PATH=/home/$USERNAME/Téléchargements

#LOG_FILE=/home/user/download_log

NUMBER_OF_FILES=$(ls ${DOWNLOAD_PATH}| wc -l)

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

PATHS=(JAR_FILES ZIP_FILES VIDEO_FILES GZ_FILES IMG_FILES DOC_FILES DEB_FILES ISO_FILES MP3_FILES)
PATH_LINKS=($DOWNLOAD_PATH/java_files $DOWNLOAD_PATH/zip_files /home/$USERNAME/Vidéos $DOWNLOAD_PATH/gz_files /home/$USERNAME/Images /home/$USERNAME/Documents $DOWNLOAD_PATH/deb_files $DOWNLOAD_PATH/iso_files /home/$USERNAME/Musique)


if [ -f "$FOLDER_SAVE" ]; then PATH_LINKS=$(cat $FOLDER_SAVE); fi

RED='\033[0;31m'
NC='\033[0m'
ORANGE='\033[1;33m'

change_path(){ #PERSISTANCE ?????
	read -r -p "Please enter your Download folder path: " key
	if [ -z "$key" ]; then
		echo "You need to enter something !"
		clear && change_path
	else
		if [ ! -d "$key" ]; then
			echo "This Directory is not valid !"
			echo "Please enter a directory path from root" && change_path
		else
			if [[ $key == */ ]]; then echo "u need 2 change"; fi
			DOWNLOAD_PATH=$key
			echo "Download directory set to $DOWNLOAD_PATH"
		fi
	fi
	for ((i=0; i < ${#PATH_LINKS[@]}; i++)) do
		read -r -p "Enter the path for your ${PATHS[$i]} currently ${PATH_LINKS[$i]}: " key
		if [[ $key == */ ]]; then key=sed 's//\([^*]*\)$/ \1/'; fi
		echo $key
		if [ -z "$key" ]; then
			echo "The default path will be kept : ${PATH_LINKS[$i]}"
		else
			if [ -d "$key" ]; then
				echo "Be carefull, a directory named $key alredy exist."
			else
				echo "$key does not exist and will have to be created"
			fi
			echo ""
			PATH_LINKS[$i]=$key
		fi
	done
	echo ${PATH_LINKS[@]} >> $FOLDER_SAVE
}

# Checking for folder existance
if [ $DOWNLOAD_PATH = "/home/user/Téléchargements" ]; then
	echo -e "${ORANGE}[WARNING] ${NC}You haven't modified the path of your Download folder, it is curently set to default, ${RED}change it to your own${NC}"
	echo -e "The script wont work unless you modify all the path variables${NC}"
	read -r -p "Do you want to change the default path ? [yes/no] " key
	case $key in
		Y ) change_path ;;
		y ) change_path ;;
		yes) change_path ;;
		Yes) change_path ;;
		*) echo "ending the script" & exit ;;
	esac
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
#for f in *\ *; do mv "$f" "${f// /_}"; done


for ((i=0; i < ${#PATHS[@]}; i++)) do
	if [ ! -d ${PATH_LINKS[$i]} ]; then
		echo "le dossier ${PATH_LINKS[$i]} n'existe pas, creation du dossier..."
		mkdir ${PATH_LINKS[$i]}
	else
		echo "${PATH_LINKS[$i]} existe"
	fi
done

echo "il y a $NUMBER_OF_FILES fichier dans $DOWNLOAD_PATH"

#for f in *\ *; do mv "$f" "${f// /_}"; done
while true; do
	for ((i=1; i <= $NUMBER_OF_FILES; i++)); do
		#for f in *\ *; do mv "$f" "${f// /_}"; done
		FILE_NAME=$(ls $DOWNLOAD_PATH | sed -n ${i}p)
		if [[ $FILE_NAME = *\ * ]]; then
			echo "Renaming $FILE_NAME into ${FILE_NAME// /_}"
			mv "$FILE_NAME" "${FILE_NAME// /_}"
			FILE_NAME=$(ls $DOWNLOAD_PATH | sed -n ${i}p)
		fi
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
