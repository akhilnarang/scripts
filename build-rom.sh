#!/usr/bin/env bash

# Build script to compile Android ROMs

# FORMATS THE TIME
function format_time() {
    MINS=$(((${1}-${2})/60))
    SECS=$(((${1}-${2})%60))
    if [[ ${MINS} -ge 60 ]]; then
        HOURS=$((${MINS}/60))
        MINS=$((${MINS}%60))
    fi

    if [[ ${HOURS} -eq 1 ]]; then
        TIME_STRING+="1 HOUR, "
    elif [[ ${HOURS} -ge 2 ]]; then
        TIME_STRING+="${HOURS} HOURS, "
    fi

    if [[ ${MINS} -eq 1 ]]; then
        TIME_STRING+="1 MINUTE"
    else
        TIME_STRING+="${MINS} MINUTES"
    fi

    if [[ ${SECS} -eq 1 && -n ${HOURS} ]]; then
        TIME_STRING+=", AND 1 SECOND"
    elif [[ ${SECS} -eq 1 && -z ${HOURS} ]]; then
        TIME_STRING+=" AND 1 SECOND"
    elif [[ ${SECS} -ne 1 && -n ${HOURS} ]]; then
        TIME_STRING+=", AND ${SECS} SECONDS"
    elif [[ ${SECS} -ne 1 && -z ${HOURS} ]]; then
        TIME_STRING+=" AND ${SECS} SECONDS"
    fi

    echo ${TIME_STRING}
}

function sendHelp() {
	echo -e "Usage";
	echo -e "bash $0 <rom> <device> [NEEDED] [ROM can be aosip|caf|rr, device bacon|kenzo]"
	echo -e "Optional flags: <sync|nosync> <clean|noclean> <user|userdebug|eng> <rmccache> <-j X|--jobs X> <bootimage|recoveryimage>";
    exit 1;
}

function rr() {
	export LUNCH="lineage";
	if [[ -z "${RR_BUILDTYPE}" ]]; then
		export RR_BUILDTYPE="Experimental";
	fi
	if [[ -z "${days_to_log}" ]]; then
		export days_to_log="0";
	fi
	export ZIPNAME="RR-N";
}

function caf() {
	export LUNCH="aosp";
	export ZIPNAME="aosp-caf-n-mr2";
}

function aosip() {
	export LUNCH="aosip";
	if [[ -z "${AOSIP_BUILDTYPE}" ]]; then
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
			if [[ $# -gt 0 ]]; then
				JOBS="$1";
			else
				echo -e "Please specify as value for jobs";
				exit 1;
			fi
			;;
                "bootimage"|recoveryimage)
                        TARGET="$1";
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

[[ -z "${DEVICE}" ]] && DEVICE="oneplus3"
[[ -z "${ROM}" ]] && ROM="rr"
[[ -z "${VARIANT}" ]] && VARIANT="userdebug"


if [[ "$(hostname)" == "WorldOfVoid" ]]; then
    BASEDIR="/mnt/raidzero";
else
    BASEDIR="${HOME}";
fi

ROM_SOURCE_DIR="${BASEDIR}/${ROM}";

if [[ ! -d "${ROM_SOURCE_DIR}" ]]; then
	echo -e "${ROM_SOURCE_DIR} dosen\'t exist, please sync up in the correct folder and rerun";
	exit 1;
fi

cd "${ROM_SOURCE_DIR}";

if [[ ! -d ".repo" ]]; then
	echo -e ".repo folder not found - not in a properly synced android tree - please sync properly";
	exit 1;
fi

${ROM};


if [[ "$(python --version | awk '{print $2}' | awk -F '.' '{print $1}')" -ne 2 ]];
then
    if [[ "$(command -v 'virtualenv2')" ]]; then
        virtualenv2 "${BASEDIR}/virtualenv";
        source "${BASEDIR}/virtualenv/bin/activate";
    else
        echo "Please install 'virtualenv2', or make 'python' point to python2";
        exit 1;
    fi
fi

source build/envsetup.sh;


lunch "${LUNCH}_${DEVICE}-${VARIANT}"

if [[ "${CLEAN}" == "clean" ]]; then
	make clobber;
fi

if [[ "${NUKECCACHE}" == "true" ]]; then
        ccache -C;
fi

if [[ -z "${MAKE}" ]]; then
	if [[ "$(grep '^bacon:' 'build/core/Makefile')" ]]; then
		MAKE="bacon"
	else
		MAKE="otapackage"
	fi
fi

if [[ -z "${TARGET}" ]]; then
    TARGET="${MAKE}";
fi

if [[ -z "${JOBS}" ]];then
	JOBS="$(nproc --all)";
fi

export USE_CCACHE=1;
export CCACHE_DIR="${BASEDIR}/.ccache-${DEVICE}";
ccache -M 30;

if [[ "${SYNC}" == "sync" ]]; then
    time repo sync -j${JOBS} --current-branch --no-tags --no-clone-bundle --optimized-fetch --prune
fi

if [[ "$(command -v 'mka')" ]]; then
	MAKE="mka ${TARGET}";
else
	MAKE="make -j${JOBS} ${TARGET}";
fi

LOG="${BASEDIR}/logs/${ROM}_${DEVICE}_$(date +%Y%m%d-%H%M).log"

START="$(date +%s)";
eval "${MAKE}" 2>&1 | tee ${LOG}
END="$(date +%s)";

format_time ${END} ${START};


if [[ "${TARGET}" == "bootimage" ]]; then
    OUTPUT="boot.img";
elif [[ "{TARGET"} == "recoveryimage" ]]; then
    OUTPUT="recovery.img";
else
    OUTPUT="${ZIPNAME}";
fi

if [[ "$(ls ${OUT}/${OUTPUT}*)" ]]; then
	echo -e "Build succeeded";
else
	echo -e "Build failed, check ${LOG}";
fi


if [[ -d "${BASEDIR}/virtualenv" ]]; then
    echo -e "virtualenv detected, deactivating!";
    deactivate;
    rm -rf "${BASEDIR}/virtualenv";
fi

echo -e "Stopping jack server";
./prebuilts/sdk/tools/jack-admin stop-server;
