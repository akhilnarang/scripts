#!/usr/bin/env bash

# Script to setup an android build environment on Arch Linux and derivative distributions

clear
# Uncomment the multilib repo, incase it was commented out
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
echo Installing Dependencies!
# Update
sudo pacman -Syyu
# Install pacaur
sudo pacman -S base-devel git wget multilib-devel cmake svn clang lzip patchelf
# Install ncurses5-compat-libs, lib32-ncurses5-compat-libs, aosp-devel, xml2, and lineageos-devel
for package in ncurses5-compat-libs lib32-ncurses5-compat-libs aosp-devel xml2 lineageos-devel; do
    git clone https://aur.archlinux.org/"${package}"
    cd "${package}" || continue
    makepkg -si --skippgpcheck
    cd - || break
    rm -rf "${package}"
done

sudo pacman -S android-tools
echo -e "Setting up udev rules for adb!"
sudo curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules
sudo chmod 644 /etc/udev/rules.d/51-android.rules
sudo chown root /etc/udev/rules.d/51-android.rules
sudo udevadm control --reload-rules

# Revert ccache to an older version.
echo "Reverting ccache to older version....."
sudo rm -rf /usr/bin/ccache
wget https://github.com/ccache/ccache/releases/download/v3.6/ccache-3.6.tar.xz
tar -xvf ccache-3.6.tar.xz
sudo pacman -S asciidoc -y
cd ccache-3.6/
export CC="clang"
./autogen.sh
./configure
sed -i 's/-Wall -W/-Wall -W -Wno-implicit-fallthrough -Wno-extra-semi-stmt/g' Makefile
make
sudo make install

# Cleanup

cd ..
rm -rf ccache-3.6 ccache-3.6.tar.xz

echo "All Done :'D"
echo "Don't forget to run these commands before building, or make sure the python in your PATH is python2 and not python3"
echo "
virtualenv2 venv
source venv/bin/activate"
