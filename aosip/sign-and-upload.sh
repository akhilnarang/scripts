#!/usr/bin/env bash

# Copyright (C) 2018-20 Akhil Narang
# SPDX-License-Identifier: GPL-3.0-only
# AOSiP upload script

if [[ -d "${HOME}/jenkins-scripts" ]]; then
    git -C ~/jenkins-scripts fetch origin master && git -C ~/jenkins-scripts reset --hard origin/master
else
    git clone https://github.com/AOSiP-Devices/jenkins ~/jenkins-scripts
fi

if [[ -d "${HOME}/scripts" ]]; then
    git -C ~/scripts fetch origin master && git -C ~/scripts reset --hard origin/master
else
    git clone https://github.com/akhilnarang/scripts ~/scripts
fi

if [[ -d "${HOME}/api" ]]; then
    git -C ~/api fetch origin master && git -C ~/api reset --hard origin/master
else
    git clone https://github.com/AOSiP/api ~/api
fi

source ~/scripts/functions
rclone copy -P --drive-chunk-size 1024M kronic-sync:jenkins/"${PARAM_BUILD_NUMBER:?}"/ "$PARAM_BUILD_NUMBER" || exit 1

cd "$PARAM_BUILD_NUMBER" || exit 1
SIGNED_OTAPACKAGE="AOSiP-10-$AOSIP_BUILDTYPE-$DEVICE-$(date +%Y%m%d)-signed.zip"
SIGNED_TARGET_FILES="signed-target-files.zip"
SIGNING_FLAGS="-e CronetDynamite.apk= -e DynamiteLoader.apk= -e DynamiteModulesA.apk= -e AdsDynamite.apk= -e DynamiteModulesC.apk= -e MapsDynamite.apk= -e GoogleCertificates.apk= -e AndroidPlatformServices.apk="
cd ~/ten || exit 1
echo "Signing target_files APKs"
# shellcheck disable=SC2086
# SC2086: Double quote to prevent globbing and word splitting
./build/make/tools/releasetools/sign_target_files_apks -o -d ~/.android-certs $SIGNING_FLAGS "$OLDPWD"/aosip_"$DEVICE"-target_files-*.zip "$OLDPWD/$SIGNED_TARGET_FILES" || exit 1
echo "Generating signed otapackage"
./build/make/tools/releasetools/ota_from_target_files -k ~/.android-certs/releasekey --backup=true "$OLDPWD/$SIGNED_TARGET_FILES" "$OLDPWD/$SIGNED_OTAPACKAGE" || exit 1
cd - || exit 1
~/api/generate_json.py "$SIGNED_OTAPACKAGE" > /var/www/html/"${DEVICE}"-"${AOSIP_BUILDTYPE}".json
rclone copy -P --drive-chunk-size 256M "$SIGNED_OTAPACKAGE" kronic-sync:jenkins/"$PARAM_BUILD_NUMBER"
mkdir -pv /var/www/html/"$PARAM_BUILD_NUMBER"
cp -v "$SIGNED_OTAPACKAGE" /var/www/html/"$PARAM_BUILD_NUMBER"
FOLDER_LINK="$(rclone link kronic-sync:jenkins/"$PARAM_BUILD_NUMBER")"
[[ ${QUIET} == "no" ]] && PARSE_MODE="html" sendAOSiP "Build <a href=\"$FOLDER_LINK\">$PARAM_BUILD_NUMBER</a> - $DEVICE $AOSIP_BUILDTYPE"
[[ ${QUIET} == "no" ]] && PARSE_MODE="html" sendAOSiP "<a href=\"https://aosip.dev/dl/$PARAM_BUILD_NUMBER\">$DEVICE $AOSIP_BUILDTYPE</a>"
case $AOSIP_BUILDTYPE in
    "Gapps" | "Official" | "Beta" | "Alpha")
        mkdir -pv /mnt/builds/"$DEVICE"
        cp -v "$SIGNED_OTAPACKAGE" /mnt/builds/"$DEVICE"
        cp -v boot.img /mnt/builds/"$DEVICE"/AOSiP-10-"$AOSIP_BUILDTYPE"-"$DEVICE"-"$(date +%Y%m%d)"-boot.img
        cd /mnt/builds/"$DEVICE" || exit
        md5sum "$SIGNED_OTAPACKAGE" > "$SIGNED_OTAPACKAGE".md5sum
        python3 ~/api/post_device.py "${DEVICE}" "${AOSIP_BUILDTYPE}"
        ;;
    *)
        [[ ${QUIET} == "no" ]] && PARSE_MODE=html sendAOSiP "$(~/jenkins-scripts/message_testers.py "${DEVICE}")"
        [[ ${QUIET} == "no" ]] && [[ -n $REPOPICK_LIST ]] && sendAOSiP "$(python3 ~/scripts/gerrit/parsepicks.py "${REPOPICK_LIST}")"
        ;;
esac
