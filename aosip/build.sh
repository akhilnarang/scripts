#!/usr/bin/env bash

# Copyright (C) 2018-20 Akhil Narang
# SPDX-License-Identifier: GPL-3.0-only
# AOSiP build script
# shellcheck disable=SC1090,SC1091,SC2029
# SC1090: Can't follow non-constant source. Use a directive to specify location.
# SC1091: Not following: (error message here)
# SC2029: Note that, unescaped, this expands on the client side.

# Set some variables based on the buildtype
if [[ "$AOSIP_BUILDTYPE" =~ ^(Official|Gapps|CI|CI_Gapps|Quiche|Quiche_Gapps)$ ]]; then
    TARGET="dist"
    if [[ "$AOSIP_BUILDTYPE" =~ ^(CI|CI_Gapps|Quiche|Quiche_Gapps)$ ]]; then
        export OVERRIDE_OTA_CHANNEL="${BASE_URL}/${DEVICE}-${AOSIP_BUILDTYPE}.json"
    fi
else
    TARGET="kronic"
    ZIP="AOSiP-10-$AOSIP_BUILDTYPE-$DEVICE-$(date +%Y%m%d).zip"
fi

function repo_init() {
    repo init -u https://github.com/AOSiP/platform_manifest.git -b ten --no-tags --no-clone-bundle --current-branch
}

function repo_sync() {
    time repo sync -j"$(nproc)" --current-branch --no-tags --no-clone-bundle --force-sync
}

function clean_repo() {
    repo forall --ignore-missing -j"$(nproc)" -c "git reset --hard m/ten && git clean -fdx"
}

set -e
source ~/scripts/functions
export TZ=UTC
sendAOSiP "${START_MESSAGE}"
export PATH=~/bin:$PATH
PARSE_MODE="html" sendAOSiP "Starting ${DEVICE} ${AOSIP_BUILDTYPE} build on $NODE_NAME, check progress <a href='${BUILD_URL}'>here</a>!"


[[ -d "vendor/aosip" ]] || {
    repo_init
    repo_sync
}

. build/envsetup.sh
if [[ ${SYNC} == "yes" ]]; then
    clean_repo
    rm -rf .repo/repo .repo/manifests
    repo_init
    [[ -d ".repo/local_manifests" ]] && rm -rf .repo/local_manifests
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
if [[ "$AOSIP_BUILD" != "$DEVICE" ]]; then
    sendAOSiP "Lunching failed!"
    exit 1
fi
set -e

if [[ "${CLEAN}" =~ ^(clean|deviceclean|installclean)$ ]]; then
    m "${CLEAN}"
else
    rm -rf "${OUT}"/AOSiP*
fi

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
if ! m "$TARGET"; then
    sendAOSiP "[ten build failed for ${DEVICE}](${BUILD_URL})"
    sendAOSiP "$(./jenkins/tag_maintainer.py "$DEVICE")"
    exit 1
fi

sendAOSiP "${DEVICE} build is done, check [jenkins](${BUILD_URL}) for details!"
sendAOSiP "${END_MESSAGE}"

if [[ "$TARGET" == "kronic" ]]; then
    cp "$OUT/$ZIP" ~/nginx
    ssh Illusion "axel -a -n16 -q http://$(hostname)/$ZIP -O /tmp/$ZIP; rclone copy -P --drive-chunk-size 256M /tmp/$ZIP kronic-sync:jenkins/$BUILD_NUMBER/; rm -rfv /tmp/$ZIP"
    rm -fv ~/nginx/"$ZIP"
    FOLDER_LINK="$(rclone link kronic-sync:jenkins/"$BUILD_NUMBER")"
    sendAOSiP "Build artifacts for job $BUILD_NUMBER can be found [here]($FOLDER_LINK)"
    sendAOSiP "$(./jenkins/message_testers.py "${DEVICE}")"
    if [[ -n $REPOPICK_LIST ]]; then
        sendAOSiP "$(python3 ~/scripts/gerrit/parsepicks.py "${REPOPICK_LIST}")"
    fi
else
    sendAOSiP "Wait a few minutes for a signed zip to be generated!"
fi
