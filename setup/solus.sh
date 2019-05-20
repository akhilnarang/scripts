#!/usr/bin/env bash

# Copyright (C) 2019 ZVNexus
# SPDX-License-Identifier: GPL-3.0-only

# Script to setup an AOSP build environment on Solus

sudo eopkg it -c system.devel
sudo eopkg it openjdk-8-devel curl-devel git gnupg gperf libgcc-32bit libxslt-devel lzop ncurses-32bit-devel ncurses-devel readline-32bit-devel rsync schedtool sdl1-devel squashfs-tools unzip wxwidgets-devel zip zlib-32bit-devel

# ADB/Fastboot
sudo eopkg bi --ignore-safety https://raw.githubusercontent.com/solus-project/3rd-party/master/programming/tools/android-tools/pspec.xml
sudo eopkg it android-tools*.eopkg;sudo rm android-tools*.eopkg

# udev rules
echo -e "Setting up udev rules for adb!"
sudo curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules
sudo chmod 644 /etc/udev/rules.d/51-android.rules
sudo chown root /etc/udev/rules.d/51-android.rules
sudo usysconf run -f

echo "Installing repo"
sudo curl --create-dirs -L -o /usr/bin/repo -O -L https://storage.googleapis.com/git-repo-downloads/repo
sudo chmod a+x /usr/bin/repo

printf "\nYou are now ready to build Android!"
printf "\n\n"

# CCACHE
while true; do
    read -p "Do you wish to enable CCACHE? (y/n)" yn
    case $yn in
        [Yy]* ) echo "export USE_CCACHE=1
export CCACHE_DIR=${HOME}/.ccache" >> ${HOME}/.bashrc ; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

printf "\nTo enable CCACHE for a ROM, run this from your the top of your ROM's directory.\n"
printf "prebuilts/misc/linux-x86/ccache/ccache -M 10G\n"
printf "\n"	

source ${HOME}/.bashrc

while true; do
    read -p "Do you also wish to compress CCACHE? (y/n)" yn
    case $yn in
        [Yy]* ) echo "export CCACHE_COMPRESS=1" >> ${HOME}/.bashrc ; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

source ${HOME}/.bashrc	
