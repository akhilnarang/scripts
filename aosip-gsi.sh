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
export PATH=~/bin:$PATH
rm -fv .repo/local_manifests/*
wget https://raw.githubusercontent.com/AOSiP-Devices/device_phh_treble/pie/gsi.xml -O .repo/local_manifests/gsi.xml
repo init -u https://github.com/AOSiP/platform_manifest.git -b pie --no-tags --no-clone-bundle --current-branch --repo-url https://github.com/akhilnarang/repo --repo-branch master --no-repo-verify;
repo forall -j$(nproc) -c "git reset --hard m/pie && git clean -fdx"
time repo sync -j$(nproc) --current-branch --no-tags --no-clone-bundle --force-sync
. build/envsetup.sh
export AOSIP_BUILDTYPE=GSI
lunch treble_${ARCH}_${SYSTEMTYPE}vN-userdebug
m -j clean
repopick -t dnm-gsi -f
repopick_stuff
export USE_CCACHE=1
export CCACHE_DIR="${HOME}/.ccache"
ccache -M 500G
time m -j systemimage
set +e;
IMG="$(cout && ls system.img)" || exit 1
case ${SYSTEMTYPE} in
"a") type="aonly";;
"b") type="ab";;
*) type="${SYSTEMTYPE}"
esac
NAME="AOSiP-9.0-GSI-${ARCH}_${type}-$(date +%Y%m%d).img"
cp -v $OUT/system.img /var/www/html/$NAME
sendAOSiP "${ARCH}_${type} GSI build done on $(hostname)!"
url="https://$(hostname)/$NAME"
sendAOSiP $url
if [[ "${RELEASE}" == "yes" ]]; then
    rsync -av --progress $OUT/system.img kronic@illusion.aosip.dev:/mnt/builds/GSI/$NAME
    url="https://get.aosip.dev/GSI/$NAME"
    sendAOSiP $url
else
    sendAOSiP $(python3 ~/scripts/gerrit/parsepicks.py "$REPOPICK_LIST")
    rsync -av --progress $OUT/system.img akhil@illusion.aosip.dev:/var/www/html/
    url="https://build.aosip.dev/$NAME"
    sendAOSiP $url
fi
