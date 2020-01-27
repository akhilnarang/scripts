#!/usr/bin/env bash

BRANCH="mp1-v9.2"
BASE="$(pwd)/"
ORG="exconfidential/t-alps-release-q0/sauce"

function push() {
    cd "${1:?}" || return
    git init;
    git add -A;
    git commit -m 'Initial commit' -q;
    git push git@gitlab.com:$ORG/$(pwd | sed "s|$BASE||;s|/|_|g").git HEAD:refs/heads/"${BRANCH}"
    rm -rf "${PWD}"
    cd - || return
}

while read -r project; do push "$project"; done < projects.txt

git init;
git add -A;
git commit -m 'Initial commit' -q;
git push git@gitlab.com:exconfidential/t-alps-release-q0/sauce/source_root.git HEAD:refs/heads/$BRANCH;
