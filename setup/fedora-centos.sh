#
# Copyright © 2019 baalajimaestro
#
# SPDX-License-Identifier: GPL-3.0

# Script to setup an AOSP Build environment on Fedora/CentOS 8
# Referred from https://raw.githubusercontent.com/tripLr/fedora_build/fedora31/android_binaries_fedora31.sh

### Lets start clean
sudo dnf clean all
sudo dnf -y update

# This is replication of arch's base-devel
sudo dnf groupinstall -y "Development Tools" "Development Libraries"

# There goes the deps
sudo dnf install -y readline.* \
                    readline-devel.* \
                    zlibrary.* \
                    zlibrary-devel.* \
                    ncurses.* \
                    ncurses-* \
                    SDL.* \
                    SDL-* \
                    SDL2.* \
                    SDL2-* \
                    ImageMagick \
                    gcc-c++ \
                    openssl \
                    openssl-libs.* \
                    gtk3 \
                    gtk3-devel.* \
                    libxml2 \
                    libxml2-devel.* \
                    libxslt \
                    zlib.* \
                    lzma \
                    xz


# What if you didnt set this up?
GIT_USERNAME="$(git config --get user.name)"
GIT_EMAIL="$(git config --get user.email)"
echo "Configuring Git"
if [[ -z ${GIT_USERNAME} ]]; then
	echo "Enter your name: "
	read -r NAME
	git config --global user.name "${NAME}"
fi
if [[ -z ${GIT_EMAIL} ]]; then
	echo "Enter your email: "
	read -r EMAIL
	git config --global user.email "${EMAIL}"
fi
