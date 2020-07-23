#!/usr/bin/env bash

# Copyright (C) 2018-20 Akhil Narang
# SPDX-License-Identifier: GPL-3.0-only
# AOSiP upload script


source ~/scripts/functions
export TZ=UTC
AOSIP_VERSION="AOSiP-10-${AOSIP_BUILDTYPE}-${DEVICE}-$(date +%Y%m%d)"
SIGNED_OTAPACKAGE="${AOSIP_VERSION}.zip"
BOOTIMAGE="${AOSIP_VERSION}-boot.img"
SIGNED_TARGET_FILES="signed-target_files.zip"
SIGNED_IMAGE_PACKAGE="${AOSIP_VERSION}-img.zip"
OUT="./out/target/product/$DEVICE"
UPLOAD="./upload_assets"
mkdir -pv "$UPLOAD"

if [[ "$WITH_GAPPS" == "true" ]]; then
    SIGNING_FLAGS="-e CronetDynamite.apk= -e DynamiteLoader.apk= -e DynamiteModulesA.apk= -e AdsDynamite.apk= -e DynamiteModulesC.apk= -e MapsDynamite.apk= -e GoogleCertificates.apk= -e AndroidPlatformServices.apk="
fi

echo "Signing target_files APKs"
# shellcheck disable=SC2086
# SC2086: Double quote to prevent globbing and word splitting
./build/make/tools/releasetools/sign_target_files_apks -o -d ~/.android-certs $SIGNING_FLAGS "$OUT"/obj/PACKAGING/target_files_intermediates/aosip_"$DEVICE"-target_files-"$BUILD_NUMBER".zip "$UPLOAD/$SIGNED_TARGET_FILES" || exit 1

echo "Generating signed otapackage"
./build/make/tools/releasetools/ota_from_target_files -k ~/.android-certs/releasekey --backup=true "$UPLOAD/$SIGNED_TARGET_FILES" "$UPLOAD/$SIGNED_OTAPACKAGE" || exit 1

echo "Generating signed images package"
./build/make/tools/releasetools/img_from_target_files "$UPLOAD/$SIGNED_TARGET_FILES" "$UPLOAD/$SIGNED_IMAGE_PACKAGE" || exit 1

echo "Extracting build.prop to get build timestamp"
BUILD_TIMESTAMP=$(grep -oP "(?<=ro.build.date.utc=).*" "$OUT"/system/build.prop)

echo "Generating JSON for updater"
~/api/generate_json.py "$UPLOAD/$SIGNED_OTAPACKAGE" "$BUILD_TIMESTAMP" > "${DEVICE}"-"${AOSIP_BUILDTYPE}".json

echo "Extracting signed bootimage"
7z e "$UPLOAD/$SIGNED_TARGET_FILES" IMAGES/boot.img -so > "$UPLOAD/$BOOTIMAGE"

echo "Generating MD5 checksums"
md5sum "$UPLOAD/$SIGNED_OTAPACKAGE" > "$UPLOAD/$SIGNED_OTAPACKAGE".md5sum
md5sum "$UPLOAD/$SIGNED_IMAGE_PACKAGE" > "$UPLOAD/$SIGNED_IMAGE_PACKAGE".md5sum

# Upload everything to gdrive
rclone copy -P --drive-chunk-size 256M "$UPLOAD/" kronic-sync:jenkins/"$BUILD_NUMBER"

# This doesn't have any further use
rm -fv "$UPLOAD/$SIGNED_TARGET_FILES"

if [[ "$AOSIP_BUILDTYPE" =~ ^(CI|CI_Gapps|Quiche|Quiche_Gapps)$ ]]; then
    rsync -av --progress "$DEVICE-$AOSIP_BUILDTYPE".json Illusion:/var/www/html/
    rsync -av --progress "$UPLOAD"/*.zip Illusion:/var/www/html/"$BUILD_NUMBER"
    FOLDER_LINK="$(rclone link kronic-sync:jenkins/"$BUILD_NUMBER")"
    export PARSE_MODE="html"
    sendAOSiP "Build <a href=\"$FOLDER_LINK\">$BUILD_NUMBER</a> - $DEVICE $AOSIP_BUILDTYPE"
    sendAOSiP "<a href=\"https://aosip.dev/dl/$BUILD_NUMBER/$SIGNED_OTAPACKAGE\">Direct link</a> for $DEVICE $AOSIP_BUILDTYPE"
    sendAOSiP "$(./jenkins/message_testers.py "${DEVICE}")"
    if [[ -n $REPOPICK_LIST ]]; then
        sendAOSiP "$(python3 ~/scripts/gerrit/parsepicks.py "${REPOPICK_LIST}")"
    fi
elif [[ "$AOSIP_BUILDTYPE" =~ ^(Official|Gapps)$ ]]; then
    rsync -av --progress "$UPLOAD"/* Illusion:/mnt/builds/"$DEVICE"/
    python3 ~/api/post_device.py "$DEVICE" "$AOSIP_BUILDTYPE"
fi

rm -rfv "$DEVICE-$AOSIP_BUILDTYPE".json "$UPLOAD"
