#!/bin/bash
#
# Copyright � 2016, Akhil Narang "akhilnarang" <akhilnarang.1999@gmail.com>
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

export DEVICE="falcon";
export ARCH="arm"
export IMAGE="arch/$ARCH/boot/zImage-dtb"
export ANYKERNEL=$THUGDIR/$DEVICE/anykernel
export DEFCONFIG="falcon_defconfig";
export FINAL_ZIP="$THUGDIR/files/$DEVICE/thuglife-falcon-$(date +%Y%m%d).zip"
export CROSS_COMPILE="$THUGDIR/falcon-toolchain/bin/arm-linux-androideabi-"

cd /data/ThugLife/falcon
rm -f $IMAGE
make mrproper
make $DEFCONFIG
figlet ThugLife
START=$(date +"%s")
make -j16
END=$(date +"%s")
DIFF=$(($END - $START))
echo -e "Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.";

if [ ! -f "$IMAGE" ];
then
echo -e "Kernel Compilation Failed!";
echo -e "Fix The Errors!";
else
echo -e "Build Succesfull Enjoy Living the ThugLife!"

cp -v $IMAGE $ANYKERNEL/zImage
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
