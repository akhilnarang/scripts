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

echo -e "Init and sync of RR-LP beginning!";
rm -rf $home
mkdir -p $home
cd $home
repo init -u https://github.com/ResurrectionRemix/platform_manifest.git -b optimized-lollipop5.1
curl --create-dirs -L -o .repo/local_manifests/roomservice.xml -O -L https://raw.githubusercontent.com/anik1199/blazingphoenix/master/rr.xml
touch synclog;
repo sync -f --force-sync -j125 >> synclog 2>&1
repo sync -f --force-sync >> synclog 2>&1

echo -e "Setting up build environment";
. build/envsetup.sh
rm -rf bionic
git clone git://github.com/ResurrectionRemix/android_bionic -b sprout bionic

make -j10 clobber
for DEVICE in sprout sprout_b jfltexx jfltetmo huashan
do
export UPLOAD_DIR=/var/www/html/downloads/ResurrectionRemix/$DEVICE
mkdir -p $UPLOAD_DIR > /dev/null
### Lunching device
echo -e "Lunching $DEVICE"
lunch cm_$DEVICE-userdebug

### Build and log output to a log file
echo -e "Starting ResurrectionRemix build in 5 seconds"
sleep 5
export WITH_LZMA_OTA=true
export KBUILD_BUILD_HOST=resurrectionremix-lp
export LOCALVERSION="~BlazingPhoenix"
touch $DEVICE-log
case $DEVICE in
	jfltetmo|jfltexx)
	export KBUILD_BUILD_USER=TJSteveMX;
	make -j10 bacon 2&>1 >> $DEVICE-log 2>&1
	bash /var/lib/jenkins/upload-scripts/esteban.sh $OUT/Resurrection*.zip
	;;
	sprout|sprout_b|sprout4|sprout8|huashan|bacon|baconcaf)
	export KBUILD_BUILD_USER=akhilnarang;
	make -j10 bacon 2&>1 >> $DEVICE-log 2>&1
	bash /var/lib/jenkins/upload-scripts/akhil.sh $OUT/Resurrection*.zip
	;;
	*)
	export KBUILD_BUILD_USER="ResurrectionRemix"
	make -j10 bacon 2&>1 >> $DEVICE-log 2>&1
esac
cp -v out/target/product/$DEVICE/Resurrection*.zip $UPLOAD_DIR/
done
							
