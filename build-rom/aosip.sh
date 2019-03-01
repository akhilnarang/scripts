#!/usr/bin/env bash

# Copyright (C) 2018-2019 Akhil Narang
# SPDX-License-Identifier: GPL-3.0-only
# AOSiP Build Script
# shellcheck disable=SC1090,SC1091,SC2076
# SC1090: Can't follow non-constant source. Use a directive to specify location.
# SC1091: Not following: (error message here)
# SC2076: Don't quote right-hand side of =~, it'll match literally rather than as a regex.

set -e
source ~/scripts/functions
sendAOSiP "${START_MESSAGE}";
export PATH=~/bin:$PATH
sendAOSiP "Starting ${DEVICE} ${AOSIP_BUILDTYPE} build on ${node:?}, check progress [here](${BUILD_URL})!"
if [[ "${SYNC}" == "yes" ]]; then
	repo init -u https://github.com/AOSiP/platform_manifest.git -b pie --no-tags --no-clone-bundle --current-branch --repo-url https://github.com/akhilnarang/repo --repo-branch master --no-repo-verify;
	time repo sync -j32 --current-branch --no-tags --no-clone-bundle --force-sync
fi
set +e
rm -fv .repo/local_manifests/*
. build/envsetup.sh
lunch aosip_"${DEVICE}"-"${BUILDVARIANT}"
set -e
case "${CLEAN}" in
  "clean"|"deviceclean"|"installclean") m -j "${CLEAN}" ;;
  *) rm -rf "${OUT}"/A*
esac
repopick_stuff
eval "${COMMAND_TO_RUN}"
export USE_CCACHE=1
export CCACHE_DIR="${HOME}/.ccache"
ccache -M 200G
time m -j kronic || sendAOSiP "[Build failed!](${BUILD_URL})"
set +e;
ZIP="$(cout && ls AOSiP*.zip)" || exit 1
sendAOSiP "Build done, check ${BUILD_URL} for details!"
while [[ ! "$url" =~ "https://drive.google.com" ]]; do
	url="$(gdrive upload -p 1hhyKQ9yqLg0bIn-QmkPhpMrrc7OuHuNC "${OUT}"/"${ZIP}" --share | tail -1 | awk '{ print $NF }')"
done
MD5="$(md5sum "${OUT}"/"${ZIP}" | awk '{print $1}')"
SIZE="$(du -sh "${OUT}"/"${ZIP}" | awk '{print $1}')"
sendAOSiP "
[$ZIP]($url)
Size: $SIZE
MD5: \`$MD5\`
"
sendAOSiP "${END_MESSAGE}";
