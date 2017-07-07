#!/usr/bin/env bash

# Script to merge upstream AOSP Tags in AOSiP

#COLORS -
red=$'\e[1;31m'
grn=$'\e[1;32m'
blu=$'\e[1;34m'
end=$'\e[0m'


# Assumes source is in users home in a directory called "nougat"
export AOSIP_PATH="${HOME}/nougat"

# Set the tag you want to merge
export TAG="android-7.1.2_r24"

# Set the base URL for all repos to be pulled from
export AOSP="https://android.googlesource.com"

do_not_merge="vendor/* manifest packages/apps/OmniSwitch packages/apps/OmniStyle packages/apps/OwlsNest external/google packages/apps/ThemeInterfacer \
packages/apps/Gallery2 device/qcom external/DUtils packages/apps/DUI packages/apps/SlimRecents packages/services/OmniJaws packages/apps/LockClock \
packages/apps/CalendarWidget hardware/* external/ant-wireless external/brctl external/chromium-webview external/connectivity external/busybox \
external/fuse external/exfat external/ebtables external/ffmpeg external/gson external/json-c external/libncurses external/libnetfilter_conntrack"

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
git fetch aosip nougat-mr2;
git checkout nougat-mr2;
git reset --hard aosip/nougat-mr2;
git remote rm aosp 2> /dev/null;
git remote add aosp "${AOSP}/platform/$repos";
git fetch aosp --quiet --tags;
if [ $? -ne 0 ];
then
echo "$repos" >> ${AOSIP_PATH}/notaosp
else
git merge ${TAG} --no-edit;
if [ $? -ne 0 ];
then
echo "$repos" >> ${AOSIP_PATH}/failed
echo "$red $repos failed :( $end"
else
if [[ "$(git rev-parse HEAD)" != "$(git rev-parse aosip/nougat-mr2)" ]]; then
echo "$repos" >> ${AOSIP_PATH}/success
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


