#!/usr/bin/env bash

# Script to setup an android build environment on Arch Linux and derivative distributions

clear
# Uncomment the multilib repo, incase it was commented out
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
echo Installing Dependencies!
# Update
sudo pacman -Syyu
# Install pacaur
sudo pacman -S base-devel git wget multilib-devel cmake svn clang lzip patchelf inetutils python2-distlib
# Install ncurses5-compat-libs, lib32-ncurses5-compat-libs, aosp-devel, xml2, and lineageos-devel
for package in ncurses5-compat-libs lib32-ncurses5-compat-libs aosp-devel xml2 lineageos-devel; do
    git clone https://aur.archlinux.org/"${package}"
    cd "${package}" || continue
    makepkg -si --skippgpcheck
    cd - || break
    rm -rf "${package}"
done

echo -e "Installing platform tools & udev rules for adb!"
sudo pacman -S android-tools android-udev
