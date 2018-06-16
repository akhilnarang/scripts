#!/usr/bin/env bash

# Buld script for Kronic kernel for Nexus 5X

if [ -z $KERNELDIR ]
then
echo "Please set KERNELDIR"
exit 1
else

export DEVICE="bullhead"
export TOOLCHAIN="${KERNELDIR}/${DEVICE}-toolchain"
export ARCH="arm64"
export IMAGE="arch/$ARCH/boot/Image.gz-dtb"
export ANYKERNEL=$KERNELDIR/$DEVICE/anykernel
export DEFCONFIG="kronic_defconfig"
export ZIPS_DIR="$KERNELDIR/files/$DEVICE"
if [ -z $KRONICVERSION ]; then
export KRONICVERSION="$(grep "KRONICVERSION ?= " ${KERNELDIR}/bullhead/Makefile | awk '{print $3}')"
fi
export ZIPNAME="Kronic-bullhead-${KRONICVERSION}-$(date +%Y%m%d).zip"
export FINAL_ZIP="$ZIPS_DIR/$ZIPNAME"

if [ -f "${TOOLCHAIN}/bin/aarch64-gcc" ]
then
export CROSS_COMPILE="${TOOLCHAIN}/bin/aarch64-"
elif [ -f "${TOOLCHAIN}/bin/aarch64-linux-android-gcc" ]
then
export CROSS_COMPILE="${TOOLCHAIN}/bin/aarch64-linux-android-"
else
echo -e "No suitable aarch64- or aarch64-linux-android- toolchain found in ${TOOLCHAIN}"
fi

export USE_CCACHE=1
export CCACHE_DIR=${KERNELDIR}/ccache-${DEVICE}
ccache -M 5G

case $(hostname) in
randomness) export THREADS=10;;
aosip.xyz) export THREADS=16;;
node3) export THREADS=24;;
*) export THREADS=$(nproc);;
esac

if [ ! -d "$ZIPS_DIR" ]
then
mkdir -p $ZIPS_DIR
fi

cd $KERNELDIR/$DEVICE

rm -f $IMAGE

if [[ "$1" =~ "mrproper" ]]
then
make mrproper
fi

if [[ "$1" =~ "clean" ]]
then
make clean
fi

make $DEFCONFIG
START=$(date +"%s")
make -j${THREADS}
END=$(date +"%s")
DIFF=$(($END - $START))
echo -e "Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."

if [ ! -f "$IMAGE" ]
then
echo -e "Kernel Compilation Failed!"
echo -e "Fix The Errors!"
else
echo -e "Build Succesful!"

cp -v $IMAGE $ANYKERNEL/kernel/zImage
cd $ANYKERNEL
zip -r9 $FINAL_ZIP *
cd ..
if [ -f "$FINAL_ZIP" ]
then
echo -e "$ZIPNAME can be found at $FINAL_ZIP"
else
echo -e "Zip Creation Failed =("
fi # FINAL_ZIP found
fi # no IMAGE found
fi # KERNELDIR not defined
