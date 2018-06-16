#!/usr/bin/env bash

# A gerrit script to push all repositories from a manifest

# This again, will have to be adapted based on your setup.

cwd=$PWD
cd ~/nougat
PROJECTS="$(grep 'aosip' .repo/manifests/snippets/aosip.xml  | awk '{print $2}' | awk -F'"' '{print $2}' | uniq | grep -v caf)"
for project in ${PROJECTS}
do
    cd $project
    git push $(git remote -v | head -1 | awk '{print $2}' | sed -e 's/https:\/\/github.com\/AOSiP/ssh:\/\/localhost:29418\/AOSIP/') HEAD:refs/heads/nougat-mr2
    cd -
done
cd $cwd
