#!/usr/bin/env bash

#COLORS -
red=$'\e[1;31m'
grn=$'\e[1;32m'
blu=$'\e[1;34m'
end=$'\e[0m'


# Assumes source is in users home in a directory called "rro"
export RROPATH="${HOME}/rro"

# Set the tag you want to merge
export TAG="android-7.0.0_r14"

do_not_merge="vendor/aosp manifest external/fuse packages/apps/Snap system/bt"

cd ${RROPATH}

for filess in failed success
do
rm $filess 2> /dev/null
touch $filess
done
# AOSP-RRO manifest is setup with path first, then repo name, so the path attribute is after 2 spaces, and the name within "" in it
for repos in $(grep 'remote="rro"' ${RROPATH}/.repo/manifests/default.xml  | awk '{print $2}' | cut -d '"' -f2)
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
git fetch https://android.googlesource.com/platform/$repos -qt
git merge $TAG
if [ $? -ne 0 ];
then
echo "$repos" >> ${RROPATH}/failed
echo "$red $repos failed :( $end"
else
echo "$repos" >> ${RROPATH}/success
echo "$grn $repos succeeded $end"
fi
echo -e ""
cd ${RROPATH};
fi
done

cd packages/apps/Snap
git checkout nougat
git pull https://github.com/CyanogenMod/android_packages_apps_Snap cm-14.0
cd ../../../
cd system/bt
git checkout nougat
git pull https://github.com/CyanogenMod/android_system_bt.git cm-14.0
cd ../../
cd external/fuse
git checkout nougat
git pull https://github.com/CyanogenMod/android_external_fuse.git cm-14.0
cd ../../

echo -e ""
echo -e "$red These repos failed $end"
cat ./failed
echo -e ""
echo -e "$grn These succeeded $end"
cat ./success


