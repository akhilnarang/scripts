#!/usr/bin/env bash

# Copyright (C) 2018-20 Akhil Narang
# SPDX-License-Identifier: GPL-3.0-only
# AOSiP build script
# shellcheck disable=SC1090,SC1091,SC2029
# SC1090: Can't follow non-constant source. Use a directive to specify location.
# SC1091: Not following: (error message here)
# SC2029: Note that, unescaped, this expands on the client side.

source ~/scripts/functions

function sendTG() {
    if [[ ! $AOSIP_BUILDTYPE =~ ^(Official|Gapps)$ ]]; then
        sendAOSiP "$@"
    fi
}

export TZ=UTC

case "${BRANCH}" in
    "ten")
        VERSION=10
        ;;
    "eleven")
        VERSION=11
        ;;
esac

curl --silent --fail --location review.aosip.dev > /dev/null || {
    sendTG "$DEVICE $AOSIP_BUILDTYPE is being aborted because gerrit is down!"
    exit 1
}

# Set some variables based on the buildtype
if [[ $AOSIP_BUILDTYPE =~ ^(Official|Gapps|CI|CI_Gapps|Quiche|Quiche_Gapps|Ravioli|Ravioli_Gapps)$ ]]; then
    TARGET="dist"
    if [[ $AOSIP_BUILDTYPE =~ ^(CI|CI_Gapps|Quiche|Quiche_Gapps|Ravioli|Ravioli_Gapps)$ ]]; then
        export OVERRIDE_OTA_CHANNEL="${BASE_URL}/${DEVICE}-${AOSIP_BUILDTYPE}.json"
    fi
else
    TARGET="kronic"
    ZIP="AOSiP-$VERSION-$AOSIP_BUILDTYPE-$DEVICE-$(date +%Y%m%d).zip"
fi

function repo_init() {
    repo init -u https://github.com/AOSiP/platform_manifest.git -b "$BRANCH" --no-tags --no-clone-bundle --current-branch
}

function repo_sync() {
    time repo sync -j"$(nproc)" --current-branch --no-tags --no-clone-bundle --force-sync
}

function clean_repo() {
    repo forall --ignore-missing -j"$(nproc)" -c "git reset --hard m/$BRANCH && git clean -fdx"
}

set -e
sendTG "${START_MESSAGE}"
export PATH=~/bin:$PATH
PARSE_MODE="html" sendTG "Starting ${DEVICE} ${AOSIP_BUILDTYPE} $BRANCH build on $NODE_NAME, check progress <a href='${BUILD_URL}'>here</a>!"

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
        REPOPICK_LIST="$PRE_SYNC_PICKS" repopick_stuff || {
            sendTG "Pre-sync picks failed"
            clean_repo
            exit 1
        }
    fi
    repo_sync
fi

set +e
lunch aosip_"${DEVICE}"-"${BUILDVARIANT}"
if [[ $AOSIP_BUILD != "$DEVICE" ]]; then
    sendTG "Lunching failed!"
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
repopick_stuff || {
    sendTG "Picks failed"
    clean_repo
    exit 1
}

set -e
USE_CCACHE=1
CCACHE_DIR="${HOME}/.ccache"
CCACHE_EXEC="$(command -v ccache)"
export USE_CCACHE CCACHE_DIR CCACHE_EXEC
ccache -M 500G
if ! m "$TARGET"; then
    sendTG "[$BRANCH build failed for ${DEVICE}](${BUILD_URL})"
    sendTG "$(./jenkins/tag_maintainer.py "$DEVICE")"
    exit 1
fi

sendTG "${DEVICE} build is done, check [jenkins](${BUILD_URL}) for details!"
sendTG "${END_MESSAGE}"

if [[ $TARGET == "kronic" ]]; then
    cp -v "$OUT/$ZIP" ~/nginx
    ssh Illusion "cd /tmp; axel -n16 -q http://$(hostname)/$ZIP; rclone copy -P $ZIP kronic-sync:jenkins/$BUILD_NUMBER; rm -fv $ZIP"
    rm -fv ~/nginx/"$ZIP"
    FOLDER_LINK="$(ssh Illusion rclone link kronic-sync:jenkins/"$BUILD_NUMBER")"
    sendTG "Build artifacts for job $BUILD_NUMBER can be found [here]($FOLDER_LINK)"
    sendTG "$(./jenkins/message_testers.py "${DEVICE}")"
    if [[ -n $REPOPICK_LIST ]]; then
        sendTG "$(python3 ~/scripts/gerrit/parsepicks.py "${REPOPICK_LIST}")"
    fi
else
    sendTG "Wait a few minutes for a signed zip to be generated!"
fi
