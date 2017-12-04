#!/usr/bin/env bash

source "${HOME}/scripts/startupstuff.sh";

# Kernel compiling script

function check_toolchain() {

    export TC="$(find ${TOOLCHAIN}/bin -type f -name aarch64-*-gcc)";

	if [[ -f "${TC}" ]]; then
		export CROSS_COMPILE="${CCACHE} ${TOOLCHAIN}/bin/$(echo ${TC} | awk -F '/' '{print $NF'} |\
sed -e 's/gcc//')";
		echo -e "Using toolchain: $(${CROSS_COMPILE}gcc --version | head -1)";
	else
		echo -e "No suitable toolchain found in ${TOOLCHAIN}";
		exit 1;
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
export MODULES_DIR="${ANYKERNEL}/modules";
export ARCH="arm64";
export TOOLCHAIN="${KERNELDIR}/toolchain/${DEVICE}";
export CCACHE="$(command -v ccache)";
export DEFCONFIG="${DEVICE}_defconfig";
export ZIP_DIR="${KERNELDIR}/files/${DEVICE}";
export IMAGE="${OUTDIR}/arch/${ARCH}/boot/Image.gz-dtb";

if [[ -z "${JOBS}" ]]; then
    export JOBS="$(grep -c '^processor' /proc/cpuinfo)";
fi

if [[ ! -d "${ANYKERNEL}" ]]; then
    hub clone AnyKernel2 -b "${DEVICE}" "${ANYKERNEL}";
fi

export MAKE="make O=${OUTDIR}";

check_toolchain;

if [[ -z "${NAME}" ]]; then
    export NAME="derp";
fi
export NAME="${NAME}-${DEVICE}-$(date +%Y%m%d-%H%M)";
export ZIPNAME="${NAME}.zip"
export FINAL_ZIP="${ZIP_DIR}/${ZIPNAME}"

[ ! -d "${ZIP_DIR}" ] && mkdir -pv ${ZIP_DIR}
[ ! -d "${OUTDIR}" ] && mkdir -pv ${OUTDIR}

cd "${SRCDIR}";
rm -fv ${IMAGE};

if [[ "$@" =~ "mrproper" ]]; then
    ${MAKE} mrproper
fi

if [[ "$@" =~ "clean" ]]; then
    ${MAKE} clean
fi

${MAKE} $DEFCONFIG || (echo "Failed to build with ${DEFCONFIG}, exiting!" && exit 1);

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

grep -q "=m" ${OUTDIR}/.config;
if [[ "$?" -eq 0 ]]; then
    find ${OUTDIR} -name "*.ko" -exec cp {} ${MODULES_DIR} \;
    for module in $(ls ${MODULES_DIR/*.ko}); do
  		${CROSS_COMPILE}strip --strip-unneeded "${MODULES_DIR}/${module}";
  	done
fi # Modules check 
cd -;
cd ${ANYKERNEL};
zip -r9 ${FINAL_ZIP} *;
cd -;

if [ -f "$FINAL_ZIP" ];
then
echo -e "$NAME zip can be found at $FINAL_ZIP";
if [[ "$@" =~ "transfer" ]]; then
    echo -e "Uploading ${ZIPNAME} to https://transfer.sh/";
    transfer "${FINAL_ZIP}";
fi
if [[ "$@" =~ "upload" ]]; then
	git -C ${SRCDIR} log akhilnarang/stable..HEAD > ${ZIP_DIR}/${NAME}-changelog.txt;
    for f in -changelog.txt .zip
    do
    scp "${ZIP_DIR}/${NAME}$f" "akhil@downloads.akhilnarang.me:downloads/kernel/oneplus3/Test/";
    done
    bash ~/kronicbot/send_tg.sh @caesiumkernel "Check https://downloads.akhilnarang.me/kernel/oneplus3/Test for ${NAME}";
fi
else
echo -e "Zip Creation Failed =(";
fi # FINAL_ZIP check

exit ${exitCode};
