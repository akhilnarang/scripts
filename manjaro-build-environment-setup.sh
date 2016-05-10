#!/bin/bash
clear
echo Installing Dependencies!
# Update
sudo pacman -Syu
# Install needed packages
sudo pacman -S gcc git gnupg flex bison gperf sdl wxgtk bash-completion \
squashfs-tools curl ncurses zlib schedtool perl-switch zip \
unzip libxslt maven tmux screen w3m python2-virtualenv bc rsync
# Installing 64 bit needed packages
sudo pacman -S gcc-multilib lib32-zlib lib32-ncurses lib32-readline
# yaourt for easy installing from AUR
sudo pacman -Sy yaourt
# Disable pgp checking when installing stuff from AUR
export MAKEPKG="makepkg --skippgpcheck"
yaourt libtinfo
yaourt lib32-ncurses5-compat-libs
yaourt ncurses5-compat-libs
yaourt phablet-tools

echo "All Done :'D"
echo "Don't forget to run these command before building!"
echo "
virtualenv2 <folder name>
source <folder name>/bin/activate
export LC_ALL=C"
