#!/usr/bin/env bash

# shellcheck disable=SC2086
# SC2086: Double quote to prevent globbing and word splitting.

AOSIP_VERSION=$1
RELEASE_TAG=$2
DEVICE=$3
BUILD_NUMBER=$4
AOSIP_BUILDTYPE=$5

pushd /tmp/"$BUILD_NUMBER" || exit

s=""
for d in "$AOSIP_VERSION"*; do
    s+="-a $d "
done
hub -C ~/github-release release create "$RELEASE_TAG" $s -m "Assets for $AOSIP_VERSION"
rm -fv /home/kronic/builds/"$DEVICE"/*"$AOSIP_BUILDTYPE"*
cp -v /tmp/"$BUILD_NUMBER"/AOSiP* /home/kronic/builds/"$DEVICE"/
rm -rfv /tmp/"$BUILD_NUMBER"

popd || exit
