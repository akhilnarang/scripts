#!/bin/bash
#
# Copyright � 2015-2016, Akhil Narang "akhilnarang" <akhilnarang.1999@gmail.com>
#
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Please maintain this if you use this script or any part of it
#

clear
echo Installing Dependencies!
# Update
sudo pacman -Syu
# Install needed packages
sudo pacman -S gcc git gnupg flex bison gperf sdl wxgtk bash-completion \
squashfs-tools curl ncurses zlib schedtool perl-switch zip \
unzip libxslt maven tmux screen w3m python2-virtualenv bc rsync ncftp \
ca-certificates-mozilla fakeroot make pkg-config
# Installing 64 bit needed packages
sudo pacman -S gcc-multilib lib32-zlib lib32-ncurses lib32-readline
# Disable pgp checking when installing stuff from AUR
export MAKEPKG="makepkg --skippgpcheck"
yaourt -S libtinfo
yaourt -S lib32-ncurses5-compat-libs
yaourt -S ncurses5-compat-libs
yaourt -S phablet-tools
yaourt -S make-3.81

echo "All Done :'D"
echo "Don't forget to run these command before building!"
echo "
virtualenv2 venv
source venv/bin/activate
export LC_ALL=C"

echo "Also symlink /usr/bin/make-3.81 as make in any bin of your choice 
for faster builds"
