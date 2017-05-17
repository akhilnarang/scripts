#!/usr/bin/env bash

# Custom build script by Akhil for Dominator Kernel

# These won't change

[ -z ${KERNELDIR} ] && echo -e "Please set KERNELDIR" && exit 1

export DEVICE="kenzo";
export SRCDIR="${KERNELDIR}/${DEVICE}";
export ARCH="arm64";
export TOOLCHAIN="${KERNELDIR}/toolchain/${DEVICE}";
export IMAGE="${SRCDIR}/arch/${ARCH}/boot/Image";
export DTIMAGE="${SRCDIR}/arch/${ARCH}/boot/dt.img";
export DTBTOOL="${SRCDIR}/dtbToolCM";
export ANYKERNEL="${KERNELDIR}/anykernel/${DEVICE}";
export DEFCONFIG="kenzo_defconfig";
export ZIP_DIR="${KERNELDIR}/files/${DEVICE}";
export CCACHE_DIR="${KERNELDIR}/ccache-${DEVICE}";
ccache -M 5G

function check_toolchain() {

	if [ -f "${TOOLCHAIN}/bin/aarch64-gcc" ]; then
		export CROSS_COMPILE="${TOOLCHAIN}/bin/aarch64-"
		echo -e "Using toolchain: $(${CROSS_COMPILE}gcc --version | head -1)"
	elif [ -f "${TOOLCHAIN}/bin/aarch64-linux-android-gcc" ]; then
		export CROSS_COMPILE="${TOOLCHAIN}/bin/aarch64-linux-android-"
		echo -e "Using toolchain: $(${CROSS_COMPILE}gcc --version | head -1)"
	elif [ -f "${TOOLCHAIN}/bin/aarch64-linux-gnu-gcc" ]; then
		export CROSS_COMPILE="${TOOLCHAIN}/bin/aarch64-linux-gnu-"
		echo -e "Using toolchain: $(${CROSS_COMPILE}gcc --version | head -1)"
	else
		echo -e "No suitable aarch64- or aarch64-linux-android- or aarch64-linux-gnu- \
                toolchain found in ${TOOLCHAIN}"
		exit 1;
	fi
}

function check_version() {

	if [ -z ${CUSTOMVERSION} ]; then
		export CUSTOMVERSION="Dominator";
	fi
}


check_toolchain;
check_version;

export TCVERSION1="$(${CROSS_COMPILE}gcc --version | head -1 | awk -F '(' '{print $2}' | awk '{print tolower($1)}')"
export TCVERSION2="$(${CROSS_COMPILE}gcc --version | head -1 | awk -F ')' '{print $2}' | awk '{print tolower($1)}')"
export ZIPNAME="${CUSTOMVERSION}-${DEVICE}-$(date +%Y%m%d-%H%M).zip"
export CUSTOMVERSION="${CUSTOMVERSION}-${TCVERSION1}.${TCVERSION2}"
export FINAL_ZIP="${ZIP_DIR}/${ZIPNAME}"

[ -d $ZIP_DIR ] || mkdir -p $ZIP_DIR

cd $KERNELDIR/kenzo
rm -fv /tmp/Dominator-kenzo.zip ${IMAGE}

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
time make -j$(nproc) Image
exitCode="$?"
${DTBTOOL}  -2 -o arch/arm64/boot/dt.img  -s 2048 -p scripts/dtc/ arch/arm/boot/dts/
END=$(date +"%s")
DIFF=$(($END - $START))
echo -e "Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.";

if [[ ! -f "${IMAGE}" ]] || [[ ! -f "${DTIMAGE}" ]]; then
echo -e "Kernel Compilation Failed!";
echo -e "Fix The Errors!";
else
echo -e "Build Succesful!"

cp -v "${IMAGE}" "${ANYKERNEL}/zImage"
cp -v "${DTIMAGE}" "${ANYKERNEL}/dtb"
cd -
cd ${ANYKERNEL}
zip -r9 ${FINAL_ZIP} *;
cp -v ${FINAL_ZIP} /tmp/Dominator-kenzo.zip
cd -
if [ -f "$FINAL_ZIP" ];
then
echo -e "$ZIPNAME zip can be found at $FINAL_ZIP";
else
echo -e "Zip Creation Failed =(";
fi # $FINAL_ZIP found
fi # no $IMAGE found
exit ${exitCode}
