#!/bin/bash

###############################
# Declaration Area
###############################

CHOICE=""
DE_NAME=""

##############################
# Upgrade the Machine
##############################

sudo apt-get update
sudo apt-get upgrade

##############################
# Install Desktop Environment
##############################
clear
echo -e "\n Select the Desktop Environment\n 1. Ubuntu \n 2. Xfce4"
read -p "Enter Your Choice: " CHOICE

case $CHOICE in
  1)
    DE_NAME="Ubuntu"
    sudo apt-get install ubuntu-desktop gnome-terminal metacity nautilus gnome-panel gnome-settings-daemon
    ;;
  2)
    DE_NAME="Xfce"
    sudo apt-get intall xfce4 xfce4-goodies
    ;;
esac


#############################
# Install Some Utilities
#############################

echo -e "\n Downloading Some VNC utility"
sudo apt-get install vnc4server autocutsel

#############################
# Configure VNC Settings
############################

touch  ~/.Xresources
echo -e "\n In Next Window Configure VNC for first run(Note: Keep Password of exact 8 characters)"
vncserver 
vncserver -kill :1
echo -e "\n Adding Some FireWall Rules"
sudo ufw allow 5901:5910/tcp
echo -e "\n Writing DE Configuration"
sudo cp ~/.vnc/xstartup ~/.vnc/xstartup.bak
sudo mv $(pwd)/config/${DE_NAME} ~/.vnc/xstartup
sudo chmod +x ~/.vnc/xstartup
echo -e "\n Starting VNC Service"
vncserver
echo -e "\n\n Done Enjoy !!!"

