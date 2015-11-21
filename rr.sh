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
home=/android/common/rr
export USE_CCACHE=1
export CCACHE_DIR=/android/.ccache
ccache -M 500G



echo "██████╗ ██╗      █████╗ ███████╗██╗███╗   ██╗ ██████╗ ██████╗ ██╗  ██╗ ██████╗ ███████╗███╗   ██╗██╗██╗  ██╗";
echo "██╔══██╗██║     ██╔══██╗╚══███╔╝██║████╗  ██║██╔════╝ ██╔══██╗██║  ██║██╔═══██╗██╔════╝████╗  ██║██║╚██╗██╔╝";
echo "██████╔╝██║     ███████║  ███╔╝ ██║██╔██╗ ██║██║  ███╗██████╔╝███████║██║   ██║█████╗  ██╔██╗ ██║██║ ╚███╔╝ ";
echo "██╔══██╗██║     ██╔══██║ ███╔╝  ██║██║╚██╗██║██║   ██║██╔═══╝ ██╔══██║██║   ██║██╔══╝  ██║╚██╗██║██║ ██╔██╗ ";
echo "██████╔╝███████╗██║  ██║███████╗██║██║ ╚████║╚██████╔╝██║     ██║  ██║╚██████╔╝███████╗██║ ╚████║██║██╔╝ ██╗";
echo "╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝";
echo "                                                                                                            ";

figlet ResurrectionRemix
cd $home
curl --create-dirs -L -o .repo/local_manifests/roomservice.xml -O -L https://raw.githubusercontent.com/anik1199/blazingphoenix/master/rr.xml
touch synclog;
echo -e "Fetched Local manifest\nSyncing now!";
repo sync -f --force-sync -j125 >> synclog 2>&1
repo sync -f --force-sync >> synclog 2>&1
echo -e "sync done";
echo -e "Setting up build environment";
. build/envsetup.sh
rm -rf bionic
git clone git://github.com/ResurrectionRemix/android_bionic -b sprout bionic

make -j10 clobber
for DEVICE in jfltexx jfltetmo
do
export UPLOAD_DIR=/var/www/html/downloads/ResurrectionRemix/$DEVICE
### Lunching device
echo -e "Lunching $DEVICE"
rm -rf device/samsung/$DEVICE/cm.dependencies
lunch cm_$DEVICE-userdebug

### Build and log output to a log file
echo -e "Starting ResurrectionRemix build of $DEVICE in 5 seconds"
sleep 5
export WITH_LZMA_OTA=true
export KBUILD_BUILD_HOST=resurrectionremix-lp
export LOCALVERSION="~BlazingPhoenix"
touch $DEVICE-log
	export KBUILD_BUILD_USER=TJSteveMX;
	make -j10 bacon >> $DEVICE-log 2>&1
	bash /var/lib/jenkins/upload-scripts/esteban.sh $OUT/Resurrection*.zip
echo -e $DEVICE build done :D
cp -v out/target/product/$DEVICE/Resurrection*.zip $UPLOAD_DIR/
done
							
