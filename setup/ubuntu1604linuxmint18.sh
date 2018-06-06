#!/usr/bin/env bash

# Script to setup an AOSP Build Environment on Ubuntu 16.04 and above and Linux Mint 18.x

clear
echo -e "Installing Dependencies!"
sudo apt update -y
sudo apt install python gnupg flex bison gperf libsdl1.2-dev libesd0-dev \
squashfs-tools build-essential zip libncurses5-dev zlib1g-dev openjdk-8-jre \
openjdk-8-jdk pngcrush schedtool libxml2 libxml2-utils xsltproc lzop libc6-dev \
g++-multilib lib32z1-dev lib32ncurses5-dev gcc-multilib liblz4-* pngquant \
ncurses-dev texinfo gcc gperf patch libtool automake g++ gawk subversion expat \
libexpat1-dev python-all-dev bc libcloog-isl-dev libcap-dev autoconf libgmp-dev \
build-essential gcc-multilib g++-multilib pkg-config libmpc-dev libmpfr-dev \
lzma* liblzma* w3m adb fastboot maven ncftp htop imagemagick libssl-dev clang cmake -y
echo Dependencies have been installed
if [[ ! "$(which adb)" == "" ]]; then
	echo -e "Setting up some stuff for adb!"
	sudo curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L \
https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules;
	sudo chmod 644 /etc/udev/rules.d/51-android.rules;
	sudo chown root /etc/udev/rules.d/51-android.rules;
	sudo systemctl restart udev;
	adb kill-server;
	sudo killall adb;
fi

if [[ -d "utils" ]]; then
	if [ "$(command -v make)" ]; then
		makeversion="$(make -v | head -1 | awk '{print $3}')";
		if [ "${makeversion}" != "4.2.1" ]; then
			echo "Installing make 4.2.1 instead of ${makeversion}";
			sudo install utils/make /usr/local/bin/;
		fi
	fi
else
	echo "Please run the script from root of cloned repo!";
fi
echo "Installing repo";
curl -L -s https://github.com/akhilnarang/repo/raw/master/repo | sudo tee \
/usr/local/bin/repo;
sudo chmod a+x /usr/local/bin/repo

bash ./setup/ccache.sh;
bash ./setup/ninja.sh;
