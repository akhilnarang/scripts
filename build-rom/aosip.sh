#!/usr/bin/env bash

# Copyright (C) 2018-19 Akhil Narang
# SPDX-License-Identifier: GPL-3.0-only
# AOSiP Build Script
# shellcheck disable=SC1090,SC1091
# SC1090: Can't follow non-constant source. Use a directive to specify location.
# SC1091: Not following: (error message here)

set -e
source ~/scripts/functions
export TZ=UTC
[[ $QUIET == "no" ]] && sendAOSiP "${START_MESSAGE}";
export PATH=~/bin:$PATH
[[ $QUIET == "no" ]] && sendAOSiP "Starting ${DEVICE} ${AOSIP_BUILDTYPE} build on ${NODE_NAME:?}, check progress [here](${BUILD_URL})!"
rm -fv .repo/local_manifests/*
if [[ "${SYNC}" == "yes" ]]; then
	repo init -u https://github.com/AOSiP/platform_manifest.git -b pie --no-tags --no-clone-bundle --current-branch --repo-url https://github.com/akhilnarang/repo --repo-branch master --no-repo-verify;
	repo forall -j$(nproc) -c "git reset --hard m/pie && git clean -fdx"
	time repo sync -j$(nproc) --current-branch --no-tags --no-clone-bundle --force-sync
fi
set +e
. build/envsetup.sh
lunch aosip_"${DEVICE}"-"${BUILDVARIANT}"
export OVERRIDE_OTA_CHANNEL="https://build.aosip.dev/${DEVICE}-${AOSIP_BUILDTYPE}.json"
set -e
case "${CLEAN}" in
  "clean"|"deviceclean"|"installclean") m -j "${CLEAN}" ;;
  *) rm -rf "${OUT}"/A*
esac
set +e
repopick_stuff
set -e
eval "${COMMAND_TO_RUN}"
export USE_CCACHE=1
export CCACHE_DIR="${HOME}/.ccache"
ccache -M 500G
time m -j kronic || ([[ $QUIET == "no" ]] && sendAOSiP "[Build failed!](${BUILD_URL})")
set +e;
ZIP="$(cout && ls AOSiP*.zip)" || exit 1
[[ $QUIET == "no" ]] && sendAOSiP "Build done, check ${BUILD_URL} for details!"
sendAOSiP "${END_MESSAGE}";
cp -v $OUT/A* /var/www/html/
~/api/generation_json.py $OUT/A*.zip > /var/www/html/${DEVICE}-${AOSIP_BUILDTYPE}.json
rsync -av --progress /var/www/html/ akhil@build.aosip.dev:/var/www/html
url="https://build.aosip.dev/$ZIP"
[[ $QUIET == "no" ]] && sendAOSiP $url
[[ $QUIET == "no" ]] && sendAOSiP $(python3 ~/scripts/gerrit/parsepicks.py "$REPOPICK_LIST")
[[ "${AOSIP_BUILDTYPE}" == "Official" ]] || [[ "${AOSIP_BUILDTYPE}" == "Beta" ]] && curl -s "https://jenkins.akhilnarang.me/job/AOSiP-Mirror/buildWithParameters?token=${TOKEN:?}&DEVICE=$DEVICE&TYPE=direct&LINK=$url" || exit 0

