#!/usr/bin/env bash

# Copyright (C) 2018 Harsh 'MSF Jarvis' Shandilya
# Copyright (C) 2018 Akhil Narang
# SPDX-License-Identifier: GPL-3.0-only

# Script to setup an AOSP Build environment on Linux Mint and Ubuntu

LATEST_MAKE_VERSION="4.2.1"
UBUNTU_14_PACKAGES="binutils-static curl figlet git-core libesd0-dev libwxgtk2.8-dev"
UBUNTU_16_PACKAGES="libesd0-dev"
UBUNTU_18_PACKAGES="curl"
PACKAGES=""

LSB_RELEASE="$(lsb_release -d)"

if [[ "${LSB_RELEASE}" =~ "Ubuntu 14" ]]; then
    PACKAGES="${UBUNTU_14_PACKAGES}"
elif [[ "${LSB_RELEASE}" =~ "Mint 18" || "${LSB_RELEASE}" =~ "Ubuntu 16" ]]; then
    PACKAGES="${UBUNTU_16_PACKAGES}"
elif [[ "${LSB_RELEASE}" =~ "Ubuntu 18" ]]; then
    PACKAGES="${UBUNTU_18_PACKAGES}"
fi

sudo apt update -y
sudo apt install -y adb autoconf automake axel bc bison build-essential clang cmake expat fastboot flex \
g++ g++-multilib gawk gcc gcc-multilib gnupg gperf htop imagemagick lib32ncurses5-dev lib32z1-dev \
libc6-dev libcap-dev libcloog-isl-dev libexpat1-dev libgmp-dev liblz4-* liblzma* libmpc-dev libmpfr-dev \
libncurses5-dev libsdl1.2-dev libssl-dev libtool libxml2 libxml2-utils lzma* lzop maven ncftp ncurses-dev \
openjdk-8-jdk openjdk-8-jre patch pkg-config pngcrush pngquant python python-all-dev re2c schedtool \
squashfs-tools subversion texinfo unzip w3m xsltproc zip zlib1g-dev "${PACKAGES}"
# Purge problematic packages found in things like Mint 19 and Ubuntu 18
sudo apt purge -y openjdk-11-*

if [[ ! "$(command -v adb)" == "" ]]; then
    echo -e "Setting up udev rules for adb!"
    sudo curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules
    sudo groupdel adbusers
    sudo curl --create-dirs -L -o /usr/lib/sysusers.d/android-udev.conf -O -L https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/android-udev.conf
    if [[ "${LSB_RELEASE}" =~ "Mint 18" || "${LSB_RELEASE}" =~ "Ubuntu 16" ]]; then
        sudo groupadd adbusers
    else
        sudo systemd-sysusers
    fi
    sudo usermod -a -G adbusers "$(whoami)"
    sudo udevadm control --reload-rules
    sudo service udev restart
    adb kill-server
    sudo killall adb
fi

if [[ "$(command -v make)" ]]; then
    makeversion="$(make -v | head -1 | awk '{print $3}')"
    if [[ "${makeversion}" != "${LATEST_MAKE_VERSION}" ]]; then
        echo "Installing make ${LATEST_MAKE_VERSION} instead of ${makeversion}"
        bash ./setup/make.sh "${LATEST_MAKE_VERSION}"
    fi
fi

echo "Installing repo"
sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://raw.githubusercontent.com/akhilnarang/repo/master/repo
sudo chmod a+x /usr/local/bin/repo

bash ./setup/ccache.sh
bash ./setup/ninja.sh
