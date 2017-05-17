#!/usr/bin/env bash

# My jenkins script to build AOSiP

# REPOSYNC, PICKS, DEVICE, MAKECLEAN are setup as parameters in jenkins
# android_shell_tools is from https://github.com/AdrianDC/android_shell_tools/

function pick() {

if [ $# -gt 0 ]; then
repopick $@
fi

if [ $? -ne 0 ]; then
exit 1;
fi

}

source ${HOME}/android_shell_tools/android_bash.rc && bashsync || exit 1
[ ${REPOSYNC} == "yes" ] && rm -rfv .repo/local_manifests/ && time reposy -j64
export USE_CCACHE=1
export CCACHE_DIR="/home/akhil/.ccache-${DEVICE}"
ccache -M 25
source build/envsetup.sh
pick ${PICKS}
lunch aosip_${DEVICE}-userdebug
[ ${MAKECLEAN} == "yes"] && time mka clobber || time mka installclean
time mka kronic
exitCode=$?
jack-admin stop-server
exit $exitCode
