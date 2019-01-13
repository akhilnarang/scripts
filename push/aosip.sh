#!/usr/bin/env bash

# Script to push all AOSiP repositories

if [ -z "$1" ]
then
export BRANCH="oreo-mr1"
else
export BRANCH="$1"
fi

export AOSIP_SOURCE_DIR="/home/akhil/${BRANCH}"
export DIR=$PWD

cd ${AOSIP_SOURCE_DIR}
. build/envsetup.sh

PROJECTS="$(grep aosip .repo/manifests/snippets/aosip.xml | grep project | awk '{print $2}' | awk -F'"' '{print $2}')"


for project in ${PROJECTS}; do
cd $project
#git push $(git remote -v | head -1 | awk '{print $2}' | sed -e 's/https:\/\/github.com\/AOSiP/ssh:\/\/akhil@review.aosiprom.com:29418\/AOSIP/') HEAD:oreo
gerrit
git push gerrit HEAD:refs/heads/${BRANCH}
cd -
done

cd ${DIR}
