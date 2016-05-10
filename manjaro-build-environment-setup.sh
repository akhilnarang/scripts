#!/bin/bash
clear
echo Installing Dependencies!
# Update
sudo pacman -Syu
# Install needed packages
sudo pacman -S gcc git gnupg flex bison gperf sdl wxgtk bash-completion \
squashfs-tools curl ncurses zlib schedtool perl-switch zip \
unzip libxslt maven tmux screen w3m python2-virtualenv bc rsync vi
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

echo "If you wanna use nano as your git editor (for commit messages, interactive rebase, etc, enter 1."
echo "Anything else will result in the default i.e. vim being used"
read giteditor
if [[ "$giteditor" == "1" ]];
then
git config --global core.editor nano
fi
