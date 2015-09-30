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
home=/android/common/Candy5
cd $home
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

export UPLOAD_DIR="/android/to-upload/Candy5/$DEVICE"

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

# Remove roomservice.xml if exist
file=roomservice.xml
cd $home/.repo/local_manifests/
if [ -f $file ]; then
echo -e "$ROUGE Deleting roomservice.xml inside local_manifests $NORMAL"
rm -rf $file
else
echo -e "No files found ...."
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
echo -e "Building CandyRoms OFFICIAL for $DEVICE"
export Candy5_RELEASE=true
else
echo -e "Building CandyRoms UNOFFICIAL for $DEVICE"
unset Candy5_RELEASE
fi

### Lunching device
echo -e "Lunching $DEVICE"
lunch candy5_$DEVICE-userdebug

### Build and log output to a log file
echo -e "Starting CandyRoms build in 5 seconds"
sleep 5
make -j8 bacon  2>&1 | tee candy5_$DEVICE-$(date "+%Y%m%d").log

### Copying of zip and build log

if [ ! -e "$UPLOAD_DIR" ];
then
echo -e "Dir to copy zip not found, creating";
mkdir -p $UPLOAD_DIR
fi
echo -e "Copying zip, build log, zip md5sum";
cp out/target/product/$DEVICE/*-candy5-*.zip $UPLOAD_DIR/
cp candy5_$DEVICE-*.log $UPLOAD_DIR/
cp out/target/product/$DEVICE/*-candy5-*.zip.md5sum $UPLOAD_DIR/
echo -e "All required outputs copied to $UPLOAD_DIR please use upload_Candy5 script to upload :)"
echo -e "Have a nice day :), enjoy the power of BlazingPhoenix Server :D ";
