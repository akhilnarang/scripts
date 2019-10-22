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
rm -fv .repo/local_manifests/*
if [[ "${SYNC}" == "yes" ]]; then
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
	export OVERRIDE_OTA_CHANNEL="https://illusion.aosip.dev/${DEVICE}-${AOSIP_BUILDTYPE}.json"
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
	git clone git@github.com:AOSiP-Devices/jenkins
fi
[[ -f "jenkins/${DEVICE}" ]] && REPOPICK_LIST+=" | $(cat jenkins/"${DEVICE}")"
repopick_stuff
set -e
eval "${COMMAND_TO_RUN}"
export USE_CCACHE=1
export CCACHE_DIR="${HOME}/.ccache"
CCACHE_EXEC="$(command -v ccache)"
export CCACHE_EXEC
ccache -M 500G
time m -j kronic || ([[ $QUIET == "no" ]] && PARSE_MODE=md sendAOSiP "[${BRANCH} build failed for ${DEVICE}](${BUILD_URL})")
set +e
ZIP="$(cout && ls AOSiP*.zip)" || exit 1
[[ $QUIET == "no" ]] && PARSE_MODE=md sendAOSiP "${DEVICE} build is done, check [jenkins](${BUILD_URL}) for details!"
[[ $QUIET == "no" ]] && sendAOSiP "${END_MESSAGE}"
[[ $QUIET == "no" ]] && [[ $AOSIP_BUILDTYPE != "Official" ]] && [[ $AOSIP_BUILDTYPE != "Beta" ]] && [[ $AOSIP_BUILDTYPE != "Alpha" ]] && sendAOSiP "$(./jenkins/message_testers.py "${DEVICE}")"
url="https://illusion.aosip.dev/$ZIP"
if [[ "$(hostname)" == "Illusion" ]]; then
	cp -v "$OUT"/A* /var/www/html/
	~/api/generate_json.py "$OUT"/A*.zip >/var/www/html/"${DEVICE}"-"${AOSIP_BUILDTYPE}".json
else
	scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$OUT"/A* akhil@illusion.aosip.dev:/var/www/html/
	~/api/generate_json.py "$OUT"/A*.zip >/tmp/"${DEVICE}"-"${AOSIP_BUILDTYPE}".json
	scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /tmp/"${DEVICE}"-"${AOSIP_BUILDTYPE}".json akhil@illusion.aosip.dev:/var/www/html/
fi
case $AOSIP_BUILDTYPE in
"Official" | "Beta" | "Alpha")
	curl -s "https://jenkins.akhilnarang.me/job/AOSiP-Mirror/buildWithParameters?token=${TOKEN:?}&DEVICE=$DEVICE&TYPE=direct&LINK=$url" || exit 0
	;;
*)
	[[ $QUIET == "no" ]] && sendAOSiP "$url"
	[[ $QUIET == "no" ]] && [[ -n "$REPOPICK_LIST" ]] && sendAOSiP "$(python3 ~/scripts/gerrit/parsepicks.py "$REPOPICK_LIST")"
	;;
esac
GDRIVE_URL=$(gdrive upload -p 1hhyKQ9yqLg0bIn-QmkPhpMrrc7OuHuNC --share "${OUT}/${ZIP}" | awk '/https/ {print $7}')
[[ $QUIET == "no" ]] && PARSE_MODE=md sendAOSiP "[$ZIP](${GDRIVE_URL})" || exit 0
