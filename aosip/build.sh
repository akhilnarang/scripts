#!/usr/bin/env bash

# Copyright (C) 2018-20 Akhil Narang
# SPDX-License-Identifier: GPL-3.0-only
# AOSiP build script
# shellcheck disable=SC1090,SC1091,SC2029
# SC1090: Can't follow non-constant source. Use a directive to specify location.
# SC1091: Not following: (error message here)
# SC2029: Note that, unescaped, this expands on the client side.

source ~/scripts/functions

function notify() {
    if [[ ! $AOSIP_BUILDTYPE =~ ^(Official|Gapps)$ ]]; then
        sendAOSiP "$@"
    fi
}

function getAbort() {
    sendAOSiP "Build $BUILD_NUMBER has been aborted"
}

trap 'tag_aborted' SIGTERM

export TZ=UTC

curl --silent --fail --location https://review.aosip.dev > /dev/null || {
    notify "$DEVICE $AOSIP_BUILDTYPE is being aborted because gerrit is down!"
    exit 1
}

# Set some variables based on the buildtype
if [[ $AOSIP_BUILDTYPE =~ ^(Official|Gapps|CI|CI_Gapps|Quiche|Quiche_Gapps|Ravioli|Ravioli_Gapps)$ ]]; then
    TARGET="otatools target-files-package"
    if [[ $AOSIP_BUILDTYPE =~ ^(CI|CI_Gapps|Quiche|Quiche_Gapps|Ravioli|Ravioli_Gapps)$ ]]; then
        export OVERRIDE_OTA_CHANNEL="${BASE_URL}/${DEVICE}-${AOSIP_BUILDTYPE}.json"
    fi
else
    TARGET="kronic"
fi

function repo_init() {
    repo init -u https://github.com/AOSiP/platform_manifest.git -b "$BRANCH" --no-tags --no-clone-bundle --current-branch
}

function repo_sync() {
    time repo sync -j"$(nproc)" --current-branch --no-tags --no-clone-bundle --force-sync --quiet
}

function clean_repo() {
    repo forall --ignore-missing -j"$(nproc)" -c "git reset --quiet --hard m/$BRANCH && git clean -fdxq"
}

set -e
notify "${START_MESSAGE}"
export PATH=~/bin:$PATH
PARSE_MODE="html" notify "Starting ${DEVICE} ${AOSIP_BUILDTYPE} $BRANCH build on $NODE_NAME, check progress <a href='${BUILD_URL}'>here</a>!"

[[ -d "vendor/aosip" ]] || {
    repo_init
    repo_sync
}

. build/envsetup.sh
if [[ ${SYNC} == "yes" ]]; then
    [[ -d ".repo/local_manifests" ]] && rm -rf .repo/local_manifests
    git -C .repo/manifests reset --hard
    clean_repo
    rm -rf .repo/repo .repo/manifests
    repo_init
    if [[ -n ${LOCAL_MANIFEST} ]]; then
        curl --create-dirs -s -L "${LOCAL_MANIFEST}" -o .repo/local_manifests/aosip_manifest.xml
    fi
    if [[ -f "jenkins/${DEVICE}-presync" ]]; then
        if [[ -z $PRE_SYNC_PICKS ]]; then
            PRE_SYNC_PICKS="$(cat jenkins/"${DEVICE}-presync")"
        else
            PRE_SYNC_PICKS+=" | $(cat jenkins/"${DEVICE}-presync")"
        fi
    fi
    if [[ -n ${PRE_SYNC_PICKS} ]]; then
        echo "Trying to pick $PRE_SYNC_PICKS before syncing!"
        REPOPICK_LIST="$PRE_SYNC_PICKS" repopick_stuff || {
            notify "Pre-sync picks failed"
            clean_repo
            exit 1
        }
    fi
    repo_sync
fi

set +e
echo "Lunching $BUILDVARIANT for $DEVICE!"
lunch aosip_"${DEVICE}"-"${BUILDVARIANT}"
if [[ $AOSIP_BUILD != "$DEVICE" ]]; then
    notify "Lunching failed!"
    exit 1
fi
set -e

if [[ ${CLEAN} =~ ^(clean|deviceclean|installclean)$ ]]; then
    m "${CLEAN}"
else
    rm -rf "${OUT}"/AOSiP*
fi

if [[ -f "jenkins/${DEVICE}" ]]; then
    if [[ -z $REPOPICK_LIST ]]; then
        REPOPICK_LIST="$(cat jenkins/"${DEVICE}")"
    else
        REPOPICK_LIST+=" | $(cat jenkins/"${DEVICE}")"
    fi
fi

echo "Trying to pick $REPOPICK_LIST!"
start=$(date +%s)
repopick_stuff || {
    notify "Picks failed"
    clean_repo
    exit 1
}
echo "Took $(($(date +%s) - start)) seconds to pick!"

USE_CCACHE=1
CCACHE_DIR="${HOME}/.ccache"
CCACHE_EXEC="$(command -v ccache)"
export USE_CCACHE CCACHE_DIR CCACHE_EXEC
ccache -M 500G
if ! m "$TARGET"; then
    notify "[$BRANCH build failed for ${DEVICE}](${BUILD_URL})"
    notify "$(./jenkins/tag_maintainer.py "$DEVICE")"
    exit 1
fi

notify "${DEVICE} build is done, check [jenkins](${BUILD_URL}) for details!"
notify "${END_MESSAGE}"

if [[ $TARGET == "kronic" ]]; then
    ZIP="AOSiP-$(get_build_var AOSIP_VERSION).zip"
    [[ -f "$OUT/$ZIP" ]] || ZIP="AOSiP-$(grep ro.aosip.version "$OUT"/system/etc/prop.default | cut -d= -f2).zip"
    cp -v "$OUT/$ZIP" ~/nginx
    ssh Illusion "cd /tmp; axel -n8 -q http://$(hostname)/$ZIP; rclone copy -P $ZIP aosip-jenkins:$BUILD_NUMBER; rm -fv $ZIP"
    rm -fv ~/nginx/"$ZIP"
    FOLDER_LINK="$(ssh Illusion rclone link aosip-jenkins:"$BUILD_NUMBER")"
    notify "Build artifacts for job $BUILD_NUMBER can be found [here]($FOLDER_LINK)"
    notify "$(./jenkins/message_testers.py "${DEVICE}")"
    if [[ -n $REPOPICK_LIST ]]; then
        notify "$(python3 ~/scripts/gerrit/parsepicks.py "${REPOPICK_LIST}")"
    fi
else
    notify "Wait a few minutes for a signed zip to be generated!"
fi
