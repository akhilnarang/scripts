#!/usr/bin/env bash

if [ -z $1 ];
then
DEVICE="oneplus3";
else
DEVICE=$1;
fi

source build/envsetup.sh

if [[ "$2" =~ "clean" ]];
then
make clean
fi

if [[ "$2" =~ "dirty" ]];
then
make installclean
outdir="./out/target/product/${DEVICE}";
  rm -rf "$outdir/combinedroot";
  rm -rf "$outdir/data";
  rm -rf "$outdir/recovery";
  rm -rf "$outdir/root";
  rm -rf "$outdir/system";
  rm -rf "$outdir/utilities";
  rm -rf "$outdir/boot"*;
  rm -rf "$outdir/combined"*;
  rm -rf "$outdir/kernel";
  rm -rf "$outdir/ramdisk"*;
  rm -rf "$outdir/recovery"*;
  rm -rf "$outdir/system"*;
  rm -rf "$outdir/obj/ETC/system_build_prop_intermediates";
  rm -rf "$outdir/ota_temp/RECOVERY/RAMDISK";
fi

if [[ "$2" =~ "sync" ]];
then
time repo sync -c -f -j16 --force-sync --no-clone-bundle --no-tags
fi

export CCACHE_DIR=${HOME}/.ccache-${DEVICE}
export USE_CCACHE=1
if [[ "${DEVICE}" = "oneplus3" ]]; then
    ./prebuilts/misc/linux-x86/ccache/ccache -M 100
else
    ./prebuilts/misc/linux-x86/ccache/ccache -M 30
fi

rm -rfv .repo/local_manifests/
lunch aosip_${DEVICE}-userdebug
time mka kronic
if [ $? -eq 0 ]; then
  cd $OUT
  AOSIP_ZIP="$(ls AOSiP*.zip)";
  rsync -av "${AOSIP_ZIP}" "akhil@aosiprom.com:/home/kronic/aosiprom.com/.dothidden/akhil/${DEVICE}/";
  cd -;
  DOWNLOAD_URL="http://aosiprom.com/.dothidden/akhil/${DEVICE}/${AOSIP_ZIP}";
  bash ~/kronicbot/aosip_testers.sh "[$AOSIP_ZIP](${DOWNLOAD_URL})"
  if [[ "${DEVICE}" = "oneplus3" ]]; then
    bash ~/kronicbot/3_t_testers.sh "[$AOSIP_ZIP](${DOWNLOAD_URL})"
  fi
else
    bash ~/kronicbot/aosip_testers.sh "Failed: ${DEVICE} ${AOSIP_BUILDTYPE}"
fi
