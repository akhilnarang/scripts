#!/usr/bin/env bash
axel -a -n128 ${URL:?}
FILE=${URL##*/}
UNZIP_DIR=${FILE/.zip/}
unzip -q ${FILE} -d ${UNZIP_DIR} || unzip -q *.zip -d ${UNZIP_DIR}
cd ${UNZIP_DIR} || exit
rm -f ../${FILE}
for p in system vendor; do
    brotli -d $p.new.dat.br;
    sdat2img $p.{transfer.list,new.dat,img}
    mkdir $p || rm -rf $p/*
    sudo mount -t ext4 -o loop $p.img $p
    sudo chown $(whoami) $p/ -R
done
mkdir modem
sudo mount -t vfat -o loop firmware-update/modem.img modem/ || sudo mount -t vfat -o loop firmware-update/NON-HLOS.bin modem/
git clone -q https://github.com/xiaolu/mkbootimg_tools
./mkbootimg_tools/mkboot ./boot.img ./bootimg
find system/ -type f -exec echo {} >> allfiles.txt \;
find vendor/ -type f -exec echo {} >> allfiles.txt \;
find bootimg/ -type f -exec echo {} >> allfiles.txt \;
find modem/ -type f -exec echo {} >> allfiles.txt \;
sort allfiles.txt | tee all_files.txt
git init
git config user.name "Akhil's Lazy Buildbot"
git config user.email "jenkins@akhilnarang.me"
git config user.signingKey "76954A7A24F0F2E30B3DB2354D5819B432B2123C"
git add system/ vendor/ bootimg/ modem/ all_files.txt
TAG=$(cat modem/verinfo/ver_info.txt  | jq -r .Image_Build_IDs | jq -r .apps)
git commit -asm "${BRANCH} ${TAG}"
git push -qf ${GIT_REPO:?}HEAD:refs/heads/${BRANCH:?}

sudo umount system/
sudo umount vendor/
sudo umount modem/
