#!/usr/bin/env bash

# Copyright (C) 2018-19 Akhil Narang
# SPDX-License-Identifier: GPL-3.0-only
# AOSiP Build Script
# shellcheck disable=SC1090,SC1091
# SC1090: Can't follow non-constant source. Use a directive to specify location.
# SC1091: Not following: (error message here)

export PARSE_MODE="html"

set -e
source ~/scripts/functions
export TZ=UTC
[[ $QUIET == "no" ]] && sendAOSiP "${START_MESSAGE}"
export PATH=~/bin:$PATH
[[ $QUIET == "no" ]] && sendAOSiP "Starting ${DEVICE} ${AOSIP_BUILDTYPE} build on $(hostname), check progress <a href='${BUILD_URL}'>here</a>!"
if [[ "${SYNC}" == "yes" ]]; then
        rm -rf .repo/repo .repo/manifests .repo/local_manifests
	repo init -u https://github.com/AOSiP/platform_manifest.git -b "${BRANCH}" --no-tags --no-clone-bundle --current-branch --repo-url https://github.com/akhilnarang/repo --repo-branch master --no-repo-verify
	repo forall --ignore-missing -j"$(nproc)" -c "git reset --hard m/${BRANCH} && git clean -fdx"
	if [[ -n "${LOCAL_MANIFEST}" ]]; then
		curl --create-dirs -s -L "${LOCAL_MANIFEST}" -o .repo/local_manifests/aosip_manifest.xml
	fi
	time repo sync -j"$(nproc)" --current-branch --no-tags --no-clone-bundle --force-sync
fi
set +e
. build/envsetup.sh
lunch aosip_"${DEVICE}"-"${BUILDVARIANT}"
if [[ "${AOSIP_BUILDTYPE}" != "Official" ]] && [[ "${AOSIP_BUILDTYPE}" != "Beta" ]]; then
	export OVERRIDE_OTA_CHANNEL="https://aosip.dev/direct/${DEVICE}-${AOSIP_BUILDTYPE}.json"
fi
set -e
case "${CLEAN}" in
"clean" | "deviceclean" | "installclean") m -j "${CLEAN}" ;;
*) rm -rf "${OUT}"/A* ;;
esac
set +e
if [[ -d "jenkins" ]]; then
	git -C jenkins pull
else
	git clone https://github.com/AOSiP-Devices/jenkins
fi
if [[ -d "${HOME}/api" ]]; then
	git -C ~/api pull
else
	git clone https://github.com/AOSiP/api ~/api
fi
[[ -f "jenkins/${DEVICE}" ]] && REPOPICK_LIST+=" | $(cat jenkins/"${DEVICE}")"
repopick_stuff || { sendAOSiP "Picks failed"; exit 1; }
set -e
eval "${COMMAND_TO_RUN}"
export USE_CCACHE=1
export CCACHE_DIR="${HOME}/.ccache"
CCACHE_EXEC="$(command -v ccache)"
export CCACHE_EXEC
ccache -M 500G
time m -j kronic || ([[ $QUIET == "no" ]] && PARSE_MODE=md sendAOSiP "[${BRANCH} build failed for ${DEVICE}](${BUILD_URL})" && exit 1)
set +e
[[ $QUIET == "no" ]] && PARSE_MODE=md sendAOSiP "${DEVICE} build is done, check [jenkins](${BUILD_URL}) for details!"
[[ $QUIET == "no" ]] && sendAOSiP "${END_MESSAGE}"
~/api/generate_json.py "$OUT"/A*.zip > "${OUT}"/"${DEVICE}"-"${AOSIP_BUILDTYPE}".json
