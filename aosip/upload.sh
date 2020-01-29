#!/usr/bin/env bash

# Copyright (C) 2018-20 Akhil Narang
# SPDX-License-Identifier: GPL-3.0-only
# AOSiP upload script

if [[ -d "${HOME}/jenkins-scripts" ]]; then
	git -C ~/jenkins-scripts pull
else
	git clone https://github.com/AOSiP-Devices/jenkins ~/jenkins-scripts
fi

if [[ -d "${HOME}/scripts" ]]; then
    git -C ~/scripts pull
else
    git clone https://github.com/akhilnarang/scripts ~/scripts
fi

source ~/scripts/functions
cd /var/www/html/$FOLDER
mv $DEVICE-$AOSIP_BUILDTYPE.json ../
VERSION=10
[[ "$BRANCH" == "pie" ]] && VERSION=9.0
ZIP=$(ls AOSiP-$VERSION-$AOSIP_BUILDTYPE-$DEVICE-*.zip | tail -1)
[[ "${QUIET}" == "no" ]] && sendAOSiP "[$ZIP]($BASE_URL/$FOLDER/$ZIP)"
[[ "${QUIET}" == "no" ]] && sendAOSiP "[GDrive]($BUILD_URL) incoming"
GDRIVE_URL=$(gdrive upload -p $PARENT_FOLDER --share "${ZIP}" | awk '/https/ {print $7}')
[[ "${QUIET}" == "no" ]] && sendAOSiP "[Google Drive]($GDRIVE_URL)"
url="https://$BASE_URL/$FOLDER/$ZIP"
case $AOSIP_BUILDTYPE in
"Official" | "Beta" | "Alpha")
	curl -s "http://0.0.0.0:8080/job/AOSiP-Mirror/buildWithParameters?token=${TOKEN:?}&DEVICE=$DEVICE&TYPE=direct&LINK=$url" || exit 0
	;;
*)
	[[ "${QUIET}" == "no" ]] && PARSE_MODE=html sendAOSiP "$(~/jenkins-scripts/message_testers.py ${DEVICE})"
	[[ "${QUIET}" == "no" ]] && [[ -n "$REPOPICK_LIST" ]] && sendAOSiP $(python3 ~/scripts/gerrit/parsepicks.py "${REPOPICK_LIST}")
	;;
esac
