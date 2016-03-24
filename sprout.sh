 #!/bin/bash
 #
 # Copyright � 2015-2016, Akhil Narang "akhilnarang" <akhilnarang.1999@gmail.com>
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
export ZIMAGE="${THUGDIR}/${DEVICE}/arch/arm/boot/zImage"
export ANYKERNEL=$THUGDIR/$DEVICE/anykernel
export DEFCONFIG="thug_defconfig";
export ZIPS_DIR="${THUGDIR}/files/${DEVICE}"
export FINAL_ZIP="${ZIPS_DIR}/thuglife-${DEVICE}-$(date +%Y%m%d).zip"
export CROSS_COMPILE="$THUGDIR/$DEVICE-toolchain/bin/arm-linux-androideabi-"

cd $THUGDIR/$DEVICE

[ -d "${ZIPS_DIR}" ] || mkdir -p ${ZIPS_DIR}

if [ -f ".config" ];
then
rm .config;
fi

if [ -f "$ZIMAGE" ];
then
rm -f $ZIMAGE;
fi

make $DEFCONFIG
figlet ThugLife
START=$(date +"%s")
make -j16
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
