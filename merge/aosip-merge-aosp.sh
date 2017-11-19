#!/usr/bin/env bash

# Script to merge upstream AOSP tags in AOSiP

#COLORS -
red=$'\e[1;31m'
grn=$'\e[1;32m'
blu=$'\e[1;34m'
end=$'\e[0m'


# Assumes source is in users home in a directory called "oreo"
export AOSIP_PATH="${HOME}/oreo"

# Set OLD_TAG to the tag you are currently based on
export OLD_TAG="android-8.0.0_r15"

# Set NEW_TAG to the tag you want to merge
export NEW_TAG="android-8.0.0_r32"

# Set the base URL for all repos to be pulled from
export AOSP="https://android.googlesource.com"

do_not_merge="vendor/* manifest packages/apps/OmniSwitch packages/apps/OmniStyle \
packages/apps/OwlsNest external/google packages/apps/ThemeInterfacer \
packages/apps/Gallery2 device/qcom external/DUtils packages/apps/DUI \
packages/apps/SlimRecents packages/services/OmniJaws packages/apps/LockClock \
packages/apps/CalendarWidget hardware/qcom/*-caf external/ant-wireless \
external/brctl external/chromium-webview external/connectivity external/busybox \
external/fuse external/exfat external/ebtables external/ffmpeg external/gson \
external/json-c external/libncurses external/libnetfilter_conntrack \
external/libnfnetlink"

cd ${AOSIP_PATH}

for filess in failed success notaosp
do
rm $filess 2> /dev/null
touch $filess
done
# AOSiP manifest is setup with repo path first, then repo name, so the path attribute is after 2 spaces, and the path itself within "" in it
for repos in $(grep 'remote="aosip"' ${AOSIP_PATH}/.repo/manifests/snippets/aosip.xml  | awk '{print $2}' | awk -F '"' '{print $2}')
do
echo -e ""
if [[ "${do_not_merge}" =~ "${repos}" ]];
then
echo -e "${repos} is not to be merged";
else
echo "$blu Merging $repos $end"
echo -e ""
cd $repos;
if [[ "$repos" == "build/make" ]]; then
    repos="build";
fi
git fetch aosip oreo;
git checkout oreo;
git reset --hard aosip/oreo;
git remote rm aosp 2> /dev/null;
git remote add aosp "${AOSP}/platform/$repos";
git fetch aosp --quiet --tags;
if [ $? -ne 0 ];
then
echo "$repos" >> ${AOSIP_PATH}/notaosp
else
git merge ${NEW_TAG} --no-edit --log=$(git rev-list --count ${OLD_TAG}..${NEW_TAG});
if [ $? -ne 0 ];
then
echo "$repos" >> ${AOSIP_PATH}/failed
echo "$red $repos failed :( $end"
else
if [[ "$(git rev-parse HEAD)" != "$(git rev-parse aosip/oreo)" ]]; then
echo "$repos" >> ${AOSIP_PATH}/success
git commit -as --amend --no-edit
echo "$grn $repos succeeded $end"
else
echo "$repos - unchanged";
fi
fi
fi
echo -e ""
cd ${AOSIP_PATH};
fi
done

echo -e ""

echo -e "$red These repos failed $end"
cat ./failed
echo -e ""
echo -e "$grn These succeeded $end"
cat ./success


