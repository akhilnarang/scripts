#!/usr/bin/env bash

# shellcheck disable=SC1091,SC2029
# SC1091: Not following: build/envsetup.sh: openBinaryFile: does not exist (No such file or directory)
# SC2029: Note that, unescaped, this expands on the client side

# Repopicks a | delimited set of commits
function repopick_stuff() {
	export oldifs=$IFS
	export IFS="|"
	for f in ${REPOPICK_LIST}; do
		echo "Picking: $f"
		eval repopick "${f}" || return
	done
	export IFS=$oldifs
}

[[ -z "${API_KEY}" ]] && echo "API_KEY not defined, exiting!" && exit 1
function sendTG() {
	curl -s "https://api.telegram.org/bot${API_KEY}/sendmessage" --data "text=${*}&chat_id=-1001185331716&parse_mode=Markdown" >/dev/null
}
rm -fv .repo/local_manifests/*
export days_to_log=${DAY}
source ~/.bashrc
repo sync --force-sync -j64
. build/envsetup.sh
if ! breakfast "${DEVICE:?}"; then
	sendTG "Lunching [$DEVICE]($BUILD_URL) failed on $NODE_NAME"
	exit 1
fi
repopick_stuff
export USE_CCACHE=1
ccache -M 200G
mka "${CLOBBER:?}"
rm -rfv "${OUT}/{RR*,system,vendor}"
sendTG "Starting build for [$DEVICE]($BUILD_URL) on $NODE_NAME"
if ! mka bacon; then
	sendTG "[$DEVICE]($BUILD_URL) Build failed on $NODE_NAME"
	exit 1
fi
cout
ZIP=$(ls RR*.zip)
ssh jenkins@ssh.packet.resurrectionremix.com "rm -rf /home/acar/ua/.hidden/${DEVICE:?}"
ssh jenkins@ssh.packet.resurrectionremix.com "mkdir /home/acar/ua/.hidden/$DEVICE -p"
scp "${ZIP}" "jenkins@ssh.packet.resurrectionremix.com:/home/acar/ua/.hidden/${DEVICE}"/
scp "${DEVICE}".json "jenkins@ssh.packet.resurrectionremix.com:/home/acar/ua/.hidden/${DEVICE}"/
cd - || exit
scp CHANGELOG.mkdn "jenkins@ssh.packet.resurrectionremix.com:/home/acar/ua/.hidden/${DEVICE}/${ZIP/.zip/-changelog.txt}"
DEVICE_C="$(echo "$DEVICE" | tr '[:upper:]' '[:lower:]')"
sendTG "$DEVICE_C build is done on $NODE_NAME. It's private. Test it then publish it."
sendTG "[$ZIP](https://rr.umutcanacar.me/.hidden/$DEVICE/$ZIP)"
sendTG "[Changelog](https://rr.umutcanacar.me/.hidden/$DEVICE/${ZIP/.zip/-changelog.txt})"
