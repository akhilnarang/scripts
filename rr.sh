 #
 # Copyright � 2015, Akhil Narang "akhilnarang" <akhilnarang.1999@gmail.com>
 #
 # This software is licensed under the terms of the GNU General Public
 # License version 2, as published by the Free Software Foundation, and
 # may be copied, distributed, and modified under those terms.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # Please maintain this if you use this script or any part of it
 #

#!/bin/bash
home=/android/common/ResurrectionRemix
cd $home
export USE_CCACHE=1
export CCACHE_DIR=/android/.ccache
ccache -M 500G
CLEAN_OR_NOT=$1
SYNC_OR_NOT=$2
DEVICE=$3

export UPLOAD_DIR="/android/to-upload/ResurrectionRemix/$DEVICE"
if [ ! -d "$UPLOAD_DIR" ];
then
mkdir -p $UPLOAD_DIR
fi

echo "██████╗ ██╗      █████╗ ███████╗██╗███╗   ██╗ ██████╗ ██████╗ ██╗  ██╗ ██████╗ ███████╗███╗   ██╗██╗██╗  ██╗";
echo "██╔══██╗██║     ██╔══██╗╚══███╔╝██║████╗  ██║██╔════╝ ██╔══██╗██║  ██║██╔═══██╗██╔════╝████╗  ██║██║╚██╗██╔╝";
echo "██████╔╝██║     ███████║  ███╔╝ ██║██╔██╗ ██║██║  ███╗██████╔╝███████║██║   ██║█████╗  ██╔██╗ ██║██║ ╚███╔╝ ";
echo "██╔══██╗██║     ██╔══██║ ███╔╝  ██║██║╚██╗██║██║   ██║██╔═══╝ ██╔══██║██║   ██║██╔══╝  ██║╚██╗██║██║ ██╔██╗ ";
echo "██████╔╝███████╗██║  ██║███████╗██║██║ ╚████║╚██████╔╝██║     ██║  ██║╚██████╔╝███████╗██║ ╚████║██║██╔╝ ██╗";
echo "╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝";
echo "                                                                                                            ";

figlet ResurrectionRemix
echo -e "Setting up build environment";
. build/envsetup.sh

### Check conditions for cleaning output directory
if [ "$CLEAN_OR_NOT" == "1" ];
then
echo -e "Cleaning out directory"
make -j8 clean > /dev/null
echo -e "Out directory cleaned"
elif [ "$CLEAN_OR_NOT" == "2" ];
then
echo -e "Making out directory dirty"
make -j8 dirty > /dev/null
echo -e "Deleted old zips, changelogs, build.props"
else
echo -e "Out directory untouched!"
fi

### Check conditions for repo sync
if [ "$SYNC_OR_NOT" == "1" ];
then
echo -e "Running repo sync"
rm -rf .repo/local_manifests/*.xml
curl --create-dirs -L -o .repo/local_manifests/roomservice.xml -O -L https://raw.githubusercontent.com/anik1199/blazingphoenix/master/rr.xml
rm -rf bionic
repo sync -cfj8 --force-sync --no-clone-bundle
echo -e "Repo sync complete"
else
echo -e "Not syncing!"
fi

if [ "$DEVICE" == "sprout" ] || [ "$DEVICE" == "sprout_b" ];
then
rm -rf bionic
git clone git://github.com/ResurrectionRemix/android_bionic -b sprout bionic
fi

### Lunching device
echo -e "Lunching $DEVICE"
lunch cm_$DEVICE-userdebug

### Build and log output to a log file
echo -e "Starting ResurrectionRemix build in 5 seconds"
sleep 5
export WITH_LZMA_OTA=true
export KBUILD_BUILD_USER="ResurrectionRemix"
export KBUILD_BUILD_HOST="blazingphoenix.in"
make -j8 bacon
cp -v $OUT/Resurrection*.zip $UPLOAD_DIR/
