#!/usr/bin/env bash

if [ -z "$1" ];
then
export BRANCH="staging/nougat"
else
export BRANCH="$1"
fi

export RRO_SOURCE_DIR="${HOME}/rro"
export DIR=$PWD

cd ${RRO_SOURCE_DIR}

for repos in $(grep 'remote="rro"' ${RRO_SOURCE_DIR}/manifest/default.xml  | awk '{print $2}' | cut -d'"' -f2); do
echo -e "Deleting $BRANCH from $repos";
cd $repos;
git push rro :$BRANCH;
cd ${RRO_SOURCE_DIR}
done

cd ${DIR}
