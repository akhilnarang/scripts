#!/bin/bash
home=/android/common/SlimRemiX
cd $home
export SLIMREMIX_VERSION_MINOR="MR18"
export SLIMREMIX_VERSION_MAINTENANCE="Official"
export SLIMREMIX_VERSION="$SLIMREMIX_VERSION_MAJOR $SLIMREMIX_VERSION_MINOR $SLIMREMIX_MAINTENANCE"
export SLIMREMIX_CHANGELOG=true
host=$(cat /etc/hostname)
export KBUILD_BUILD_HOST=$host
export LINUX_COMPILE_HOST=$host
export WITH_LZMA_OTA=true
CLEAN_OR_NOT=$1
SYNC_OR_NOT=$2
DEVICE=$3
export KBUILD_BUILD_USER="SlimRemiX"
export UPLOAD_DIR=/var/www/html/downloads/SlimRemix/$DEVICE
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

figlet SlimRemix ;
echo -e "Setting up build environment";
. build/envsetup.sh


# This will create a new build.prop with updated build time and date
rm -f "$OUTDIR"/target/product/"$DEVICE"/system/build.prop

# This will create a new .version for kernel version is maintained on one
rm -f "$OUTDIR"/target/product/"$DEVICE"/obj/KERNEL_OBJ/.version

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
curl --create-dirs -L -o .repo/local_manifests/roomservice.xml -O -L https://raw.githubusercontent.com/anik1199/blazingphoenix/master/slimremix.xml
repo sync -cfj8 --force-sync --no-clone-bundle
echo -e "Repo sync complete"
else
echo -e "Not syncing!"
fi

### Lunching device
echo -e "Lunching $DEVICE"
lunch slimremix_$DEVICE-userdebug

### Build
echo -e "Starting SlimRemix build in 5 seconds"
sleep 5
unset SLIMREMIX_MAKE
make -j8 bacon
cp -v $OUT/SlimRemix*.zip $UPLOAD_DIR/
