#!/usr/bin/env bash
source ~/.rvm/scripts/rvm
repo init -u git://github.com/AOSiP/platform_manifest.git -b pie -m crowdin.xml --no-tags --current-branch
time repo sync -j8 --force-sync --force-broken --no-tags --current-branch
repo forall -j8 -c "scp -p -P 29418 review.aosiprom.com:hooks/commit-msg .git/hooks/"
./crowdin/sync.py "${@}"
