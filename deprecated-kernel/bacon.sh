#!/usr/bin/env bash

# Build Script For Custom Kernel for the OnePlus One

# These won't change

[ -z ${KERNELDIR} ] && echo -e "Please set KERNELDIR" && exit 1

export DEVICE="bacon"
export ARCH="arm"
export TOOLCHAIN="${KERNELDIR}/toolchain/${DEVICE}"
export IMAGE="arch/${ARCH}/boot/zImage-dtb"
export ANYKERNEL="${KERNELDIR}/anykernel/${DEVICE}"
export DEFCONFIG="illusion_defconfig"
export ZIP_DIR="${KERNELDIR}/files/${DEVICE}"
export CCACHE_DIR="${KERNELDIR}/ccache-${DEVICE}"
ccache -M 5G

function check_toolchain() {

	if [ -f "${TOOLCHAIN}/bin/arm-eabi-gcc" ]; then
		export CROSS_COMPILE="${TOOLCHAIN}/bin/arm-eabi-"
		echo -e "Using toolchain: $(${CROSS_COMPILE}gcc --version | head -1)"
	elif [ -f "${TOOLCHAIN}/bin/arm-linux-androideabi-gcc" ]; then
		export CROSS_COMPILE="${TOOLCHAIN}/bin/arm-linux-androideabi-"
		echo -e "Using toolchain: $(${CROSS_COMPILE}gcc --version | head -1)"
	else
		echo -e "No suitable arm-eabi- or arm-linux-androideabi- toolchain \
		found in ${TOOLCHAIN}"
		exit 1
	fi
}

function check_version() {

	if [ -z ${CUSTOMVERSION} ]; then
		export CUSTOMVERSION="$(grep "CUSTOMVERSION ?= " \
		${KERNELDIR}/bacon/Makefile | awk '{print $3}')"
	fi
}


check_toolchain
check_version

export TCVERSION1="$(${CROSS_COMPILE}gcc --version | head -1 | awk '{print $2}' | sed -e 's/(//' -e 's/)//' | awk '{print tolower($0)}')"
export TCVERSION2="$(${CROSS_COMPILE}gcc --version | head -1 | awk '{print $3}' | awk '{print tolower($0)}')"
export ZIPNAME="${CUSTOMVERSION}-${DEVICE}-$(date +%Y%m%d-%H%M).zip"
export CUSTOMVERSION="${CUSTOMVERSION}-${TCVERSION1}.${TCVERSION2}"
export FINAL_ZIP="${ZIP_DIR}/${ZIPNAME}"

[ -d $ZIP_DIR ] || mkdir -p $ZIP_DIR

cd $KERNELDIR/bacon
rm -fv /tmp/IllusionKernel-bacon.zip ${IMAGE}

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
time make -j$(nproc)
exitCode="$?"
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
cd -
cd $ANYKERNEL
zip -r9 ${FINAL_ZIP} *
cp -v ${FINAL_ZIP} /tmp/IllusionKernel-bacon.zip
cd -
if [ -f "$FINAL_ZIP" ]
then
echo -e "$ZIPNAME zip can be found at $FINAL_ZIP"
else
echo -e "Zip Creation Failed =("
fi # $FINAL_ZIP found
fi # no $IMAGE found
exit ${exitCode}
