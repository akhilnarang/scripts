#!/usr/bin/env bash

# Script to push all AOSiP repositories

if [ -z "$1" ];
then
export BRANCH="nougat-mr2"
else
export BRANCH="$1"
fi

export AOSIP_SOURCE_DIR="${HOME}/nougat"
export DIR=$PWD

cd ${AOSIP_SOURCE_DIR}

PROJECTS="$(grep aosip .repo/manifests/snippets/aosip.xml | awk '{print $2}' | awk -F'"' '{print $2}')"


for project in ${PROJECTS}; do
cd $project;
#git push $(git remote -v | head -1 | awk '{print $2}' | sed -e 's/https:\/\/github.com\/AOSiP/ssh:\/\/localhost:29418\/AOSIP/') HEAD:nougat;
git push aosip ${BRANCH};
cd -;
done

cd ${DIR}
