#!/usr/bin/env bash

# Script to setup an android build environment on Arch Linux and derivative distributions

clear
echo 'Starting Arch-based Android build setup'
# Uncomment the multilib repo, incase it was commented out
echo '[1/4] Enabling multilib repo'
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
# Sync, update, and prepare system
echo '[2/4] Syncing repositories and updating system packages'
sudo pacman -Syyu --noconfirm --needed git git-lfs multilib-devel fontconfig ttf-droid python-pyelftools
# Install android build prerequisites
echo '[3/4] Installing Android building prerequisites'
packages="ncurses5-compat-libs lib32-ncurses5-compat-libs aosp-devel xml2 lineageos-devel"
if command -v paru 2>&1 >/dev/null 
then
    paru -S --noconfirm --needed $packages
elif command -v yay 2>&1 >/dev/null
then
    yay -S --noconfirm --needed $packages
else
    for package in $packages; do
        echo "Installing $package"
        git clone https://aur.archlinux.org/"$package"
        cd "$package" || exit
        makepkg -si --skippgpcheck --noconfirm --needed
        cd - || exit
        rm -rf "$package"
    done
fi
# Install adb and associated udev rules
echo '[4/4] Installing adb convenience tools'
sudo pacman -S --noconfirm --needed android-tools android-udev

echo 'Setup completed, enjoy'
