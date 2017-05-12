#!/usr/bin/env bash

# DEVICE, THIS_WILL_BE_RUN, RR_BUILDTYPE are set as jenkins parameters

source /home/akhiln/android_shell_tools/android_bash.rc && bashsync && time reposy -j64 || exit 1;
export USE_CCACHE=1
export CCACHE_DIR="/home/akhiln/.ccache-${DEVICE}"
ccache -M 20
export days_to_log=7
source build/envsetup.sh
lunch lineage_${DEVICE}-userdebug
time mka clobber
echo "Running ${THIS_WILL_BE_RUN}"
eval ${THIS_WILL_BE_RUN}
time mka bacon
exitCode=$?
if [ ${exitCode} -eq 0 ];
then
if [ ${RR_BUILDTYPE} == "Nightly" ];
then
echo -e "Build sucessful, uploading!";
# Upload and give OTA here
cd -
fi
fi
jack-admin stop-server
exit ${exitCode}
