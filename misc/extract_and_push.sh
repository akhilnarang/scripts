#!/usr/bin/env bash

[[ -z "${API_KEY}" ]] && echo "API_KEY not defined, exiting!" && exit 1

function sendTG() {
    curl -s "https://api.telegram.org/bot${API_KEY}/sendmessage" --data "text=${*}&chat_id=-1001412293127&parse_mode=HTML"
}

[[ -z "$ORG" ]] && ORG="AndroidDumps"
sendTG "Starting dump on <a href=\"$BUILD_URL\">jenkins</a>"
aria2c ${URL:?} || wget ${URL}
sendTG "Downloaded"
FILE=${URL##*/}
EXTENSION=${URL##*.}
UNZIP_DIR=${FILE/.$EXTENSION/}

if [[ "${EXTENSION}" == "tgz" ]]; then
    tar xf ${FILE}
    cd */images
else
    if [[ -f "${FILE}" ]]; then
        7z e ${FILE} -o${UNZIP_DIR}
    else
        7z e * -o${UNZIP_DIR}
    fi
fi
cd ${UNZIP_DIR} || exit
rm -f ../*.zip

files=$(ls)
if [[ -d "${files}" ]] && [[ $(echo ${files} | wc -l) -eq 1 ]]; then
    cd ${files}
    unzip *.zip
fi


if [[ -f "payload.bin" ]]; then
    sendTG "payload detected"
    if [[ ! -d "${HOME}/extract_android_ota_payload" ]]; then
        cd
        git clone https://github.com/cyxx/extract_android_ota_payload
        cd -
    fi
    python2 ~/extract_android_ota_payload/extract_android_ota_payload.py payload.bin
fi

for p in system vendor cust odm oem; do
    brotli -d $p.new.dat.br &>/dev/null ; #extract br
    cat $p.new.dat.{0..999} 2>/dev/null >> $p.new.dat #merge split Vivo(?) sdat
    sdat2img $p.{transfer.list,new.dat,img} &>/dev/null #convert sdat to img
    mkdir $p\_ || rm -rf $p/*
    echo $p 'extracted'
    sudo mount -t ext4 -o loop $p.img $p\_ &>/dev/null || (mv $p.img temp.img && simg2img temp.img $p.img && rm temp.img && sudo mount -t ext4 -o loop $p.img $p\_ &>/dev/null)
    sudo chown $(whoami) $p\_/ -R
    sudo chmod -R u+rwX $p\_/
done
mkdir modem_
sudo mount -t vfat -o loop firmware-update/NON-HLOS.bin modem_/ || sudo mount -t vfat -o loop firmware-update/modem.img modem_/ ||
sudo mount -t vfat -o loop NON-HLOS.bin modem_/ || sudo mount -t vfat -o loop modem.img modem_/ #extract modem
git clone -q https://github.com/xiaolu/mkbootimg_tools
./mkbootimg_tools/mkboot ./boot.img ./bootimg > /dev/null #extract boot
echo 'boot extracted'
rm -rf mkbootimg_tools
for p in system vendor modem cust odm oem; do
        sudo cp -r $p\_ $p/ #copy images
        echo $p 'copied'
        sudo umount $p\_ &>/dev/null #unmount
        rm -rf $p\_
done
#copy file names
sudo chown $(whoami) * -R ; chmod -R u+rwX * #ensure final permissions
find system/ -type f -exec echo {} >> allfiles.txt \;
find vendor/ -type f -exec echo {} >> allfiles.txt \;
find bootimg/ -type f -exec echo {} >> allfiles.txt \;
find modem/ -type f -exec echo {} >> allfiles.txt \;
find cust/ -type f -exec echo {} >> allfiles.txt \;
find odm/ -type f -exec echo {} >> allfiles.txt \;
find oem/ -type f -exec echo {} >> allfiles.txt \;
sort allfiles.txt > all_files.txt
rm allfiles.txt
rm *.dat *.list *.br system.img vendor.img 2>/dev/null #remove all compressed files

fingerprint=$(grep -oP "(?<=^ro.build.fingerprint=).*" -hs system/build.prop system/system/build.prop)
brand=$(echo $fingerprint | cut -d / -f1  | tr '[:upper:]' '[:lower:]')
codename=$(echo $fingerprint | cut -d / -f3 | cut -d : -f1  | tr '[:upper:]' '[:lower:]')
description=$(grep -oP "(?<=^ro.build.description=).*" -hs system/build.prop system/system/build.prop)
branch=$(echo $description | tr ' ' '-')
repo=$(echo $brand\_$codename\_dump)
git init
git config user.name "Akhil's Lazy Buildbot"
git config user.email "jenkins@akhilnarang.me"
git config user.signingKey "76954A7A24F0F2E30B3DB2354D5819B432B2123C"
git checkout -b $branch
find -size +97M -printf '%P\n' -o -name *sensetime* -printf '%P\n' -o -name *.lic -printf '%P\n' > .gitignore
git add --all
git reset META-INF/ file_contexts.bin
git commit -asm "Add $description" -S
curl -s -X POST -H "Authorization: token ${GITHUB_OAUTH_TOKEN}" -d '{ "name": "'"$repo"'" }' "https://api.github.com/orgs/$ORG/repos"
sendTG "Pushing"
git push ssh://git@github.com/$ORG/$repo HEAD:refs/heads/$branch ||

(git update-ref -d HEAD ; git reset system/ vendor/ ;
git checkout -b $branch ;
git commit -asm "Add extras for ${description}" ;
git push ssh://git@github.com/$ORG/${repo,,}.git $branch ;
git add vendor/ ;
git commit -asm "Add vendor for ${description}" ;
git push ssh://git@github.com/$ORG/${repo,,}.git $branch ;
git add system/system/app/ system/system/priv-app/ || git add system/app/ system/priv-app/ ;
git commit -asm "Add apps for ${description}" ;
git push ssh://git@github.com/$ORG/${repo,,}.git $branch ;
git add system/ ;
git commit -asm "Add system for ${description}" ;
git push ssh://git@github.com/$ORG/${repo,,}.git $branch ;)
sendTG "Pushed <a href=\"https://github.com/$ORG/$repo\">$description</a>"
