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
[[ $QUIET == "no" ]] && sendAOSiP "${START_MESSAGE}";
export PATH=~/bin:$PATH
[[ $QUIET == "no" ]] && sendAOSiP "Starting ${DEVICE} ${AOSIP_BUILDTYPE} build on $(hostname), check progress <a href='${BUILD_URL}'>here</a>!"
rm -fv .repo/local_manifests/*
if [[ "${SYNC}" == "yes" ]]; then
	repo init -u https://github.com/AOSiP/platform_manifest.git -b pie --no-tags --no-clone-bundle --current-branch --repo-url https://github.com/akhilnarang/repo --repo-branch master --no-repo-verify;
	repo forall -j$(nproc) -c "git reset --hard m/pie && git clean -fdx"
	time repo sync -j$(nproc) --current-branch --no-tags --no-clone-bundle --force-sync
fi
set +e
. build/envsetup.sh
lunch aosip_"${DEVICE}"-"${BUILDVARIANT}"
if [[ "${AOSIP_BUILDTYPE}" != "Official" ]] && [[ "${AOSIP_BUILDTYPE}" != "Beta" ]]; then
	export OVERRIDE_OTA_CHANNEL="https://illusion.aosip.dev/${DEVICE}-${AOSIP_BUILDTYPE}.json"
fi
set -e
case "${CLEAN}" in
  "clean"|"deviceclean"|"installclean") m -j "${CLEAN}" ;;
  *) rm -rf "${OUT}"/A*
esac
set +e
repopick_stuff
[[ "${DEVICE}" == "fajita" ]] && repopick -t fod
set -e
eval "${COMMAND_TO_RUN}"
export USE_CCACHE=1
export CCACHE_DIR="${HOME}/.ccache"
ccache -M 500G
[[ "$(hostname)" != "Illusion" ]] && unset USE_CCACHE
time m -j kronic || ([[ $QUIET == "no" ]] && PARSE_MODE=md sendAOSiP "[Build failed for ${DEVICE}](${BUILD_URL})")
set +e;
ZIP="$(cout && ls AOSiP*.zip)" || exit 1
[[ $QUIET == "no" ]] && PARSE_MODE=md sendAOSiP "${DEVICE} build is done, check [jenkins](${BUILD_URL}) for details!"
[[ $QUIET == "no" ]] && sendAOSiP "${END_MESSAGE}";
[[ $QUIET == "no" ]] && [[ $AOSIP_BUILDTYPE != "Official" ]] && [[ $AOSIP_BUILDTYPE != "Beta" ]] && sendAOSiP "$(~/scripts/message_testers.py ${DEVICE})";
cp -v $OUT/A* /var/www/html/
case $AOSIP_BUILDTYPE in
"Official"|"Beta")
	url="https://$(hostname)/$ZIP"
	curl -s "https://jenkins.akhilnarang.me/job/AOSiP-Mirror/buildWithParameters?token=${TOKEN:?}&DEVICE=$DEVICE&TYPE=direct&LINK=$url" || exit 0
;;
*)
	~/api/generate_json.py $OUT/A*.zip > /var/www/html/${DEVICE}-${AOSIP_BUILDTYPE}.json
	if [[ "$(hostname)" != "Illusion" ]]; then
		for f in ${DEVICE}-${AOSIP_BUILDTYPE}.json $ZIP; do
			scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /var/www/html/$f akhil@illusion.aosip.dev:/var/www/html/
		done
		url="https://$(hostname)/$ZIP"
		[[ $QUIET == "no" ]] && sendAOSiP $url
	fi
	url="https://illusion.aosip.dev/$ZIP"
	[[ $QUIET == "no" ]] && sendAOSiP $url
	[[ $QUIET == "no" ]] && [[ -n "$REPOPICK_LIST" ]] && sendAOSiP $(python3 ~/scripts/gerrit/parsepicks.py "$REPOPICK_LIST")
;;
esac
GDRIVE_URL=$(gdrive upload -p 1hhyKQ9yqLg0bIn-QmkPhpMrrc7OuHuNC --share "${OUT}/${ZIP}"  | awk '/https/ {print $7}')
[[ $QUIET == "no" ]] && PARSE_MODE=md sendAOSiP "[$ZIP](${GDRIVE_URL})" || exit 0
