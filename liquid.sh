#!/bin/bash
cd /android/common/LiquidSmooth-Layers
export UPLOAD_DIR=/var/www/html/downloads/LiquidSmooth-Layers/$device
if [ ! -d "$UPLOAD_DIR" ];
then
mkdir -p $UPLOAD_DIR
fi
rm -rf .repo/local_manifests/*
curl --create-dirs -L -o .repo/local_manifests/liquid.xml -O -L https://raw.githubusercontent.com/Anik1199/BlazingPhoenix/master/liquid.xml
repo sync -cfj8 --force-sync --no-clone-bundle
export TARGET_USE_O_LEVEL_3=true
export USE_CCACHE=1
export CCACHE_DIR=/android/.ccache
ccache -M 500G
. build/envsetup.sh
if [ "$cleanOrNot" == "1" ];
then
make -j10 clobber
elif [ "$cleanOrNot" == "2" ];
then
make -j10 dirty
else
figlet No Clean
fi
lunch liquid_$device-userdebug
make -j10 liquid
cp -v $OUT/LS*.zip $UPLOAD_DIR
