#!/usr/bin/env bash

# Script to setup an android build environment on Arch Linux and derivative distributions

clear
echo Installing Dependencies!
# Update
sudo pacman -Syyu

# check if pacaur is installed
if pacman -Qi $package &> /dev/null; then
    echo "Requirement satisfied - pacaur is installed, moving on to next step"
else
    # Install pacaur (not available in official repos)
    # sudo pacman -S pacaur

    # Install pacaur from AUR
    # Pacaur depends on cower also from AUR so first build cower

    # First, install the necessary dependencies.
    sudo pacman -S expac yajl --noconfirm

    # create a temporary working directory
    mkdir ~/tmp
    cd ~/tmp/

    # build cower (import keys for cower alternatively use --skipgpcheck in makepkg)
    gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53
    curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower
    makepkg -i PKGBUILD --noconfirm

    # next install pacaur
    curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pacaur
    makepkg -i PKGBUILD --noconfirm

    # cleanup build directory
    cd && rm -r ~/tmp
fi

# Downgrade curl for now
pacaur -S agetpkg-git --noconfirm
agetpkg --install curl 7.55.1 1
sudo sed -i '/\[options\]/a IgnorePkg = curl' /etc/pacman.conf
# Import PGP signatures for ncurses5-compat-libs and lib32-ncurses5-compat-libs
gpg --recv-keys 702353E0F7E48EDB
# Install aosp-devel (and lineageos-devel because quite a few probably build Lineage/Lineage based ROMs as well.
pacaur -S aosp-devel lineageos-devel --noconfirm
# Just a couple of other useful tools I use, others do too probably
pacaur -S hub neofetch fortune-mod --noconfirm

echo "All Done :'D"
echo "Don't forget to run these commands before building, or make sure the python in your PATH is python2 and not python3"
echo "
virtualenv2 venv
source venv/bin/activate
export LC_ALL=C"
