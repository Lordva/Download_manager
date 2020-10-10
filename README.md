[![CodeFactor](https://www.codefactor.io/repository/github/lordva/download_manager/badge)](https://www.codefactor.io/repository/github/lordva/download_manager)

# Download manager script

This bash script clean your download folder for you by putting files in subfolders

It's a very simple script but is nevertheless super handy if your download folder is a jungle

# currently supported extentions
 
- Jar / iso / img / zip / mp3 / mp4 / deb / pdf / odt / wav / image / raw / txt / jpg / png / gif and a few more...
	
### UPDATE ! 
The script now check file type with the file command and not with the extention, this mean that virtualy every file type is supported, support will extend with time as I update the script

The script now support file with the same name at the destination folder, it will no longer replace it but instead rename it `filename#<number>`.
## To be added 

- [x] basic file sorting
- [x] renaming files containing spaces
- [x] auto service setup (enable on startup)
- [ ] Add an "old" folder for added clarity in subfolders
- [x] support files with the same name
- [x] support advanced customisation
- [ ] add clear uninstall script
- [x] add support for every type of file (need to rewrite a large portion of the code)
- [ ] translate logs in English (currently in french)

## Installation

To use the script just clone the repo.
```shell
git clone https://github.com/Lordva/Download_manager

cd Download_manager

sudo bash exec.sh
```
if you dont want to setup a service simply do:
```
bash exec.sh --no-service
```

For the first run it's recomended to run as root to setup the service.
Once the service is setup you wont be needed to run the exec.sh again il will run automaticly

#### Edit exec.sh and change paths variables to your computer specifics !
## Control

To stop the script use `systemctl stop dlmanager`
To restart the script use `systemctl restart dlmanager`
To see the script logs run `systemctl status dlmanager`
For more information see `man systemctl`


