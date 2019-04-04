#!/usr/bin/env bash

# shellcheck disable=SC1091,SC2029
# SC1091: Not following: build/envsetup.sh: openBinaryFile: does not exist (No such file or directory)
# SC2029: Note that, unescaped, this expands on the client side

[[ -z "${API_KEY}" ]] && echo "API_KEY not defined, exiting!" && exit 1
function sendTG() {
    curl -s "https://api.telegram.org/bot${API_KEY}/sendmessage" --data "text=${*}&chat_id=-1001185331716&parse_mode=Markdown" > /dev/null
}
rm -fv .repo/local_manifests/*
export days_to_log=${DAY}
repo sync --force-sync -j64
. build/envsetup.sh
if ! breakfast "${DEVICE}"; then
	sendTG "Lunching ${DEVICE} failed on $NODE_NAME"
    exit 1
fi
export USE_CCACHE=1 
ccache -M 200G
mka "${CLOBBER:?}"
rm -rfv "${OUT}/{RR*,system,vendor}"
sendTG "Starting build for [$DEVICE]($BUILD_URL) on $NODE_NAME"
if ! mka bacon; then
    sendTG "${DEVICE} Build failed on $NODE_NAME"
    exit 1
fi
cout
ZIP=$(ls RR*.zip)
ssh acar@ssh.packet.resurrectionremix.com "rm -rf ~/ua/.hidden/${DEVICE:?}"
ssh acar@ssh.packet.resurrectionremix.com "mkdir ~/ua/.hidden/$DEVICE -p"
scp "${ZIP}" acar@ssh.packet.resurrectionremix.com:ua/.hidden/"${DEVICE}"/
scp "${DEVICE}".json acar@ssh.packet.resurrectionremix.com:ua/.hidden/"${DEVICE}"/
cd - || exit
scp CHANGELOG.mkdn acar@ssh.packet.resurrectionremix.com:ua/.hidden/"${DEVICE}/${ZIP/.zip/-changelog.txt}"
sendTG "Build is done. It's private. Test it and let us know if we can publish it."
sendTG "[$ZIP](https://rr.umutcanacar.me/.hidden/$DEVICE/$ZIP)"
sendTG "[Changelog](https://rr.umutcanacar.me/.hidden/$DEVICE/${ZIP/.zip/-changelog.txt})"
