#!/usr/bin/env bash
#
# Copyright � 2015-2016, Akhil Narang "akhilnarang" <akhilnarang.1999@gmail.com>
# Build Script For Kronic Kernel
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

if [ -z $KRONICDIR ];
then
echo "Please set KRONICDIR";
exit 1;
else

export DEVICE="bullhead";
export TOOLCHAIN="${KRONICDIR}/${DEVICE}-toolchain"
export ARCH="arm64"
export IMAGE="arch/$ARCH/boot/Image.gz-dtb"
export ANYKERNEL=$KRONICDIR/$DEVICE/anykernel
export DEFCONFIG="kronic_defconfig";
export ZIPS_DIR="$KRONICDIR/files/$DEVICE"
if [ -z $KRONICVERSION ]; then
export KRONICVERSION="$(grep "CUSTOM_VERSION ?= " ${KRONICDIR}/bullhead/Makefile | awk '{print $3}')";
fi
export ZIPNAME="Kronic-bullhead-${KRONICVERSION}-$(date +%Y%m%d).zip"
export FINAL_ZIP="$ZIPS_DIR/$ZIPNAME"

if [ -f "${TOOLCHAIN}/bin/aarch64-gcc" ];
then
export CROSS_COMPILE="${TOOLCHAIN}/bin/aarch64-"
elif [ -f "${TOOLCHAIN}/bin/aarch64-linux-android-gcc" ];
then
export CROSS_COMPILE="${TOOLCHAIN}/bin/aarch64-linux-android-"
else
echo -e "No suitable aarch64- or aarch64-linux-android- toolchain found in ${TOOLCHAIN}"
fi


if [ ! -d "$ZIPS_DIR" ];
then
mkdir -p $ZIPS_DIR
fi

cd $KRONICDIR/$DEVICE

rm -f $IMAGE

if [[ "$1" =~ "mrproper" ]];
then
make mrproper
fi

if [[ "$1" =~ "clean" ]];
then
make clean
fi

make $DEFCONFIG
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
echo -e "Build Succesfull Enjoy Living the KRONICLife!"

cp -v $IMAGE $ANYKERNEL/kernel/zImage
cd $ANYKERNEL
zip -r9 $FINAL_ZIP *;
cd ..
if [ -f "$FINAL_ZIP" ];
then
echo -e "$ZIPNAME can be found at $FINAL_ZIP";
else
echo -e "Zip Creation Failed =(";
fi # FINAL_ZIP found
fi # no IMAGE found
fi # KRONICDIR not defined
