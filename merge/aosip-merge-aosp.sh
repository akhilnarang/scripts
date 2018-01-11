#!/usr/bin/env bash

AOSIP_PATH=$PWD
bash ~/kronicbot/send_tg.sh "-1001055786180" "Merging in ${NEW_TAG}. Check progress [here](${BUILD_URL})!";
git config --global user.name "Akhil's Lazy Buildbot"
git config --global user.email "jenkins@akhilnarang.me"
git config --global user.signingkey 219187E8

do_not_merge="vendor manifest packages/apps/OmniSwitch packages/apps/OmniStyle \
packages/apps/OwlsNest external/google packages/apps/ThemeInterfacer \
packages/apps/Gallery2 device/qcom external/DUtils packages/apps/DUI \
packages/apps/SlimRecents packages/services/OmniJaws packages/apps/LockClock \
packages/apps/CalendarWidget hardware/qcom/*-caf external/ant-wireless \
external/brctl external/chromium-webview external/connectivity external/busybox \
external/fuse external/exfat external/ebtables external/ffmpeg external/gson \
external/json-c external/libncurses external/libnetfilter_conntrack \
external/libnfnetlink"


for filess in failed success notaosp; do
    rm $filess 2> /dev/null
    touch $filess
done

# AOSiP manifest is setup with repo path first, then repo name, so the path attribute is after 2 spaces, and the path itself within "" in it
for repos in $(grep 'remote="aosip"' ${AOSIP_PATH}/.repo/manifests/snippets/aosip.xml  | awk '{print $2}' | awk -F '"' '{print $2}'); do
    echo -e ""
    if [[ "${do_not_merge}" =~ "${repos}" ]]; then
        echo -e "${repos} is not to be merged";
    else
        echo "$blu Merging $repos $end"
        echo -e ""
        cd $repos;
        if [[ "$repos" == "build/make" ]]; then
            repos="build";
        fi
        git fetch aosip $SRC;
        git checkout $SRC;
        git reset --hard aosip/$SRC;
        git remote rm aosp 2> /dev/null;
        git remote add aosp "${AOSP}/platform/$repos";
        git fetch aosp --quiet --tags;
        if [[ $? -ne 0 ]]; then
            echo "$repos" >> ${AOSIP_PATH}/notaosp
        else
            RANGE=${OLD_TAG}..${NEW_TAG};
            COUNT=$(git rev-list --count ${RANGE});
            echo "Merge ${NEW_TAG} into ${SRC}" >> /tmp/aosip-merge;
            echo "\nCommits in ${TAG}: ($(git rev-list --count ${RANGE}) commits)" >> /tmp/aosip-merge;
            git log --reverse --format="    %s" ${RANGE} >> /tmp/aosip-merge;
            git merge ${NEW_TAG} --no-edit;
            if [[ $? -ne 0 ]]; then
                echo "$repos" >> ${AOSIP_PATH}/failed
                echo "$red $repos failed :( $end"
            else
                if [[ "$(git rev-parse HEAD)" != "$(git rev-parse aosip/${SRC})" ]]; then
                    echo "$repos" >> ${AOSIP_PATH}/success
                    git commit -as --amend --no-edit;
                    echo "$grn $repos succeeded $end"
                else
                    echo "$repos - unchanged";
                fi
            fi
        fi
        echo -e ""
        cd ${AOSIP_PATH};
    fi
done

bash ~/kronicbot/send_tg.sh "-1001055786180" "Failed repos:";
bash ~/kronicbot/send_tg.sh "-1001055786180" "$(cat $AOSIP_PATH/failed)";