#!/usr/bin/env bash

# My jenkins script to build AOSP-CAF

# REPOSYNC, DEVICE are parameters set in jenkins
# android_shell_tools is from https://github.com/AdrianDC/android_shell_tools

source /home/akhil/android_shell_tools/android_bash.rc
bashsync;
if [ "${REPOSYNC}" == "yes" ];
then
rm -rf .repo/local_manifests 2>/dev/null
mkdir -v .repo/local_manifests
cd .repo/local_manifests
wget https://raw.githubusercontent.com/akhilnarang/local_manifests/master/${DEVICE}.xml
if [ ! -f "${DEVICE}.xml" ];
then
exit 1;
fi
cd -
time reposy -j32
[ $? -ne 0 ] && exit 1
fi
export USE_CCACHE=1
export CCACHE_DIR="/home/akhil/.ccache-${DEVICE}"
ccache -M 25
source build/envsetup.sh
lunch aosp_${DEVICE}-user
time make -j$(nproc) clean
time make -j$(nproc) otapackage
exitCode=$?
jack-admin stop-server
exit $exitCode
