#!/bin/bash
#
# Copyright � 2015-2016, Akhil Narang "akhilnarang" <akhil.narang@protonmail.com>
# Build Script For ThugLife Kernel
#
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Please maintain this if you use this script or any part of it
#

export DEVICE="bullhead";
export ARCH="arm64"
export IMAGE="arch/$ARCH/boot/Image.gz-dtb"
export ANYKERNEL=$THUGDIR/$DEVICE/anykernel
export THUGVERSION="ThugLife~1.0~bullhead~$(date +%Y%m%d)";
export DEFCONFIG="thug_defconfig";
export ZIPS_DIR="$THUGDIR/files/$DEVICE"
export FINAL_ZIP="$ZIPS_DIR/$THUGVERSION.zip"
export CROSS_COMPILE="$THUGDIR/$DEVICE-toolchain/bin/aarch64-linux-android-"

if [ ! -d "$ZIPS_DIR" ];
then
mkdir -p $ZIPS_DIR
fi

cd $THUGDIR/$DEVICE

rm -f $IMAGE

make $DEFCONFIG
figlet ThugLife
START=$(date +"%s")
make $1
END=$(date +"%s")
DIFF=$(($END - $START))
echo -e "Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.";

if [ ! -f "$IMAGE" ];
then
echo -e "Kernel Compilation Failed!";
echo -e "Fix The Errors!";
else
echo -e "Build Succesfull Enjoy Living the ThugLife!"

cp -v $IMAGE $ANYKERNEL/kernel/zImage
cd $ANYKERNEL
zip -r9 $FINAL_ZIP *;
cd ..
if [ -f "$FINAL_ZIP" ];
then
echo -e "$THUGVERSION zip can be found at $FINAL_ZIP";
if [ ! "$PUSHOPTION" == "" ];
then
echo -e "Pushing $FINAL_ZIP to /sdcard";
adb kill-server
adb start-server
adb wait-for-device
adb push $FINAL_ZIP /sdcard/
fi # Checking $PUSHOPTION
else
echo -e "Zip Creation Failed =(";
fi # $FINAL_ZIP found
fi # no $IMAGE found
