#!/usr/bin/env bash

# Script to init RR's crowdin manifest and update translations

mkdir crowdin
cd crowdin
repo init -u ssh://git@github.com/ResurrectionRemix/platform_manifest.git -b nougat -m crowdin.xml
source ${HOME}/android_shell_tools/android_bash.rc
source ${HOME}/.rvm/scripts/rvm
bashsync
time reposy -j8
# export RR_CROWDIN_API_KEY=
./rr_crowdin/crowdin_sync.py -b nougat
