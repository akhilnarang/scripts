#!/usr/bin/env bash

source "${HOME}/scripts/startupstuff.sh";

# Kernel compiling script

function check_toolchain() {

    TC=$(find "${TOOLCHAIN}"/bin -type f -name "aarch64-*-gcc");

	if [[ -f "${TC}" ]]; then
		CROSS_COMPILE="${TOOLCHAIN}/bin/$(echo "${TC}" | awk -F '/' '{print $NF}' |\
sed -e 's/gcc//')";
		export CROSS_COMPILE;
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
    JOBS="$(grep -c '^processor' /proc/cpuinfo)";
    export JOBS;
fi

if [[ ! -d "${ANYKERNEL}" ]]; then
    hub clone AnyKernel2 -b "${DEVICE}" "${ANYKERNEL}";
fi

export MAKE="make O=${OUTDIR}";

check_toolchain;

if [[ -z "${NAME}" ]]; then
    export NAME="derp";
fi
NAME="${NAME}-${DEVICE}-$(date +%Y%m%d-%H%M)";
export NAME;
export ZIPNAME="${NAME}.zip"
export FINAL_ZIP="${ZIP_DIR}/${ZIPNAME}"

[ ! -d "${ZIP_DIR}" ] && mkdir -pv "${ZIP_DIR}"
[ ! -d "${OUTDIR}" ] && mkdir -pv "${OUTDIR}"

cd "${SRCDIR}" || exit;
rm -fv "${IMAGE}";

if [[ "$@" =~ "mrproper" ]]; then
    ${MAKE} mrproper
fi

if [[ "$@" =~ "clean" ]]; then
    ${MAKE} clean
fi

${MAKE} $DEFCONFIG;
START=$(date +"%s");
${MAKE} -j"${JOBS}";
exitCode="$?";
END=$(date +"%s")
DIFF=$((END - START))
echo -e "Build took $((DIFF / 60)) minute(s) and $((DIFF % 60)) seconds.";

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
    "${CROSS_COMPILE}strip" --strip-unneeded "${OUTDIR}/${WLAN_MODULE}";
    cp -v "${OUTDIR}/${WLAN_MODULE}" "${ANYKERNEL}/modules/";
fi
cd - || exit;
cd "${ANYKERNEL}" || exit;
zip -r9 "${FINAL_ZIP}" *;
cd - || exit;

if [ -f "$FINAL_ZIP" ];
then
echo -e "$NAME zip can be found at $FINAL_ZIP";
git -C "${SRCDIR}" log akhilnarang/stable..HEAD > "${ZIP_DIR}"/"${NAME}"-changelog.txt;
if [[ "$@" =~ "transfer" ]]; then
    echo -e "Uploading ${ZIPNAME} to https://transfer.sh/";
    transfer "${FINAL_ZIP}";
fi
if [[ "$@" =~ "upload" ]]; then
    for f in -changelog.txt .zip
    do
    scp "${ZIP_DIR}/${NAME}$f" "akhil@downloads.akhilnarang.me:downloads/kernel/oneplus3/Test/";
    done
    bash ~/kronicbot/send_tg.sh @caesiumkernel "Check https://downloads.akhilnarang.me/kernel/oneplus3/Test for ${NAME}";
    bash ~/kronicbot/send_tg.sh "-1001223901635" "Check https://downloads.akhilnarang.me/kernel/oneplus3/Test for ${NAME}";
fi
else
echo -e "Zip Creation Failed =(";
fi # FINAL_ZIP check

exit ${exitCode};
