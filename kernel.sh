#!/usr/bin/env bash

source "${HOME}/scripts/startupstuff.sh";

# Kernel compiling script

function check_toolchain() {

    export TC="$(find ${TOOLCHAIN}/bin -type f -name aarch64-*-gcc)";

	if [[ -f "${TC}" ]]; then
		export CROSS_COMPILE="${TOOLCHAIN}/bin/$(echo ${TC} | awk -F '/' '{print $NF'} |\
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
export ARCH="arm64";
export TOOLCHAIN="${KERNELDIR}/toolchain/${DEVICE}";
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

export TCVERSION1="$(${CROSS_COMPILE}gcc --version | head -1 |\
awk -F '(' '{print $2}' | awk '{print tolower($1)}')"
export TCVERSION2="$(${CROSS_COMPILE}gcc --version | head -1 |\
awk -F ')' '{print $2}' | awk '{print tolower($1)}')"
if [[ -z "${NAME}" ]]; then
    export NAME="derp";
fi
export NAME="${NAME}-${DEVICE}-$(date +%Y%m%d-%H%M)";
export ZIPNAME="${NAME}.zip"
#export LOCALVERSION="${TCVERSION1}${TCVERSION2}"
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

WLAN_MODULE="drivers/staging/qcacld-2.0/wlan.ko";
if [[ -f "${OUTDIR}/${WLAN_MODULE}" ]]; then
    ${CROSS_COMPILE}strip --strip-unneeded ${OUTDIR}/${WLAN_MODULE};
    cp -v ${OUTDIR}/${WLAN_MODULE} ${ANYKERNEL}/modules/;
fi
cd -;
cd ${ANYKERNEL};
zip -r9 ${FINAL_ZIP} *;
cd -;

if [ -f "$FINAL_ZIP" ];
then
echo -e "$NAME zip can be found at $FINAL_ZIP";
git -C ${SRCDIR} log akhilnarang/stable..HEAD > ${ZIP_DIR}/${NAME}-changelog.txt;
if [[ "$@" =~ "transfer" ]]; then
    echo -e "Uploading ${ZIPNAME} to https://transfer.sh/";
    transfer "${FINAL_ZIP}";
fi
if [[ "$@" =~ "upload" ]]; then
    for f in -changelog.txt .zip; do
        scp "${ZIP_DIR}/${NAME}$f" "akhil@downloads.akhilnarang.me:downloads/kernel/oneplus3/Test/";
    done
    ssh akhil@downloads.akhilnarang.me ~/gdrive sync upload downloads/kernel 1DnrCzSchI9MNHXkbiaqlw-qyRkNIDKFQ
    GDRIVE_URL="https://drive.google.com/drive/folders/1PwLPGxfk0A1oj2nGATxdfYuguU7hZdJ4";
    DOWNLOADS_URL="https://downloads.akhilnarang.me/kernel/oneplus3/Test";
    bash ~/kronicbot/send_tg.sh @caesiumkernel "Check [Main]($DOWNLOADS_URL) | [Mirror]($GDRIVE_URL) for ${NAME}";
    bash ~/kronicbot/send_tg.sh "-1001223901635" "Check [Main]($DOWNLOADS_URL) | [Mirror]($GDRIVE_URL) for ${NAME}";
fi
else
echo -e "Zip Creation Failed =(";
fi # FINAL_ZIP check

exit ${exitCode};
