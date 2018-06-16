#!/usr/bin/env bash

# My jenkins build script for RR

# android_development_shell_tools is from https://github.com/AdrianDC/android_development_shell_tools

# ota is from https://github.com/ResurrectionRemix/OTA

# rrkenzobot has scripts for me to be able to spam a group with a bot :P

ADCSCRIPT="/home/akhil/android_development_shell_tools"
if [ -f "${ADCSCRIPT}/android_development_shell_tools.rc" ]
then
source "${ADCSCRIPT}/android_development_shell_tools.rc"
fi

source ~/scripts/startupstuff.sh

shtoolssync

if [[ "${repoSync}" = "yes" ]]; then
    time reposy
fi
export USE_CCACHE=1
export CCACHE_DIR="/home/akhil/.ccache"
ccache -M 200
export days_to_log=7
source build/envsetup.sh
lunch rr_${DEVICE}-userdebug
if [[ "${cleanBuild}" = "yes" ]]; then
    time mka clobber
fi
echo "Running ${THIS_WILL_BE_RUN}"
eval ${THIS_WILL_BE_RUN}

if [ ${RR_BUILDTYPE} == "Official" ]; then
bash ~/rrkenzobot/lineage.sh "[Starting $(date +%Y%m%d) RR ${DEVICE} ${RR_BUILDTYPE} build]($BUILD_URL)"
fi
cp -v ota/akhil/${DEVICE}.conf ./ota_conf
time mka bacon
exitCode=$?
if [ ${exitCode} -eq 0 ]
then
cout
RRZIP="$(ls RR*.zip)"
size=$(du -sh $RRZIP | awk '{print $1}')
rrmd5=$(md5sum $RRZIP | awk '{print $1}' )
cd -
if [ ${RR_BUILDTYPE} == "Official" ]
then
echo -e "Build sucessful, uploading!"
bash ~/rrkenzobot/jenkins.sh "Build successful, uploading!"
curl --ftp-pasv --upload-file "${OUT}/${RRZIP}" ftp://localhost/downloads.resurrectionremix.com/${DEVICE}/
curl --ftp-pasv --upload-file "${OUT}/${RRZIP}.md5sum" ftp://localhost/downloads.resurrectionremix.com/${DEVICE}/
curl --ftp-pasv --upload-file "${OUT}/*Changelog*.txt" ftp://localhost/downloads.resurrectionremix.com/${DEVICE}/Changelog.txt
cp $OUT/RR*.txt ota/akhil/Changelog.txt
cd ota; git add -A
~/rr-o/ota/ota-gen.sh "${DEVICE}" "${RRZIP}"
bash ~/rrkenzobot/jenkins.sh "[$RRZIP](https://downloads.resurrectionremix.com/${DEVICE}/${RRZIP})

[Changelog](https://downloads.resurrectionremix.com/${DEVICE}/Changelog.txt)

MD5sum - $rrmd5

FileSize - $size"
else
bash ~/rrkenzobot/akhil.sh "${DEVICE} build done."
fi
rsync -av "${OUT}/${RRZIP}" ~/rr.akhilnarang.me/${DEVICE}/
echo -e "Grab it at http://rr.akhilnarang.me/${DEVICE}/${RRZIP}"
else
bash ~/rrkenzobot/lineage.sh "${DEVICE} BUILD FAILED, RIP in pieces @akhilnarang."
fi
echo -e "Killing jack server!"
jack-admin stop-server
exit ${exitCode}
