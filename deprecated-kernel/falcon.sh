#!/bin/bash

# Build Script For KronicKernel

export DEVICE="falcon"
export TOOLCHAIN="${KERNELDIR}/${DEVICE}-toolchain"
export ARCH="arm"
export IMAGE="arch/$ARCH/boot/zImage-dtb"
export ANYKERNEL=$KERNELDIR/$DEVICE/anykernel
export DEFCONFIG="falcon_defconfig"
export ZIP_DIR="${KERNELDIR}/files/${DEVICE}"
if [ -z ${KERNELVERSION} ]; then
export KERNELVERSION="$(grep "KERNELVERSION ?= " ${KERNELDIR}/falcon/Makefile | awk '{print $3}')"
fi
export ZIPNAME="KronicKernel-falcon-${KERNELVERSION}-$(date +%Y%m%d-%H%M).zip"
export FINAL_ZIP="${ZIP_DIR}/${ZIPNAME}"

if [ -f "${TOOLCHAIN}/bin/arm-eabi-gcc" ]
then
export CROSS_COMPILE="${TOOLCHAIN}/bin/arm-eabi-"
elif [ -f "${TOOLCHAIN}/bin/arm-linux-androideabi-gcc" ]
then
export CROSS_COMPILE="${TOOLCHAIN}/bin/arm-linux-androideabi-"
else
echo -e "No suitable arm-eabi- or arm-linux-androideabi- toolchain found in ${TOOLCHAIN}"
fi

[ -d $ZIP_DIR ] || mkdir -p $ZIP_DIR

cd $KERNELDIR/falcon
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
make -j16
END=$(date +"%s")
DIFF=$(($END - $START))
echo -e "Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."

if [ ! -f "$IMAGE" ]
then
echo -e "Kernel Compilation Failed!"
echo -e "Fix The Errors!"
else
echo -e "Build Succesful!"

cp -v $IMAGE $ANYKERNEL/zImage
cd $ANYKERNEL
zip -r9 $FINAL_ZIP *
cd ..
if [ -f "$FINAL_ZIP" ]
then
echo -e "$THUGVERSION zip can be found at $FINAL_ZIP"
else
echo -e "Zip Creation Failed =("
fi # $FINAL_ZIP found
fi # no $IMAGE found
