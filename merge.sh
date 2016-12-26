#!/usr/bin/env bash

device="bacon"
cd $KERNELDIR/$device
git reset --hard origin/n7x && git checkout n7x
mergeremote=$(cat upstream | awk '{print $1}')
mergebranch=$(cat upstream | awk '{print $2}')
git fetch $mergeremote $mergebranch
git merge $mergeremote/$mergebranch -S
