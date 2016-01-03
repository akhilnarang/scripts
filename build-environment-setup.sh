#!/bin/bash
clear
echo Installing Dependencies!
sudo apt-get update
sudo apt-get -y install git-core python gnupg flex bison gperf libsdl1.2-dev libesd0-dev libwxgtk2.8-dev \
squashfs-tools build-essential zip curl libncurses5-dev zlib1g-dev openjdk-7-jre openjdk-7-jdk pngcrush \
schedtool libxml2 libxml2-utils xsltproc lzop libc6-dev schedtool g++-multilib lib32z1-dev lib32ncurses5-dev \
lib32readline-gplv2-dev gcc-multilib liblz4-* pngquant ncurses-dev texinfo gcc gperf patch libtool \
automake g++ gawk subversion expat libexpat1-dev python-all-dev binutils-static libgcc1:i386 bc libcloog-isl-dev \
libcap-dev autoconf libgmp-dev build-essential gcc-multilib g++-multilib pkg-config libmpc-dev libmpfr-dev lzma* \
liblzma* w3m
clear
echo Dependencies have been installed
clear
echo repo has been Downloaded!
echo Settings up USB Ports
sudo curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/snowdream/51-android/master/51-android.rules
sudo chmod 644   /etc/udev/rules.d/51-android.rules
sudo chown root /etc/udev/rules.d/51-android.rules
sudo service udev restart
adb kill-server
sudo killall adb
#echo Cloning LZMA repo
#git clone https://github.com/peterjc/backports.lzma /tmp/backports.lzma
#cd /tmp/backports.lzma
#sudo python2 setup.py install
#python2 test/test_lzma.py
#rm -rf /tmp/backports.lzma
#echo LZMA compression for ROMs enabled
#echo "WITH_LZMA_OTA=true" >> ~/.bashrc
