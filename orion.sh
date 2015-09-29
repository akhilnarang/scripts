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
cd /android/common/OrionLP
export KBUILD_BUILD_HOST="blazingphoenix.in"
export LINUX_COMPILE_BY=$KBUILD_BUILD_HOST
export WITH_LZMA_OTA=true
CLEAN_OR_NOT=$1
SYNC_OR_NOT=$2
OFFICIAL_OR_NOT=$3
if [ ! "$4" == "" ];
then
export KBUILD_BUILD_USER=$4
DEVICE=$5
else
DEVICE=$4

export UPLOAD_DIR="/android/to-upload/TeamLP/$DEVICE"

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
make -j8 clean > /dev/null 2>&1 &
echo -e "Out directory cleaned"
elif [ "$CLEAN_OR_NOT" == "2" ];
then
echo -e "Making out directory dirty"
make -j8 dirty > /dev/null 2>&1 &
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

### Checking if official build or not
if [ "$OFFICIAL_OR_NOT" == "1" ];
then
echo -e "Building OrionLP OFFICIAL for $DEVICE"
export ORION_RELEASE=true
else
echo -e "Building OrionLP UNOFFICIAL for $DEVICE"
unset ORION_RELEASE
fi

### Lunching device
echo -e "Lunching $DEVICE"
lunch orion_$DEVICE-userdebug

### Build and log output to a log file
echo -e "Starting OrionLP build in 5 seconds"
sleep 5
make -j8 bacon  2>&1 | tee orion_$DEVICE-$(date "+%Y%m%d").log

### Copying of zip and build log

if [ ! -e "$UPLOAD_DIR" ];
then
echo -e "Dir to copy zip not found, creating";
mkdir -p $UPLOAD_DIR
fi
echo -e "Copying zip, build log, zip md5sum";
cp out/target/product/$DEVICE/orion-$DEVICE-*.zip $UPLOAD_DIR/
cp orion_$DEVICE-*.log $UPLOAD_DIR/
cp out/target/product/$DEVICE/orion-$DEVICE-*.zip.md5sum $UPLOAD_DIR/
echo -e "All required outputs copied to $UPLOAD_DIR please use upload_orion script to upload :)"
echo -e "Have a nice day :), enjoy the power of BlazingPhoenix Server :D ";
