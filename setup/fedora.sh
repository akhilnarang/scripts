#!/usr/bin/env bash

sudo dnf install autoconf213 bison bzip2 ccache curl flex gawk gcc-c++ git glibc-devel \
glibc-static libstdc++-static libX11-devel make mesa-libGL-devel ncurses-devel patch zlib-devel \
ncurses-devel.i686 readline-devel.i686 zlib-devel.i686 libX11-devel.i686 mesa-libGL-devel.i686 \
glibc-devel.i686 libstdc++.i686 libXrandr.i686 zip perl-Digest-SHA wget lzop openssl-devel \
java-1.8.0-openjdk-devel ImageMagick ncurses-compat-libs schedtool

sudo ln -s /usr/lib/libncurses.so.6 /usr/lib/libncurses.so.5
sudo ln -s /usr/lib/libncurses.so.6 /usr/lib/libtinfo.so.5
