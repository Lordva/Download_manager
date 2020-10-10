#!/bin/bash

USERNAME=louis
DOWNLOAD_PATH=/home/$USERNAME/Téléchargements

#LOG_FILE=/home/user/download_log


# Chemins vers les differents dossiers
JAR_PATH=$DOWNLOAD_PATH"/java_files"
ZIP_PATH=$DOWNLOAD_PATH"/zip_files"
VIDEO_PATH=/home/$USERNAME/Vidéos
IMG_PATH=/home/$USERNAME/Images
DOC_PATH=/home/$USERNAME/Documents
#DEB_PATH=$DOWNLOAD_PATH"/deb_files"
ISO_PATH=$DOWNLOAD_PATH"/iso_files"
EXEC_PATH=$DOWNLOAD_PATH"/executables"
MP3_PATH=/home/$USERNAME/Musique
SERVICE_PATH=/etc/systemd/system
SERVICE_FILE=dlmanager.service
RAW_URL=https://raw.githubusercontent.com/Lordva/Download_manager/master/dlmanager.service
BIN_PATH=/bin/dlmanager
NO_SERVICE_ARG=--no-service
HELP_ARG=--help

#ARRAY_LIST=(VIDEOS IMAGES DOCS COMPRESSED JAVA EXEC SYSTEM)
VIDEOS=(mp4 wav AVI video)
MUSIQUE=(Audio mp3 raw)
IMAGES=(jpg jpeg png gif)
DOCS=(PDF Word)
COMPRESSED=(Zip RAR compressed)
EXEC=(executable)
SYSTEM=(boot)
JAVA=(java)



PATH_LINKS=($DOWNLOAD_PATH/java_files $DOWNLOAD_PATH/zip_files /home/$USERNAME/Vidéos /home/$USERNAME/Images /home/$USERNAME/Documents $DOWNLOAD_PATH/deb_files $DOWNLOAD_PATH/iso_files /home/$USERNAME/Musique $DOWNLOAD_PATH/executables)


NUMBER_OF_FILES=$(ls ${DOWNLOAD_PATH}| wc -l)

RED='\033[0;31m'
NC='\033[0m'
ORANGE='\033[1;33m'

file_exist(){
	echo "$FILE_NAME existe deja !"
	local NUMBER_OF_FILE=$(ls "$1"/"$FILE_NAME"* | wc -l)
	NEW_FILE_NAME="$FILE_NAME#$NUMBER_OF_FILE"
}

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
			ln -s exec.sh "$SYMLINK_PATH"
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

cd $DOWNLOAD_PATH

