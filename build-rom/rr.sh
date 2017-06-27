#!/usr/bin/env bash

# My jenkins build script for RR

# android_development_shell_tools is from https://github.com/AdrianDC/android_development_shell_tools

# android-scripts is from https://github.com/tdm/android-scripts

# ota is from https://github.com/ResurrectionRemix/OTA

# script is from https://github.com/TheScarastic/script

# rrkenzobot has scripts for me to be able to spam a group with a bot :P

ADCSCRIPT="/home/akhiln/android_development_shell_tools"
if [[ -f "${ADCSCRIPT}/android_development_shell_tools.rc" ]]; then
    source "${ADCSCRIPT}/android_development_shell_tools.rc"
fi

shtoolssync;

if [[ "${repoSync}" = "yes" ]]; then
    time reposy -j16;
fi

export USE_CCACHE=1
export CCACHE_DIR="/home/akhiln/.ccache-${DEVICE}"
ccache -M 30

export days_to_log=7

source build/envsetup.sh

lunch lineage_${DEVICE}-userdebug

if [[ "${cleanBuild}" = "yes" ]]; then
    time mka clobber
fi

echo "Running ${THIS_WILL_BE_RUN}"
eval ${THIS_WILL_BE_RUN}

if [ ${RR_BUILDTYPE} == "Nightly" ];
then
bash ~/rrkenzobot/kenzo.sh "Starting $(date) RR ${DEVICE} Nightly";
fi

~/android-scripts/android-tag create > ~/tags/$(date +%Y%m%d)

cp -v ota/akhil/${DEVICE}.conf ./ota_conf

cd build/kati;
git checkout 7b2171336fa8aa62800fa17f242ef8456076d36b;
cd ../soong;
git checkout f49082afab1651e120cbc2474873b38ba4078c20;
cd ../blueprint;
git checkout e257cf82bdb9c5c1c35969e1977470fb6fb96837
cd ../../;

time mka bacon
exitCode=$?

if [ ${exitCode} -eq 0 ]; then
    cout
    RRZIP="$(ls RR*.zip)";
    cd -
    if [ ${RR_BUILDTYPE} == "Nightly" ]; then
        echo -e "Build sucessful, uploading!";
        bash ~/rrkenzobot/kenzo.sh "Build successful, uploading!";
        curl -T "${OUT}/${RRZIP}" ftp://USERNAME:PASSWORD@localhost/downloads.resurrectionremix.com/${DEVICE}/;
        echo -e "Grab zip at http://downloads.resurrectionremix.com/${DEVICE}/${RRZIP}";
        ~/android-scripts/android-changelog -f html -m ~/tags/current ~/tags/$(date +%Y%m%d) > ~/rr.akhilnarang.me/Changelogs/$(date +%Y%m%d).html
        ~/android-scripts/android-changelog -f html -m ~/tags/first ~/tags/$(date +%Y%m%d) > ~/rr.akhilnarang.me/Changelogs/Changelog.html
        # Make all ssh links into https so people can click on them
        sed -i -e 's|ssh://git@|https://|g' ~/rr.akhilnarang.me/Changelogs/*;
        cp ~/tags/$(date +%Y%m%d) ~/tags/current
        curl -T ./CHANGELOG.mkdn ftp://USERNAME:PASSWORD/downloads.resurrectionremix.com/${DEVICE}/Changelog.txt;
        cp CHANGELOG.mkdn ota/akhil/Changelog.txt;
        cd ota; git add -A;
        ~/rr/script/ota-gen.sh "${RRZIP}";
        bash ~/rrkenzobot/kenzo.sh "[$RRZIP](http://downloads.resurrectionremix.com/${DEVICE}/${RRZIP}) | [Changelog](http://rr.akhilnarang.me/Changelogs)";
    fi
    #rsync -av "${OUT}/${RRZIP}" ~/rr.akhilnarang.me/${DEVICE}/;
    #echo -e "Grab it at http://rr.akhilnarang.me/${DEVICE}/${RRZIP}";
else
    bash ~/rrkenzobot/kenzo.sh "BUILD FAILED, RIP in pieces.";
fi

echo -e "Killing jack server!";
jack-admin stop-server;

exit ${exitCode};
