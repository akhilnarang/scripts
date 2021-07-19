#!/usr/bin/env bash

# shellcheck disable=SC2086
# SC2086: Double quote to prevent globbing and word splitting.

DEVICE=$1
BUILD_NUMBER=$2
AOSIP_BUILDTYPE=$3

pushd /tmp/"$BUILD_NUMBER" || exit

if [[ -d "/home/kronic/builds/$DEVICE" ]]; then
    rm -fv /home/kronic/builds/"$DEVICE"/*"$AOSIP_BUILDTYPE"*
else
    mkdir -pv "/home/kronic/builds/$DEVICE"
fi
cp -v /tmp/"$BUILD_NUMBER"/AOSiP* /home/kronic/builds/"$DEVICE"/
rm -rfv /tmp/"$BUILD_NUMBER"

popd || exit