# Verify if the folders exists
for ((i=0; i < ${#PATH_LINKS[@]}; i++)) do
	if [ ! -d "${PATH_LINKS[$i]}" ]; then
		echo "le dossier ${PATH_LINKS[$i]} n'existe pas, creation du dossier..."
			mkdir "${PATH_LINKS[$i]}"
		else
			echo "${PATH_LINKS[$i]} existe"
		fi
done

echo "il y a $NUMBER_OF_FILES fichier dans $DOWNLOAD_PATH"

while : 
do
	for ((i=1; i <= NUMBER_OF_FILES; i++)); do
		FILE_NAME=$(ls "$DOWNLOAD_PATH" | sed -n "${i}"p)
		FILE_TYPE=$(file -b "$FILE_NAME")
		echo "nom du fichier = $FILE_NAME"

		if [[ $FILE_NAME = *\ * ]]; then
			echo "renaming $FILE_NAME"
			mv "$FILE_NAME" "${FILE_NAME// /_}"
			FILE_NAME=$(ls $DOWNLOAD_PATH | sed -n ${i}p)
			FILE_TYPE=$(file -b $FILE_NAME)
		fi
		if [ "$FILE_TYPE" != "directory" ]; then # Check if file is a directory

			for ((x=0; x < ${#VIDEOS[@]} ; x++)); do # Is it a video ?
				if [[ "$FILE_TYPE" == *"${VIDEOS[$x]}"* ]]; then
					echo "$FILE_NAME type is ${VIDEOS[$x]}"
					if [ -f "$VIDEO_PATH"/"$FILE_NAME" ]; then file_exist "$VIDEO_PATH" && mv $DOWNLOAD_PATH"/"$FILE_NAME $VIDEO_PATH"/"$NEW_FILE_NAME; else mv $DOWNLOAD_PATH"/"$FILE_NAME $VIDEO_PATH"/"$FILE_NAME; fi
				fi	
			done
				for ((x=0; x < ${#MUSIQUE[@]} ; x++)); do # Is it a video ?
				if [[ "$FILE_TYPE" == *"${MUSIQUE[$x]}"* ]]; then
					echo "$FILE_NAME type is ${MUSIQUE[$x]}"
					if [ -f "$MP3_PATH/$FILE_NAME" ]; then file_exist "$MP3_PATH" && mv $DOWNLOAD_PATH"/"$FILE_NAME $MP3_PATH"/"$NEW_FILE_NAME; else mv $DOWNLOAD_PATH"/"$FILE_NAME $MP3_PATH"/"$FILE_NAME; fi
				fi	
			done
				for ((x=0; x < ${#IMAGES[@]} ; x++)); do # Is it a video ?
				if [[ "$FILE_TYPE" == *"${IMAGES[$x]}"* ]]; then
					echo "$FILE_NAME type is ${IMAGES[$x]}"
					if [ -f "$IMG_PATH/$FILE_NAME" ]; then file_exist "$IMG_PATH" && mv $DOWNLOAD_PATH"/"$FILE_NAME $IMG_PATH"/"$NEW_FILE_NAME; else mv $DOWNLOAD_PATH"/"$FILE_NAME $IMG_PATH"/"$FILE_NAME; fi
				fi	
			done
			for ((x=0; x < ${#DOCS[@]} ; x++)); do # Is it a document ?
				if [[ "$FILE_TYPE" == *"${DOCS[$x]}"* ]]; then 
					echo "$FILE_NAME type is ${DOCS[$x]}"
					if [ -f "$DOC_PATH/$FILE_NAME" ]; then file_exist "$DOC_PATH" && mv $DOWNLOAD_PATH"/"$FILE_NAME $DOC_PATH"/"$NEW_FILE_NAME; else mv $DOWNLOAD_PATH"/"$FILE_NAME $DOC_PATH"/"$FILE_NAME; fi
				fi	
			done
			for ((x=0; x < ${#EXEC[@]} ; x++)); do # Is it a executable ?
				if [[ "$FILE_TYPE" == *"${EXEC[$x]}"* ]]; then 
					echo "$FILE_NAME type is ${EXEC[$x]}"
					if [ -f "$EXEC_PATH/$FILE_NAME" ]; then file_exist "$EXEC_PATH" && mv $DOWNLOAD_PATH"/"$FILE_NAME $EXEC_PATH"/"$NEW_FILE_NAME; else mv $DOWNLOAD_PATH"/"$FILE_NAME $EXEC_PATH"/"$FILE_NAME; fi
				fi	
			done
			for ((x=0; x < ${#COMPRESSED[@]} ; x++)); do # Is it a compressed file ?
				if [[ "$FILE_TYPE" == *"${COMPRESSED[$x]}"* ]]; then 
					echo "$FILE_NAME type is ${COMPRESSED[$x]}"
					if [ -f "$ZIP_PATH/$FILE_NAME" ]; then file_exist "$ZIP_PATH" && mv $DOWNLOAD_PATH"/"$FILE_NAME $ZIP_PATH"/"$NEW_FILE_NAME; else mv $DOWNLOAD_PATH"/"$FILE_NAME $ZIP_PATH"/"$FILE_NAME; fi
				fi	
			done
			for ((x=0; x < ${#SYSTEM[@]} ; x++)); do # Is it a system file (iso etc...) ?
				if [[ "$FILE_TYPE" == *"${SYSTEM[$x]}"* ]]; then 
					echo "$FILE_NAME type is ${SYSTEM[$x]}"
					if [ -f "$ISO_PATH/$FILE_NAME" ]; then file_exist "$ISO_PATH" && mv $DOWNLOAD_PATH"/"$FILE_NAME $ISO_PATH"/"$NEW_FILE_NAME; else mv $DOWNLOAD_PATH"/"$FILE_NAME $ISO_PATH"/"$FILE_NAME; fi
				fi	
			done
			for ((x=0; x < ${#JAVA[@]} ; x++)); do # Is it a java file ?
				if [[ "$FILE_TYPE" == *"${JAVA[$x]}"* ]]; then 
					echo "$FILE_NAME type is ${JAVA[$x]}"
					if [ -f "$JAR_PATH/$FILE_NAME" ]; then file_exist "$JAR_PATH" && mv $DOWNLOAD_PATH"/"$FILE_NAME $JAR_PATH"/"$NEW_FILE_NAME; else mv $DOWNLOAD_PATH"/"$FILE_NAME $JAR_PATH"/"$FILE_NAME; fi
				fi	
			done


			# Fallback category (text files)
			if [[ "$FILE_TYPE" == *"ASCII text"* ]]; then 
				echo "$FILE_NAME is probably just a text file"
				if [ -f "$DOC_PATH/$FILE_NAME" ]; then file_exist "$DOC_PATH" && mv $DOWNLOAD_PATH"/"$FILE_NAME $DOC_PATH"/"$NEW_FILE_NAME; else mv $DOWNLOAD_PATH"/"$FILE_NAME $DOC_PATH"/"$FILE_NAME; fi
			fi	
		fi
	done
	sleep 3
done

