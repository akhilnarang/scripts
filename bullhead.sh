#!/bin/bash
#
# Copyright � 2015, Akhil Narang "akhilnarang" <akhilnarang.1999@gmail.com>
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
export OP_DIR=/tmp/$DEVICE~kernel
export ZIMAGE="$OP_DIR/arch/arm/boot/zImage"
export ANYKERNEL=$THUGDIR/$DEVICE/anykernel
export THUGVERSION="ThugLife~1.0~CAF-bullhead";
export DEFCONFIG=$DEVICE"_defconfig";
export FINAL_ZIP="$THUGDIR/files/$DEVICE/$THUGVERSION.zip"
export CROSS_COMPILE="$THUGDIR/../arm-eabi-5.2-cortex-a15/bin/arm-eabi-"

if [ ! -d "$OP_DIR" ];
then
mkdir -p $OP_DIR;
fi

cd $THUGDIR/$DEVICE

make mrproper

if [ ! "$2" == "" ];
then
export CLEANOPTION=$2
if [ ! "$3" == "" ];
then
export PUSHOPTION=$3
fi
fi

if [ "$CLEANOPTION" == "clean" ] || [ "$CLEANOPTION" == "cleanbuild" ];
then
make clean mrproper
make clean mrproper O=$OP_DIR
rm -f include/linux/autoconf.h
else
export PUSHOPTION=$CLEANOPTION
fi

if [ -f ".config" ];
then
rm .config;
fi

if [ -f "$ZIMAGE" ];
then
rm -f $ZIMAGE;
fi

make $DEFCONFIG O=$OP_DIR
figlet ThugLife
START=$(date +"%s")
make $1 O=$OP_DIR
END=$(date +"%s")
DIFF=$(($END - $START))
echo -e "Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.";

if [ ! -f "$ZIMAGE" ];
then
echo -e "Kernel Compilation Failed!";
echo -e "Fix The Errors!";
$THUGDIR/$DEVICE/anykernel/tools/dtbToolCM -2 -o $OP_DIR/arch/arm/boot/dt.img -s 2048 -p $OP_DIR/scripts/dtc/ $OP_DIR/arch/arm/boot/

exit 1;
fi

cp -v $ZIMAGE $ANYKERNEL/tools/
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
fi
else
echo -e "Zip Creation Failed =(";
fi
