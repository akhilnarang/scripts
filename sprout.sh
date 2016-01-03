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

export DEVICE="sprout";
export OP_DIR=/tmp/$DEVICE~kernel
export ZIMAGE="$OP_DIR/arch/arm/boot/zImage"
export THUGVERSION="ThugLife~1.4~$(date +%Y%m%d)";
export ANYKERNEL=$THUGDIR/$DEVICE/anykernel
export DEFCONFIG=$DEVICE"_defconfig";
export FINAL_ZIP="$THUGDIR/files/$DEVICE/$THUGVERSION.zip"
export CROSS_COMPILE="$THUGDIR/$DEVICE-toolchain/bin/arm-eabi-"

cd $THUGDIR/$DEVICE

if [ ! -d "$OP_DIR" ];
then
mkdir -p $OP_DIR;
fi

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
make clean
make mrproper
rm -f include/linux/autoconf.h
rm -rf $OP_DIR
mkdir -p $OP_DIR
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
exit 1;
fi

cp -v $ZIMAGE $ANYKERNEL/tools/
cd $ANYKERNEL
zip -r9 $FINAL_ZIP *;
cd ..
if [ -f "$FINAL_ZIP" ];
then
echo -e "$THUGVERSION zip can be found at $FINAL_ZIP";
cp -v $FINAL_ZIP /var/www/html/ThugLife/sprout
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
