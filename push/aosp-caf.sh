#!/usr/bin/env bash

# Script to push all AOSP-CAF repos (or any other ROMs) to GitHub based on the list of repositories in manifest

if [ -z "$1" ]
then
export BRANCH="n-mr1"
else
export BRANCH="$1"
fi

export AOSP-CAF_SOURCE_DIR="${HOME}/caf"
export DIR=$PWD

cd ${AOSP-CAF_SOURCE_DIR}

PROJECTS="$(grep aosp-caf .repo/manifests/manifests/caf.xml | awk '{print $3}' | awk -F'"' '{print $2}')"


for project in ${PROJECTS}; do
cd $project
git push $(git remote -v | grep aosp-caf | head -1 | awk '{print $2}' | sed -e 's/https:\/\//ssh:\/\/git@/') HEAD:n-mr1
cd -
done

cd ${DIR}
