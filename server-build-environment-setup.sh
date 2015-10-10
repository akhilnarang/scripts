#!/bin/bash
clear
echo Installing Dependencies!
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key |   apt-key add -
sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update
apt-get -y install git-core python gnupg flex bison gperf libsdl1.2-dev libesd0-dev libwxgtk2.8-dev \
squashfs-tools build-essential zip curl libncurses5-dev zlib1g-dev openjdk-7-jre openjdk-7-jdk pngcrush \
schedtool libxml2 libxml2-utils xsltproc lzop libc6-dev schedtool g++-multilib lib32z1-dev lib32ncurses5-dev \
lib32readline-gplv2-dev gcc-multilib liblz4-* pngquant jenkins ncurses-dev texinfo gcc gperf patch libtool \
automake g++ gawk subversion expat libexpat1-dev python-all-dev binutils-static libgcc1:i386 bc libcloog-isl-dev \
libcap-dev autoconf libgmp-dev build-essential gcc-multilib g++-multilib pkg-config libmpc-dev libmpfr-dev lzma* liblzma* phablet-tools
clear
echo Dependencies have been installed
echo Installing LZMA
git clone https://github.com/peterjc/backports.lzma
cd backports.lzma
python2 setup.py install
python2 test/test_lzma.py
echo LZMA Setup, enjoy smaller builds!
echo Configuring git
git config --global user.name "Blazing Phoenix"
git config --global user.email "blazingphoenixdevs@gmail.com"
echo Git has been configured
