#!/usr/bin/env bash

# Copyright (C) 2018-20 Akhil Narang
# SPDX-License-Identifier: GPL-3.0-only
# AOSiP upload script

# shellcheck disable=SC2086,SC2029
# SC2086: Double quote to prevent globbing and word splitting
# SC2029: Note that, unescaped, this expands on the client side.

case "${BRANCH}" in
    "ten")
        VERSION=10
        ;;
    "eleven")
        VERSION=11
        ;;
esac

source ~/scripts/functions

function notify() {
    if [[ ! $AOSIP_BUILDTYPE =~ ^(Official|Gapps)$ ]]; then
        sendAOSiP "$@"
    fi
}

export TZ=UTC
DATE="$(date +%Y%m%d)"
AOSIP_VERSION="AOSiP-${VERSION}-${AOSIP_BUILDTYPE}-${DEVICE}-${DATE}"
SIGNED_OTAPACKAGE="${AOSIP_VERSION}.zip"
BOOTIMAGE="${AOSIP_VERSION}-boot.img"
RECOVERYIMAGE="${AOSIP_VERSION}-recovery.img"
SIGNED_TARGET_FILES="signed-target_files.zip"
SIGNED_IMAGE_PACKAGE="${AOSIP_VERSION}-img.zip"
OUT="./out/target/product/$DEVICE"
UPLOAD="./upload_assets"
UPDATER_JSON="$DEVICE-$AOSIP_BUILDTYPE".json
mkdir -pv "$UPLOAD"
BACKUPTOOL="--backup=true"
if [[ $WITH_GAPPS == "true" ]]; then
    SIGNING_FLAGS="-e CronetDynamite.apk= -e DynamiteLoader.apk= -e DynamiteModulesA.apk= -e AdsDynamite.apk= -e DynamiteModulesC.apk= -e MapsDynamite.apk= -e GoogleCertificates.apk= -e AndroidPlatformServices.apk="
    BACKUPTOOL="--backup=false"
fi

echo "Signing target_files APKs"
python2 ./build/make/tools/releasetools/sign_target_files_apks -p out/host/linux-x86/ -o -d ~/.android-certs $SIGNING_FLAGS "$OUT"/obj/PACKAGING/target_files_intermediates/aosip_"$DEVICE"-target_files-"$BUILD_NUMBER".zip "$UPLOAD/$SIGNED_TARGET_FILES" || exit 1

echo "Generating signed otapackage"
python2 ./build/make/tools/releasetools/ota_from_target_files -p out/host/linux-x86/ -k ~/.android-certs/releasekey "$BACKUPTOOL" "$UPLOAD/$SIGNED_TARGET_FILES" "$UPLOAD/$SIGNED_OTAPACKAGE" || exit 1

echo "Generating signed images package"
python2 ./build/make/tools/releasetools/img_from_target_files -p out/soong/host/linux-x86/ "$UPLOAD/$SIGNED_TARGET_FILES" "$UPLOAD/$SIGNED_IMAGE_PACKAGE" || exit 1

echo "Extracting build.prop to get build timestamp"
BUILD_TIMESTAMP=$(grep -oP "(?<=ro.build.date.utc=).*" "$OUT"/system/build.prop)

echo "Generating JSON for updater"
~/api/generate_json.py "$UPLOAD/$SIGNED_OTAPACKAGE" "$BUILD_TIMESTAMP" > "$UPDATER_JSON"

echo "Extracting signed boot image"
7z e "$UPLOAD/$SIGNED_TARGET_FILES" IMAGES/boot.img -so > "$UPLOAD/$BOOTIMAGE"

echo "Extracting signed recovery image"
7z e "$UPLOAD/$SIGNED_TARGET_FILES" IMAGES/recovery.img -so > "$UPLOAD/$RECOVERYIMAGE"

echo "Generating MD5 checksums"
md5sum "$UPLOAD/$SIGNED_OTAPACKAGE" > "$UPLOAD/$SIGNED_OTAPACKAGE".md5sum
md5sum "$UPLOAD/$SIGNED_IMAGE_PACKAGE" > "$UPLOAD/$SIGNED_IMAGE_PACKAGE".md5sum

# Create an archive out of everything
cd $UPLOAD || exit
tar -cvf ~/nginx/"$BUILD_NUMBER".tar AOSiP*
cd - || exit
rm -rfv $UPLOAD

# Mirror the archive
ssh Illusion "mkdir /tmp/$BUILD_NUMBER; curl -Ls https://$(hostname)/$BUILD_NUMBER.tar | tar xv -C /tmp/$BUILD_NUMBER; rclone copy -P --drive-chunk-size 256M /tmp/$BUILD_NUMBER/ aosip-jenkins:$BUILD_NUMBER"
rm -fv ~/nginx/$BUILD_NUMBER.tar

if [[ $AOSIP_BUILDTYPE =~ ^(CI|CI_Gapps|Quiche|Quiche_Gapps|Ravioli|Ravioli_Gapps)$ ]]; then
    ssh Illusion "rm -rfv /tmp/$BUILD_NUMBER"
    scp "$UPDATER_JSON" Illusion:/tmp/
    ssh Illusion "rclone copy /tmp/$UPDATER_JSON aosip-jenkins:; rm -fv /tmp/$UPDATER_JSON"
    FOLDER_LINK="$(ssh Illusion rclone link aosip-jenkins:"$BUILD_NUMBER")"
    export PARSE_MODE="html"
    notify "Build <a href=\"$FOLDER_LINK\">$BUILD_NUMBER</a> - $DEVICE $AOSIP_BUILDTYPE"
    notify "<a href=\"$BASE_URL/$BUILD_NUMBER/$SIGNED_OTAPACKAGE\">Direct link</a> for $DEVICE $AOSIP_BUILDTYPE"
    notify "$(./jenkins/message_testers.py "${DEVICE}")"
    if [[ -n $REPOPICK_LIST ]]; then
        notify "$(python3 ~/scripts/gerrit/parsepicks.py "${REPOPICK_LIST}")"
    fi
elif [[ $AOSIP_BUILDTYPE =~ ^(Official|Gapps)$ ]]; then
    ssh Illusion "bash ~/scripts/aosip/release.sh $DEVICE $BUILD_NUMBER $AOSIP_BUILDTYPE"
    python3 ~/api/post_device.py "$DEVICE" "$AOSIP_BUILDTYPE"
fi
rm -fv "$DEVICE-$AOSIP_BUILDTYPE".json
