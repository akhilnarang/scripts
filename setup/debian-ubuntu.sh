#!/usr/bin/env bash

# Copyright (C) 2018 Harsh 'MSF Jarvis' Shandilya
# Copyright (C) 2018 Akhil Narang
# SPDX-License-Identifier: GPL-3.0-only

# Script to setup an AOSP Build environment on Ubuntu and Linux Mint

LATEST_MAKE_VERSION="4.2.1"
LATEST_CCACHE_VERSION="3.4.2+226_gc4613eb"
LATEST_NINJA_VERSION="1.8.2"
UBUNTU_14_PACKAGES="binutils-static curl figlet git-core libesd0-dev libwxgtk2.8-dev schedtool"
UBUNTU_16_PACKAGES="libesd0-dev"
UBUNTU_18_PACKAGES="curl"
DEBIAN_10_PACKAGES="curl rsync"
PACKAGES=""

LSB_RELEASE="$(lsb_release -d | cut -d ':' -f 2 | sed -e 's/^[[:space:]]*//')"

if [[ "${LSB_RELEASE}" =~ "Ubuntu 14" ]]; then
    PACKAGES="${UBUNTU_14_PACKAGES}"
elif [[ "${LSB_RELEASE}" =~ "Mint 18" || "${LSB_RELEASE}" =~ "Ubuntu 16" ]]; then
    PACKAGES="${UBUNTU_16_PACKAGES}"
elif [[ "${LSB_RELEASE}" =~ "Ubuntu 18" ]]; then
    PACKAGES="${UBUNTU_18_PACKAGES}"
elif [[ "${LSB_RELEASE}" =~ "Debian GNU/Linux 10" ]]; then
    PACKAGES="${DEBIAN_10_PACKAGES}"
fi

sudo apt update -y
sudo apt install -y adb autoconf automake axel bc bison build-essential clang cmake expat fastboot flex \
g++ g++-multilib gawk gcc gcc-multilib gnupg gperf htop imagemagick lib32ncurses5-dev lib32z1-dev libtinfo5 \
libc6-dev libcap-dev libexpat1-dev libgmp-dev liblz4-* liblzma* libmpc-dev libmpfr-dev \
libncurses5-dev libsdl1.2-dev libssl-dev libtool libxml2 libxml2-utils lzma* lzop maven ncftp ncurses-dev \
patch patchelf pkg-config pngcrush pngquant python python-all-dev re2c schedtool squashfs-tools subversion texinfo \
unzip w3m xsltproc zip zlib1g-dev "${PACKAGES}"

# In Ubuntu 18.10 and Debian Buster libncurses5 package is not available, so we need to hack our way by symlinking required library
if [[ "${LSB_RELEASE}" =~ "Ubuntu 18.10" || "${LSB_RELEASE}" =~ "Debian GNU/Linux 10" ]]; then
  if [[ -e /lib/x86_64-linux-gnu/libncurses.so.6 && ! -e /usr/lib/x86_64-linux-gnu/libncurses.so.5 ]]; then
    sudo ln -s /lib/x86_64-linux-gnu/libncurses.so.6 /usr/lib/x86_64-linux-gnu/libncurses.so.5
  fi
fi

if [[ ! "$(command -v adb)" == "" ]]; then
    echo -e "Setting up udev rules for adb!"
    sudo curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules
    sudo chmod 644 /etc/udev/rules.d/51-android.rules
    sudo chown root /etc/udev/rules.d/51-android.rules
    sudo systemctl restart udev
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
sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://github.com/akhilnarang/repo/raw/master/repo
sudo chmod a+x /usr/local/bin/repo

if [[ "$(command -v ccache)" ]]; then
    ccacheversion="$(ccache -V | head -1 | awk '{print $3}')"
    if [[ "${ccacheversion}" != "${LATEST_CCACHE_VERSION}" ]]; then
        echo "Installing ccache ${LATEST_CCACHE_VERSION} instead of ${ccacheversion}"
        bash ./setup/ccache.sh
    fi
else
    bash ./setup/ccache.sh
fi

if [[ "$(command -v ninja)" ]]; then
    ninjaversion="$(ninja --version)"
    if [[ "${ninjaversion}" != "${LATEST_NINJA_VERSION}" ]]; then
        echo "Installing ninja ${LATEST_NINJA_VERSION} instead of ${ninjaversion}"
        bash ./setup/ninja.sh
    fi
else
    bash ./setup/ninja.sh
fi
