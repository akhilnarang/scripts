#!/usr/bin/env bash

for repos in $(grep 'remote="rro"' default.xml  | awk '{print $2}' | cut -d'"' -f2); do
echo -e "Pushing $repos";
export RRO_DIR=$PWD;
cd $repos;
git push rro HEAD:nougat;
cd $RRO_DIR;
done
