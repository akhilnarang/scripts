#!/usr/bin/env bash

# A github script to push all repositories from a manifest

# This again, will have to be adapted based on your setup.

cwd=$PWD
PROJECTS="$(grep 'aosip' .repo/manifests/aosip.xml | awk '{print $2}' | awk -F'"' '{print $2}' | uniq | grep -v caf)"
for project in ${PROJECTS}; do
    cd "$project" || exit
    git push git@github.com:AOSIP/"$(git remote -v | head -n1 | awk '{print $2}' | sed 's/.*\///' | sed 's/\.git//')".git HEAD:refs/heads/nougat-mr2
    cd - || exit
done
cd "$cwd" || exit
