#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-only
#
# Script to setup an Android 10 build
# environment for Fedora 31 / Rawhide.

# Packages
sudo dnf install \
    android-tools \
    autoconf213 \
    bison \
    bzip2 \
    ccache \
    curl \
    flex \
    gawk \
    gcc-c++ \
    git \
    glibc-devel \
    glibc-static \
    libstdc++-static \
    libX11-devel \
    make \
    mesa-libGL-devel \
    ncurses-devel \
    openssl \
    patch \
    zlib-devel \
    ncurses-devel.i686 \
    readline-devel.i686 \
    zlib-devel.i686 \
    libX11-devel.i686 \
    mesa-libGL-devel.i686 \
    glibc-devel.i686 \
    libstdc++.i686 \
    libXrandr.i686 \
    zip \
    perl-Digest-SHA \
    python2 \
    wget \
    lzop \
    openssl-devel \
    java-1.8.0-openjdk-devel \
    ImageMagick \
    ncurses-compat-libs \
    schedtool \
    lzip \
    vboot-utils \
    vim

# The package libncurses5 is not available, so we need to hack our way by symlinking the required library.
sudo ln -s /usr/lib/libncurses.so.6 /usr/lib/libncurses.so.5
sudo ln -s /usr/lib/libncurses.so.6 /usr/lib/libtinfo.so.5

# Repo
echo "Installing Git Repository Tool"
sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://storage.googleapis.com/git-repo-downloads/repo
sudo chmod a+rx /usr/local/bin/repo

echo -e "Setting up udev rules for ADB!"
sudo curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules
sudo chmod 644 /etc/udev/rules.d/51-android.rules
sudo chown root /etc/udev/rules.d/51-android.rules
sudo udevadm control --reload-rules
