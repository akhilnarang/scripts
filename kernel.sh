#!/usr/bin/env bash

# Kernel compiling script

function check_device() {

device_to_check=$1;
shift;
if [[ "${device_to_check}" =~ "$@" ]] \
|| [[ "$(pwd | awk -F '/' '{print $NF}')" =~ "${device_to_check}" ]]; then
    export DEVICE="${device_to_check}"
fi

}

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
		echo -e "No suitable aarch64- or aarch64-linux-android- or \
aarch64-linux-gnu- toolchain found in ${TOOLCHAIN}";
		exit 1;
	fi
}

function check_version() {

	if [ -z ${CUSTOMVERSION} ]; then
		export CUSTOMVERSION="$(grep CUSTOMVERSION ${SRCDIR}/Makefile -m1 |\
awk '{print $3}')";
	fi
  echo "${CUSTOMVERSION}";
}

if [[ -z ${KERNELDIR} ]]; then
    echo -e "Please set KERNELDIR";
    exit 1;
fi

for d in oneplus3 kenzo; do
    check_device $d $@
    [[ -z ${DEVICE} ]] && continue || break;
done

if [[ -z ${DEVICE} ]]; then
    echo -e "Please specify device!";
    exit 1;
fi

# These won't change
export SRCDIR="${KERNELDIR}/${DEVICE}";
export ARCH="arm64";
export TOOLCHAIN="${KERNELDIR}/toolchain/${DEVICE}";
export DTBTOOL="${SRCDIR}/dtbToolCM";
export ANYKERNEL="${KERNELDIR}/anykernel/${DEVICE}";
export DEFCONFIG="${DEVICE}_defconfig";
export ZIP_DIR="${KERNELDIR}/files/${DEVICE}";
export CCACHE_DIR="${KERNELDIR}/ccache-${DEVICE}";

if [[ -z "${JOBS}" ]]; then
    export JOBS="$(grep -c '^processor' /proc/cpuinfo)";
fi

if [[ "${DEVICE}" == "kenzo" ]]; then
    export IMAGE="${SRCDIR}/arch/${ARCH}/boot/Image";
    export DTIMAGE="${SRCDIR}/arch/${ARCH}/boot/dt.img";
    export TARGET="Image";
elif [[ "${DEVICE}" == "oneplus3" ]]; then
    export IMAGE="${SRCDIR}/arch/${ARCH}/boot/Image.gz-dtb";
else
    echo -e "RIP in pieces!";
    exit 1;
fi

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

if [[ -d $ZIP_DIR ]]; then
    mkdir -pv $ZIP_DIR
fi

cd "${SRCDIR}";
rm -fv ${IMAGE}

if [[ "$@" =~ "mrproper" ]]; then
    make mrproper
fi

if [[ "$@" =~ "clean" ]]; then
    make clean
fi

make $DEFCONFIG;
START=$(date +"%s");
time make -j${JOBS} ${TARGET};
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

if [[ "${DEVICE}" == "kenzo" ]]; then
    echo -e "Generating dtb";
    ${DTBTOOL}  -2 -o ${DTIMAGE} -s 2048 -p scripts/dtc/ arch/arm/boot/dts/
    if [[ ! -f "${DTIMAGE}" ]]; then
        echo -e "dtb generation failed!";
    else
        echo -e "dtb generation succesful!";
    fi
fi

echo -e "Copying kernel image";
cp -v "${IMAGE}" "${ANYKERNEL}/";

if [[ "${DEVICE}" == "kenzo" ]]; then
    echo -e "Copying dtb";
    cp -v "${DTIMAGE}" "${ANYKERNEL}/dtb";
fi

cd -;
cd ${ANYKERNEL};
zip -r9 ${FINAL_ZIP} *;
cd -;

if [ -f "$FINAL_ZIP" ];
then
echo -e "$ZIPNAME zip can be found at $FINAL_ZIP";
else
echo -e "Zip Creation Failed =(";
fi # FINAL_ZIP check

exit ${exitCode};
