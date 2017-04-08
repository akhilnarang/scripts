#!/bin/bash
#
# Copyright � 2015-2017, Akhil Narang "akhilnarang" <akhilnarang.1999@gmail.com>
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
sudo apt update -y
sudo apt install git-core python gnupg flex bison gperf libsdl1.2-dev libesd0-dev \
squashfs-tools build-essential zip curl libncurses5-dev zlib1g-dev openjdk-8-jre openjdk-8-jdk pngcrush \
schedtool libxml2 libxml2-utils xsltproc lzop libc6-dev schedtool g++-multilib lib32z1-dev lib32ncurses5-dev \
gcc-multilib liblz4-* pngquant ncurses-dev texinfo gcc gperf patch libtool \
automake g++ gawk subversion expat libexpat1-dev python-all-dev bc libcloog-isl-dev \
libcap-dev autoconf libgmp-dev build-essential gcc-multilib g++-multilib pkg-config libmpc-dev libmpfr-dev lzma* \
liblzma* w3m android-tools-adb maven ncftp htop imagemagick -y
echo Dependencies have been installed
echo repo has been Downloaded!
if [ ! "$(which adb)" == "" ];
then
echo Setting up USB Ports
sudo curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/snowdream/51-android/master/51-android.rules
sudo chmod 644   /etc/udev/rules.d/51-android.rules
sudo chown root /etc/udev/rules.d/51-android.rules
sudo service udev restart
adb kill-server
sudo killall adb
fi

makeversion=$(make -v | head -1 | awk '{print $3}')
if [ "${makeversion}" != "4.2.1" ];
then
echo "Installing make 4.2.1 instead of ${makeversion}"
sudo install utils/make /usr/bin/
fi
echo "Installing repo"
sudo install utils/repo /usr/bin/
echo "Installing ccache 3.3.4"
sudo install utils/ccache /usr/bin/
echo "Installing ninja 1.7.2, please make sure your ROM includes the commit to use host ninja"
sudo install utils/ninja /usr/bin/
