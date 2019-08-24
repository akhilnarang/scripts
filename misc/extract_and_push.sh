#!/usr/bin/env bash

[[ -z "${API_KEY}" ]] && echo "API_KEY not defined, exiting!" && exit 1

function sendTG() {
    curl -s "https://api.telegram.org/bot${API_KEY}/sendmessage" --data "text=${*}&chat_id=-1001412293127&parse_mode=HTML" > /dev/null
}

[[ -z "$ORG" ]] && ORG="AndroidDumps"
sendTG "Starting <a href=\"${URL:?}\">dump</a> on <a href=\"$BUILD_URL\">jenkins</a>"
aria2c -x16 -j"$(nproc)" "${URL}" || wget "${URL}" || exit 1
sendTG "Downloaded the file"
FILE=${URL##*/}
EXTENSION=${URL##*.}
UNZIP_DIR=${FILE/.$EXTENSION/}

if [[ ! -f "${FILE}" ]]; then
    if [[ "$(ls | wc -l)" != 1 ]]; then
        sendTG "Can't seem to find downloaded file!"
        exit 1
    else
        FILE="$(ls *)"
    fi
fi

PARTITIONS="system vendor cust odm oem factory product modem xrom systemex"

 if [[ ! -d "${HOME}/extract_android_ota_payload" ]]; then
    git clone -q https://github.com/cyxx/extract_android_ota_payload ~/extract_android_ota_payload
else
    git -C ~/extract_android_ota_payload pl
fi

if [[ ! -d "${HOME}/extract-dtb" ]]; then
    git clone -q https://github.com/PabloCastellano/extract-dtb ~/extract-dtb
else
    git -C ~/extract-dtb pl
fi

if [[ ! -d "${HOME}/Firmware_extractor" ]]; then
    git clone -q https://github.com/AndroidDumps/Firmware_extractor --recurse-submodules ~/Firmware_extractor
else
    git -C ~/Firmware_extractor pl --recurse-submodules
fi

if [[ ! -d "${HOME}/mkbootimg_tools" ]]; then
    git clone -q https://github.com/xiaolu/mkbootimg_tools ~/mkbootimg_tools
else
    git -C ~/mkbootimg_tools pl
fi

bash ~/Firmware_extractor/extractor.sh "${FILE}" "${PWD}" || ( sendTG "Extraction failed!"; exit 1 )

~/mkbootimg_tools/mkboot ./boot.img ./bootimg > /dev/null
python3 ~/extract-dtb/extract-dtb.py ./boot.img -o ./bootimg > /dev/null
mkdir bootdts dtbodts
find bootimg/ -name '*.dtb' -type f -exec dtc -I dtb -O dts {} -o bootdts/"$(echo {} | sed 's/\.dtb/.dts/')" \; > /dev/null
[[ -f "dtbo.img" ]] && python3 ~/extract-dtb/extract-dtb.py ./dtbo.img -o ./dtbo > /dev/null
find dtbo/ -name '*.dtb' -type f -exec dtc -I dtb -O dts {} -o dtbodts/"$(echo {} | sed 's/\.dtb/.dts/')" \; > /dev/null

for p in $PARTITIONS; do
    if [ -f "$p.img" ]; then
        mkdir "$p" || rm -rf "$p"/*
        7z x "$p".img -y -o"$p"/
        rm "$p".img
    fi
done

ls system/build*.prop 2>/dev/null || ls system/system/build*.prop 2>/dev/null || ( sendTG "No system build*.prop found, pushing cancelled!" && exit 1 )


# board-info.txt
find ./modem -type f -exec strings {} \; | grep "QC_IMAGE_VERSION_STRING=MPSS." | sed "s|QC_IMAGE_VERSION_STRING=MPSS.||g" | cut -c 4- | sed -e 's/^/require version-baseband=/' >> ./board-info.txt
find ./tz* -type f -exec strings {} \; | grep "QC_IMAGE_VERSION_STRING" | sed "s|QC_IMAGE_VERSION_STRING|require version-trustzone|g" >> ./board-info.txt
if [ -f ./vendor/build.prop ]; then
	strings ./vendor/build.prop | grep "ro.vendor.build.date.utc" | sed "s|ro.vendor.build.date.utc|require version-vendor|g" >> ./board-info.txt
fi
sort -u -o ./board-info.txt ./board-info.txt

# Fix permissions
chown $(whoami) * -R
chmod -R u+rwX *

# Generate all_files.txt
find . -type f -printf '%P\n' | sort | grep -v ".git/" > ./all_files.txt

flavor=$(grep -oP "(?<=^ro.build.flavor=).*" -hs {system,system/system,vendor}/build*.prop)
[[ -z "${flavor}" ]] && flavor=$(grep -oP "(?<=^ro.vendor.build.flavor=).*" -hs vendor/build*.prop)
[[ -z "${flavor}" ]] && flavor=$(grep -oP "(?<=^ro.system.build.flavor=).*" -hs {system,system/system}/build*.prop)
[[ -z "${flavor}" ]] && flavor=$(grep -oP "(?<=^ro.build.type=).*" -hs {system,system/system}/build*.prop)
release=$(grep -oP "(?<=^ro.build.version.release=).*" -hs {system,system/system,vendor}/build*.prop)
[[ -z "${release}" ]] && release=$(grep -oP "(?<=^ro.vendor.build.version.release=).*" -hs vendor/build*.prop)
[[ -z "${release}" ]] && release=$(grep -oP "(?<=^ro.system.build.version.release=).*" -hs {system,system/system}/build*.prop)
id=$(grep -oP "(?<=^ro.build.id=).*" -hs {system,system/system,vendor}/build*.prop)
[[ -z "${id}" ]] && id=$(grep -oP "(?<=^ro.vendor.build.id=).*" -hs vendor/build*.prop)
[[ -z "${id}" ]] && id=$(grep -oP "(?<=^ro.system.build.id=).*" -hs {system,system/system}/build*.prop)
incremental=$(grep -oP "(?<=^ro.build.version.incremental=).*" -hs {system,system/system,vendor}/build*.prop)
[[ -z "${incremental}" ]] && incremental=$(grep -oP "(?<=^ro.vendor.build.version.incremental=).*" -hs vendor/build*.prop)
[[ -z "${incremental}" ]] && incremental=$(grep -oP "(?<=^ro.system.build.version.incremental=).*" -hs {system,system/system}/build*.prop)
tags=$(grep -oP "(?<=^ro.build.tags=).*" -hs {system,system/system,vendor}/build*.prop)
[[ -z "${tags}" ]] && tags=$(grep -oP "(?<=^ro.vendor.build.tags=).*" -hs vendor/build*.prop)
[[ -z "${tags}" ]] && tags=$(grep -oP "(?<=^ro.system.build.tags=).*" -hs {system,system/system}/build*.prop)
fingerprint=$(grep -oP "(?<=^ro.build.fingerprint=).*" -hs {system,system/system,vendor}/build*.prop)
[[ -z "${fingerprint}" ]] && fingerprint=$(grep -oP "(?<=^ro.vendor.build.fingerprint=).*" -hs vendor/build*.prop)
[[ -z "${fingerprint}" ]] && fingerprint=$(grep -oP "(?<=^ro.system.build.fingerprint=).*" -hs {system,system/system}/build*.prop)
brand=$(grep -oP "(?<=^ro.product.brand=).*" -hs {system,system/system,vendor}/build*.prop | head -1)
[[ -z "${brand}" ]] && brand=$(grep -oP "(?<=^ro.product.vendor.brand=).*" -hs vendor/build*.prop | head -1)
[[ -z "${brand}" ]] && brand=$(grep -oP "(?<=^ro.vendor.product.brand=).*" -hs vendor/build*.prop | head -1)
[[ -z "${brand}" ]] && brand=$(grep -oP "(?<=^ro.product.system.brand=).*" -hs {system,system/system}/build*.prop | head -1)
[[ -z "${brand}" ]] && brand=$(echo "$fingerprint" | cut -d / -f1 )
codename=$(grep -oP "(?<=^ro.product.device=).*" -hs {system,system/system,vendor}/build*.prop | head -1)
[[ -z "${codename}" ]] && codename=$(grep -oP "(?<=^ro.product.vendor.device=).*" -hs vendor/build*.prop | head -1)
[[ -z "${codename}" ]] && codename=$(grep -oP "(?<=^ro.vendor.product.device=).*" -hs vendor/build*.prop | head -1)
[[ -z "${codename}" ]] && codename=$(grep -oP "(?<=^ro.product.system.device=).*" -hs {system,system/system}/build*.prop | head -1)
[[ -z "${codename}" ]] && codename=$(echo "$fingerprint" | cut -d / -f3 | cut -d : -f1 )
[[ -z "${codename}" ]] && codename=$(grep -oP "(?<=^ro.build.fota.version=).*" -hs {system,system/system}/build*.prop | cut -d - -f1 | head -1)
description=$(grep -oP "(?<=^ro.build.description=).*" -hs {system,system/system,vendor}/build*.prop)
[[ -z "${description}" ]] && description=$(grep -oP "(?<=^ro.vendor.build.description=).*" -hs vendor/build*.prop)
[[ -z "${description}" ]] && description=$(grep -oP "(?<=^ro.system.build.description=).*" -hs {system,system/system}/build*.prop)
[[ -z "${description}" ]] && description="$flavor $release $id $incremental $tags"
branch=$(echo "$description" | tr ' ' '-')
repo=$(echo "$brand"\_"$codename"\_dump | tr '[:upper:]' '[:lower:]')

printf "\nflavor: $flavor\nrelease: $release\nid: $id\nincremental: $incremental\ntags: $tags\nfingerprint: $fingerprint\nbrand: $brand\ncodename: $codename\ndescription: $description\nbranch: $branch\nrepo: $repo\n"

git init
git config user.name "Akhil's Lazy Buildbot"
git config user.email "jenkins@akhilnarang.me"
git config user.signingKey "76954A7A24F0F2E30B3DB2354D5819B432B2123C"
git checkout -b $branch
find -size +97M -printf '%P\n' -o -name *sensetime* -printf '%P\n' -o -name *.lic -printf '%P\n' > .gitignore
git add --all
git commit -asm "Add $description" -S || exit 1
curl -s -X POST -H "Authorization: token ${GITHUB_OAUTH_TOKEN}" -d '{ "name": "'"$repo"'" }' "https://api.github.com/orgs/$ORG/repos" || exit 1
sendTG "Pushing"
git push ssh://git@github.com/$ORG/$repo HEAD:refs/heads/$branch ||

(sendTG "Pushing failed, splitting commits and trying";
git update-ref -d HEAD ; git reset system/ vendor/ ;
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
git push ssh://git@github.com/$ORG/${repo,,}.git $branch ;) || (sendTG "Pushing failed" && exit 1)
sendTG "Pushed <a href=\"https://github.com/$ORG/$repo\">$description</a>"

commit_head=$(git log -1 --format=%H)
commit_link="https://github.com/$ORG/$repo/commit/$commit_head"
echo -e "Sending telegram notification"
(
printf "<b>Brand: $brand</b>"
printf "\n<b>Device: $codename</b>"
printf "\n<b>Version:</b> $release"
printf "\n<b>Fingerprint:</b> $fingerprint"
printf "\n<b>GitHub:</b>"
printf "\n<a href=\"$commit_link\">Commit</a>"
printf "\n<a href=\"https://github.com/$ORG/$repo/tree/$branch/\">$codename</a>"
) >> tg.html
TEXT=$(cat tg.html)
curl -s "https://api.telegram.org/bot${API_KEY}/sendmessage" --data "text=${TEXT}&chat_id=@android_dumps&parse_mode=HTML&disable_web_page_preview=True" > /dev/null
rm -fv tg.html
