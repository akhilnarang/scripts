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

if [[ -d "${HOME}/platform_build_make"]]; then
    git -C ~/platform_build_make fetch origin ten && git -C ~/platform_build_make reset --hard origin/ten
else
    git clone https://github.com/AOSiP/platform_build_make ~/platform_build_make
fi


source ~/scripts/functions
rclone copy -P --drive-chunk-size 1024M kronic-sync:jenkins/$PARAM_JOB_NUMBER $PARAM_JOB_NUMBER || exit 1

cd $PARAM_JOB_NUMBER || exit 1
mv $DEVICE-$AOSIP_BUILDTYPE.json /var/www/html/
SIGNING_FLAGS="-e CronetDynamite.apk= -e DynamiteLoader.apk= -e DynamiteModulesA.apk= -e AdsDynamite.apk= -e DynamiteModulesC.apk= -e MapsDynamite.apk= -e GoogleCertificates.apk= -e AndroidPlatformServices.apk="
$HOME/platform_build_make/tools/releasetools/sign_target_files_apks -o -d ~/.android-certs *-target_files-*.zip signed-target-files.zip
$HOME/platform_build_make/tools/releasetools/ota_from_target_files -k ~/.android-certs/releasekey --backup=true signed-target-files.zip AOSiP-10-$AOSIP_BUILDTYPE-$DEVICE-$(date +%Y%m%d)-signed.zip
rclone copy -P --drive-chunk-size 256M AOSiP-10-$AOSIP_BUILDTYPE-$DEVICE-$(date +%Y%m%d)-signed.zip kronic-sync:jenkins/$PARAM_JOB_NUMBER
FOLDER_LINK="$(rclone link kronic-sync:jenkins/$PARAM_JOB_NUMBER)"
[[ "${QUIET}" == "no" ]] && sendAOSiP "Build [$PARAM_JOB_NUMBER]($FOLDER_LINK)"
case $AOSIP_BUILDTYPE in
"Gapps" | "Official" | "Beta" | "Alpha")
	mkdir -pv /mnt/builds/$DEVICE
	cp -v AOSiP-10-$AOSIP_BUILDTYPE-$DEVICE-$(date +%Y%m%d)-signed.zip /mnt/builds/$DEVICE
	cp -v boot.img /mnt/builds/$DEVICE/AOSiP-10-$AOSIP_BUILDTYPE-$DEVICE-$(date +%Y%m%d)-boot.img
	cd /mnt/builds/$DEVICE
	md5sum AOSiP-10-$AOSIP_BUILDTYPE-$DEVICE-$(date +%Y%m%d)-signed.zip > AOSiP-10-$AOSIP_BUILDTYPE-$DEVICE-$(date +%Y%m%d)-signed.zip.md5sum
	python3 ~/api/post_device.py "${DEVICE}" "${AOSIP_BUILDTYPE}"
	;;
*)
	[[ "${QUIET}" == "no" ]] && PARSE_MODE=html sendAOSiP "$(~/jenkins-scripts/message_testers.py ${DEVICE})"
	[[ "${QUIET}" == "no" ]] && [[ -n "$REPOPICK_LIST" ]] && sendAOSiP $(python3 ~/scripts/gerrit/parsepicks.py "${REPOPICK_LIST}")
	;;
esac
