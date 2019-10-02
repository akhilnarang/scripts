#!/usr/bin/env bash
cd /home/acar/ua/.hidden/"${DEVICE:?}" || exit
git -C ~/api pull rr master
mv "${DEVICE}".json /home/acar/api/
git -C ~/api add -A
git -C ~/api commit -m "$(date) ${DEVICE} update"
ZIP=$(find RR*.zip | tail -1)
md5sum "${ZIP}" >"${ZIP}".md5sum
changelog=${ZIP/.zip/-changelog.txt}
sudo mkdir -pv /home/maintainers/downloads.resurrectionremix.com/"${DEVICE}"
cp -v "${ZIP}" /home/maintainers/downloads.resurrectionremix.com/"${DEVICE}"/
cp -v "${ZIP}".md5sum /home/maintainers/downloads.resurrectionremix.com/"${DEVICE}"/
cp -v "${changelog}" /home/maintainers/downloads.resurrectionremix.com/"${DEVICE}"/
git -C ~/api push git@github.com:ResurrectionRemix-Devices/api
