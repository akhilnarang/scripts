#!/usr/bin/env bash

# Copyright (C) 2018-20 Akhil Narang
# SPDX-License-Identifier: GPL-3.0-only
# AOSiP build script
# shellcheck disable=SC1090,SC1091
# SC1090: Can't follow non-constant source. Use a directive to specify location.
# SC1091: Not following: (error message here)

function repo_init() {
    repo init -u https://github.com/AOSiP/platform_manifest.git -b ten --no-tags --no-clone-bundle --current-branch
}

function repo_sync() {
    time repo sync -j"$(nproc)" --current-branch --no-tags --no-clone-bundle --force-sync
}

set -e
source ~/scripts/functions
export TZ=UTC
[[ $QUIET == "no" ]] && sendAOSiP "${START_MESSAGE}"
export PATH=~/bin:$PATH
[[ $QUIET == "no" ]] && PARSE_MODE="html" sendAOSiP "Starting ${DEVICE} ${AOSIP_BUILDTYPE} build on $NODE_NAME, check progress <a href='${BUILD_URL}'>here</a>!"
if [[ -d "jenkins" ]]; then
    git -C jenkins pull
else
    git clone https://github.com/AOSiP-Devices/jenkins
fi

[[ -d "vendor/aosip" ]] || {
    repo_init
    repo_sync
}

. build/envsetup.sh
if [[ ${SYNC} == "yes" ]]; then
    rm -rf .repo/repo .repo/manifests
    repo_init
    repo forall --ignore-missing -j"$(nproc)" -c "git reset --hard m/ten && git clean -fdx"
    rm -rf .repo/local_manifests
    if [[ -n ${LOCAL_MANIFEST} ]]; then
        curl --create-dirs -s -L "${LOCAL_MANIFEST}" -o .repo/local_manifests/aosip_manifest.xml
    fi
    if [[ -f "jenkins/${DEVICE}-presync" ]]; then
        if [[ -z "$PRE_SYNC_PICKS" ]]; then
            PRE_SYNC_PICKS="$(cat jenkins/"${DEVICE}-presync")"
        else
            PRE_SYNC_PICKS+=" | $(cat jenkins/"${DEVICE}-presync")"
        fi
    fi
    if [[ -n ${PRE_SYNC_PICKS} ]]; then
        REPOPICK_LIST="$PRE_SYNC_PICKS" repopick_stuff || {
            sendAOSiP "Pre-sync picks failed"
            exit 1
        }
    fi
    repo_sync
fi
set +e
lunch aosip_"${DEVICE}"-"${BUILDVARIANT}"
if [[ ${AOSIP_BUILDTYPE} != "Official" ]] && [[ ${AOSIP_BUILDTYPE} != "Beta" ]] && [[ ${AOSIP_BUILDTYPE} != "Alpha" ]] && [[ ${AOSIP_BUILDTYPE} != "Gapps" ]]; then
    export OVERRIDE_OTA_CHANNEL="${BASE_URL}/${DEVICE}-${AOSIP_BUILDTYPE}.json"
fi
set -e
case "${CLEAN}" in
    "clean" | "deviceclean" | "installclean") m "${CLEAN}" ;;
    *) rm -rf "${OUT}"/AOSiP* ;;
esac
set +e

if [[ -f "jenkins/${DEVICE}" ]]; then
    if [[ -z "$REPOPICK_LIST" ]]; then
        REPOPICK_LIST="$(cat jenkins/"${DEVICE}")"
    else
        REPOPICK_LIST+=" | $(cat jenkins/"${DEVICE}")"
    fi
fi
repopick_stuff || {
    sendAOSiP "Picks failed"
    exit 1
}
set -e
USE_CCACHE=1
CCACHE_DIR="${HOME}/.ccache"
CCACHE_EXEC="$(command -v ccache)"
export USE_CCACHE CCACHE_DIR CCACHE_EXEC
ccache -M 500G
time m kronic || ([[ $QUIET == "no" ]] && sendAOSiP "[ten build failed for ${DEVICE}](${BUILD_URL})" && exit 1)
set +e
[[ $QUIET == "no" ]] && sendAOSiP "${DEVICE} build is done, check [jenkins](${BUILD_URL}) for details!"
[[ $QUIET == "no" ]] && sendAOSiP "${END_MESSAGE}"
cd "$OUT"
mkdir /tmp/"$BUILD_NUMBER" -v
for f in system/build.prop *.img *.zip obj/PACKAGING/target_files_intermediates/*.zip; do cp "$f" /tmp/"$BUILD_NUMBER"; done
rclone copy -P --drive-chunk-size 1024M /tmp/"$BUILD_NUMBER" kronic-sync:jenkins/"$BUILD_NUMBER"
rm -rf /tmp/"$BUILD_NUMBER"
FOLDER_LINK="$(rclone link kronic-sync:jenkins/"$BUILD_NUMBER")"
sendAOSiP "Build artifacts for job $BUILD_NUMBER can be found [here]($FOLDER_LINK)"
