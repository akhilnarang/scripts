#!/usr/bin/env bash

cd $KERNELDIR/$1
;;
*)
usage;
esac

git reset --hard origin/nougat && git checkout nougat
mergeremote=$(cat upstream | awk '{print $1}')
mergebranch=$(cat upstream | awk '{print $2}')
git fetch $mergeremote $mergebranch
git merge $mergeremote/$mergebranch -S
