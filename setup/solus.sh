#!/usr/bin/env bash

# Copyright (C) 2019 ZVNexus
# SPDX-License-Identifier: GPL-3.0-only

# Script to setup an AOSP build environment on Solus

sudo eopkg it -c system.devel
sudo eopkg it openjdk-8-devel curl-devel git gnupg gperf libgcc-32bit libxslt-devel lzop ncurses-32bit-devel ncurses-devel readline-32bit-devel rsync schedtool sdl1-devel squashfs-tools unzip wxwidgets-devel zip zlib-32bit-devel lzip

# ADB/Fastboot
sudo eopkg bi --ignore-safety https://raw.githubusercontent.com/solus-project/3rd-party/master/programming/tools/android-tools/pspec.xml
sudo eopkg it android-tools*.eopkg
sudo rm android-tools*.eopkg

# udev rules
echo "Setting up udev rules for adb!"
sudo curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules
sudo chmod 644 /etc/udev/rules.d/51-android.rules
sudo chown root /etc/udev/rules.d/51-android.rules
sudo usysconf run -f

echo "Installing repo"
sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://storage.googleapis.com/git-repo-downloads/repo
sudo chmod a+x /usr/local/bin/repo

echo "You are now ready to build Android!"
