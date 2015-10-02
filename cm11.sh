 #
 # Copyright � 2015, Sri Harsha "srisurya95" <srisurya95@gmail.com>
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
home=/home/srisurya95/cm11
cd $home
host=$(cat /etc/hostname)
export KBUILD_BUILD_HOST=$host
export LINUX_COMPILE_BY=$host
export WITH_LZMA_OTA=true
export USE_CCACHE=1
export CCACHE_DIR=/android/.ccache
ccache -M 500G
CLEAN_OR_NOT=$1
SYNC_OR_NOT=$2
OFFICIAL_OR_NOT=$3
DEVICE=$4

export UPLOAD_DIR="/android/to-upload/cm11/$DEVICE"

echo "██████╗ ██╗      █████╗ ███████╗██╗███╗   ██╗ ██████╗ ██████╗ ██╗  ██╗ ██████╗ ███████╗███╗   ██╗██╗██╗  ██╗";
echo "██╔══██╗██║     ██╔══██╗╚══███╔╝██║████╗  ██║██╔════╝ ██╔══██╗██║  ██║██╔═══██╗██╔════╝████╗  ██║██║╚██╗██╔╝";
echo "██████╔╝██║     ███████║  ███╔╝ ██║██╔██╗ ██║██║  ███╗██████╔╝███████║██║   ██║█████╗  ██╔██╗ ██║██║ ╚███╔╝ ";
echo "██╔══██╗██║     ██╔══██║ ███╔╝  ██║██║╚██╗██║██║   ██║██╔═══╝ ██╔══██║██║   ██║██╔══╝  ██║╚██╗██║██║ ██╔██╗ ";
echo "██████╔╝███████╗██║  ██║███████╗██║██║ ╚████║╚██████╔╝██║     ██║  ██║╚██████╔╝███████╗██║ ╚████║██║██╔╝ ██╗";
echo "╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝";
echo "                                                                                                            ";


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
repo sync -cfj8 --force-sync --no-clone-bundle
echo -e "Repo sync complete"
else
echo -e "Not syncing!"
fi


### Lunching device
echo -e "Lunching $DEVICE"
lunch cm_$DEVICE-userdebug

### Build and log output to a log file
echo -e "Starting cm11 build in 5 seconds"
sleep 5
mka bacon -j8  2>&1 | tee falcon_$DEVICE-$(date "+%Y%m%d").log

### Copying of zip and build log

if [ ! -e "$UPLOAD_DIR" ];
then
echo -e "Dir to copy zip not found, creating";
mkdir -p $UPLOAD_DIR
fi
echo -e "Copying zip, build log, zip md5sum";
cp out/target/product/$DEVICE/cm-11*.zip $UPLOAD_DIR/
cp crdroid_$DEVICE-*.log $UPLOAD_DIR/
cp out/target/product/$DEVICE/cm-11*.zip.md5sum $UPLOAD_DIR/
echo -e "All required outputs copied to $UPLOAD_DIR please use upload_cm11 script to upload :)"
echo -e "Have a nice day :), enjoy the power of BlazingPhoenix Server :D ";
