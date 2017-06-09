#!/usr/bin/env bash

# Build script to compile Android ROMs


function sendHelp() {
	echo -e "Usage";
	echo -e "bash $0 <rom> <device> [NEEDED] [ROM can be aosip|caf|rr, device bacon|kenzo]"
	echo -e "Optional flags: <sync|nosync> <clean|noclean> <user|userdebug|eng> <rmccache> <-j X|--jobs X>";
    exit 1;
}

function rr() {
	export LUNCH="lineage";
	if [ -z "${RR_BUILDTYPE}" ]; then
		export RR_BUILDTYPE="Experimental";
	fi
	if [ -z "${days_to_log}" ]; then
		export days_to_log="0";
	fi
	export ZIPNAME="RR-N";
}

function caf() {
	export LUNCH="aosp";
	export ZIPNAME="aosp-caf-n-mr1";
}

function aosip() {
	export LUNCH="aosip";
	if [ -z "${AOSIP_BUILDTYPE}" ]; then
		export AOSIP_BUILDTYPE="Experimental";
	fi
	export ZIPNAME="AOSiP";
	export MAKE="kronic"
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		"aosip"|"caf"|"rr")
			ROM="$1";
			echo -e "ROM: ${ROM}";
			;;
		"oneplus3"|"kenzo")
			DEVICE="$1";
			echo -e "DEVICE: ${DEVICE}";
			;;
		"sync"|"nosync")
			SYNC="$1";
			echo -e "SYNC: ${SYNC}";
			;;
		"clean"|"noclean")
			CLEAN="$1";
			echo -e "CLEAN: ${CLEAN}";
			;;
		"user"|"userdebug"|"eng")
			VARIANT="$1";
			echo -e "VARIANT: ${VARIANT}";
			;;
		"rmccache")
			NUKECCACHE="true";
			;;
		"-j"|"--jobs")
			shift;
			if [ $# -gt 0 ]; then
				JOBS="$1";
			else
				echo -e "Please specify as value for jobs";
				exit 1;
			fi
			;;
		"-h"|"--help")
			sendHelp;
			;;
		*)
			echo -e "Invalid input!";
			sendHelp;
			;;
	esac
	shift
done

[ -z "${DEVICE}" ] && DEVICE="oneplus3"
[ -z "${ROM}" ] && ROM="rr"
[ -z "${VARIANT}" ] && VARIANT="userdebug"

ROM_SOURCE_DIR="${HOME}/${ROM}";

if [ ! -d "${ROM_SOURCE_DIR}" ]; then
	echo -e "${ROM_SOURCE_DIR} dosen\'t exist, please sync up in the correct folder and rerun";
	exit 1;
fi

cd "${ROM_SOURCE_DIR}";

if [ ! -d ".repo" ]; then
	echo -e ".repo folder not found - not in a properly synced android tree - please sync properly";
	exit 1;
fi

${ROM};

source build/envsetup.sh;


lunch "${LUNCH}_${DEVICE}-${VARIANT}"

if [ "${CLEAN}" == "clean" ]; then
	make clobber;
fi

if [ "${NUKECCACHE}" == "true" ]; then
        ccache -C;
fi

if [ -z "${MAKE}" ]; then
	if [ "$(grep '^bacon:' 'build/core/Makefile')" ]; then
		MAKE="bacon"
	else
		MAKE="otapackage"
	fi
fi

if [ -z "${JOBS}" ];then
	JOBS="$(nproc --all)";
fi

export USE_CCACHE=1;
ccache -M 30;
export CCACHE_DIR="${HOME}/.ccache-${DEVICE}";

if [ "$(command -v 'mka')" ]; then
	MAKE="mka ${MAKE}";
else
	MAKE="make -j${JOBS} ${MAKE}";
fi

START="$(date +%s)";
eval "${MAKE}";
END="$(date +%s)";

format_time ${END} ${START};

if [ "$(ls ${OUT}/${ZIPNAME}*.zip)" ]; then
	echo -e "Build succeeded";
else
	echo -e "Build failed";
fi
