#!/usr/bin/env bash

if [ -z "$1" ];
then
export BRANCH="nougat"
else
export BRANCH="$1"
fi

export AOSIP_SOURCE_DIR="${HOME}/aosip"
export DIR=$PWD

cd ${AOSIP_SOURCE_DIR}

PROJECTS="$(grep aosip .repo/manifests/manifests/aosip.xml | awk '{print $3}' | awk -F'"' '{print $2}')"


for project in ${PROJECTS}; do
cd $project;
git push $(git remote -v | head -1 | awk '{print $2}' | sed -e 's/https:\/\/github.com\/AOSiP/ssh:\/\/localhost:29418\/AOSIP/') HEAD:nougat;
cd -;
done

cd ${DIR}
