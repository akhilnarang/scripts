#!/usr/bin/env bash

# Script to setup an android build environment on Arch Linux and derivative distributions

clear
echo Installing Dependencies!
# Update
sudo pacman -Syyu
# Install pacaur
sudo pacman -S pacaur
# Import PGP signatures for ncurses5-compat-libs and lib32-ncurses5-compat-libs
gpg --recv-keys 702353E0F7E48EDB
# Install aosp-devel (and lineageos-devel because quite a few probably build Lineage/Lineage based ROMs as well.
pacaur -S aosp-devel lineageos-devel
# Just a couple of other useful tools I use, others do too probably
pacaur -S hub neofetch fortune-mod --noconfirm

echo "All Done :'D"
echo "Don't forget to run these commands before building, or make sure the python in your PATH is python2 and not python3"
echo "
virtualenv2 venv
source venv/bin/activate
export LC_ALL=C"
