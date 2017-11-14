#!/usr/bin/env bash

# Script to setup an android build environment on Arch Linux and derivative distributions

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
yaourt -S libtinfo --noconfirm
yaourt -S lib32-ncurses5-compat-libs --noconfirm
yaourt -S ncurses5-compat-libs --noconfirm

if [ -d "utils" ]; then
	if [ "$(command -v make)" ]; then
		makeversion="$(make -v | head -1 | awk '{print $3}')";
		if [ "${makeversion}" != "4.2.1" ]; then
			echo "Installing make 4.2.1 instead of ${makeversion}";
			sudo install utils/make /usr/local/bin/;
		fi
	fi
	echo "Installing repo";
	sudo install utils/repo /usr/local/bin/;
	echo "Installing ccache 3.3.4, please make sure your ROM includes the commit to use host ccache";
	sudo install utils/ccache /usr/local/bin/;
	echo "Installing ninja 1.7.2, please make sure your ROM includes the commit to use host ninja";
	sudo install utils/ninja /usr/local/bin/;
else
	echo "Please run the script from root of cloned repo!";
fi

echo "All Done :'D"
echo "Don't forget to run these command before building!"
echo "
virtualenv2 venv
source venv/bin/activate
export LC_ALL=C"
