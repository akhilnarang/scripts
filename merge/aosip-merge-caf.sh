#!/usr/bin/env bash

# Script to merge upstream CAF Tags in AOSiP

#COLORS -
red=$'\e[1;31m'
grn=$'\e[1;32m'
blu=$'\e[1;34m'
end=$'\e[0m'


# Assumes source is in users home in a directory called "nougat"
export AOSIP_PATH="${HOME}/nougat"

# Set the tag you want to merge
export TAG="LA.UM.5.7.r1-08900-8x98.0"

# Set the base URL for all repos to be pulled from
export CAF="https://source.codeaurora.org"

do_not_merge="vendor/aosip manifest packages/apps/OmniSwitch packages/apps/OmniStyle packages/apps/OwlsNest external/google packages/apps/ThemeInterfacer packages/apps/Gallery2 device/qcom/sepolicy external/DUtils packages/apps/DUI packages/apps/SlimRecents packages/services/OmniJaws packages/apps/LockClock packages/apps/CalendarWidget hardware/qcom/fm"

cd ${AOSIP_PATH}

for filess in failed success
do
rm $filess 2> /dev/null
touch $filess
done
# AOSiP manifest is setup with repo name first, then repo path, so the path attribute is after 3 spaces, and the path itself within "" in it
for repos in $(grep 'remote="aosip"' ${AOSIP_PATH}/.repo/manifests/manifests/aosip.xml  | awk '{print $3}' | awk -F '"' '{print $2}')
do
echo -e ""
if [[ "${do_not_merge}" =~ "${repos}" ]];
then
echo -e "${repos} is not to be merged";
else
echo "$blu Merging $repos $end"
echo -e ""
cd $repos;
git checkout nougat
git fetch aosip nougat
git reset --hard aosip/nougat
git remote rm caf 2> /dev/null
git remote add caf "${CAF}/platform/$repos"
git fetch caf --quiet --tags
git merge ${TAG} --no-edit
if [ $? -ne 0 ];
then
echo "$repos" >> ${AOSIP_PATH}/failed
echo "$red $repos failed :( $end"
else
echo "$repos" >> ${AOSIP_PATH}/success
echo "$grn $repos succeeded $end"
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


