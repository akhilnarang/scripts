#!/usr/bin/env bash

source "${HOME}/scripts/startupstuff.sh";

# Kernel compiling script

function check_toolchain() {

	if [ -f "${TOOLCHAIN}/bin/aarch64-gcc" ]; then
		export CROSS_COMPILE="${TOOLCHAIN}/bin/aarch64-";
		echo -e "Using toolchain: $(${CROSS_COMPILE}gcc --version | head -1)";
	elif [ -f "${TOOLCHAIN}/bin/aarch64-linux-android-gcc" ]; then
		export CROSS_COMPILE="${TOOLCHAIN}/bin/aarch64-linux-android-";
		echo -e "Using toolchain: $(${CROSS_COMPILE}gcc --version | head -1)";
	elif [ -f "${TOOLCHAIN}/bin/aarch64-linux-gnu-gcc" ]; then
		export CROSS_COMPILE="${TOOLCHAIN}/bin/aarch64-linux-gnu-";
		echo -e "Using toolchain: $(${CROSS_COMPILE}gcc --version | head -1)";
	else
		echo -e "No suitable toolchain found in ${TOOLCHAIN}";
		exit 1;
	fi
}

function check_version() {

	if [ -z ${CUSTOMVERSION} ]; then
		export CUSTOMVERSION="$(grep CUSTOMVERSION ${SRCDIR}/Makefile -m1 |\
awk '{print $3}')";
	fi
}

if [[ -z ${KERNELDIR} ]]; then
    echo -e "Please set KERNELDIR";
    exit 1;
fi

export DEVICE=$1;
if [[ -z ${DEVICE} ]]; then
    export DEVICE="oneplus3";
fi

# These won't change
export SRCDIR="${KERNELDIR}/${DEVICE}";
export OUTDIR="${KERNELDIR}/${DEVICE}/out";
export ANYKERNEL="${KERNELDIR}/anykernel/${DEVICE}";
export ARCH="arm64";
export TOOLCHAIN="${KERNELDIR}/toolchain/${DEVICE}";
export DEFCONFIG="${DEVICE}_defconfig";
export ZIP_DIR="${KERNELDIR}/files/${DEVICE}";
export CCACHE_DIR="${KERNELDIR}/ccache-${DEVICE}";
export IMAGE="${OUTDIR}/arch/${ARCH}/boot/Image.gz-dtb";

if [[ -z "${JOBS}" ]]; then
    export JOBS="$(grep -c '^processor' /proc/cpuinfo)";
fi

export MAKE="make O=${OUTDIR}";

echo -e "Setting ccache - 5gb - ${CCACHE_DIR}"
ccache -M 5G;
check_toolchain;
check_version;

export TCVERSION1="$(${CROSS_COMPILE}gcc --version | head -1 |\
awk -F '(' '{print $2}' | awk '{print tolower($1)}')"
export TCVERSION2="$(${CROSS_COMPILE}gcc --version | head -1 |\
awk -F ')' '{print $2}' | awk '{print tolower($1)}')"
export ZIPNAME="$(echo ${CUSTOMVERSION}-${DEVICE}-$(date +%Y%m%d-%H%M).zip |\
sed -e 's|™||')"
export CUSTOMVERSION="${CUSTOMVERSION}-${TCVERSION1}.${TCVERSION2}"
export FINAL_ZIP="${ZIP_DIR}/${ZIPNAME}"

mkdir -pv "${ZIP_DIR} ${OUTDIR}";

cd "${SRCDIR}";
rm -fv ${IMAGE};

if [[ "$@" =~ "mrproper" ]]; then
    ${MAKE} mrproper
fi

if [[ "$@" =~ "clean" ]]; then
    ${MAKE} clean
fi

${MAKE} $DEFCONFIG;
START=$(date +"%s");
${MAKE} -j${JOBS};
exitCode="$?";
END=$(date +"%s")
DIFF=$(($END - $START))
echo -e "Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.";

if [[ ! -f "${IMAGE}" ]]; then
    echo -e "Build failed :P";
    exit 1;
else
    echo -e "Build Succesful!";
fi

echo -e "Copying kernel image";
cp -v "${IMAGE}" "${ANYKERNEL}/";

cd -;
cd ${ANYKERNEL};
zip -r9 ${FINAL_ZIP} *;
cd -;

if [ -f "$FINAL_ZIP" ];
then
echo -e "$ZIPNAME zip can be found at $FINAL_ZIP";
if [[ "$@" =~ "transfer" ]]; then
    echo -e "Uploading ${ZIPNAME} to https://transfer.sh/";
    transfer "${FINAL_ZIP}";
fi
else
echo -e "Zip Creation Failed =(";
fi # FINAL_ZIP check

exit ${exitCode};
