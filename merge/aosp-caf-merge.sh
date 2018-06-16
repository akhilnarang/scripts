#!/usr/bin/env bash

# Script to merge in upstream CAF Tags into AOSP-CAF or other Android ROMs

#COLORS -
red=$'\e[1;31m'
grn=$'\e[1;32m'
blu=$'\e[1;34m'
end=$'\e[0m'


# Assumes source is in users home in a directory called "caf"
export AOSPCAF_PATH="${HOME}/caf"

# Set the tag you want to merge
export TAG="LA.UM.5.8.r1-02000-8x98.0"

# Set the base URL for all repositories to be pulled from
export CAF="https://source.codeaurora.org"

do_not_merge="device/qcom/common external/ant-wireless/antradio-library external/bash external/busybox external/connectivity external/exfat external/fuse external/ntfs-3g hardware/qcom/bt hardware/qcom/bt-caf hardware/qcom/keymaster hardware/qcom/wlan hardware/qcom/wlan-caf hardware/ril hardware/ril-caf vendor/aosp vendor/qcom/opensource/softap"

# AOSP-CAF manifest is setup with repo name first, then repo path, so the path attribute is after 3 spaces, and the path itself within "" in it
repos="$(grep 'remote="aosp-caf"' ${AOSPCAF_PATH}/.repo/manifests/manifests/caf.xml  | awk '{print $3}' | awk -F '"' '{print $2}')"

cd ${AOSPCAF_PATH}

for filess in failed success notcaf; do
	rm $filess 2> /dev/null
	touch $filess
done

for REPO in ${repos}; do
	echo -e ""
	if [[ "${do_not_merge}" =~ "${REPO}" ]]; then
		echo -e "${REPO} is not to be merged"
	else
		echo "$blu Merging $REPO $end"
		echo -e ""
		cd $REPO
		git checkout n-mr2
		git fetch aosp-caf n-mr2
		git reset --hard aosp-caf/n-mr2
		git remote rm caf 2> /dev/null
		if [[ "${REPO}" == "device/qcom/sepolicy" ]]; then
			reponame="${CAF}/${REPO}"
		elif [[ "${REPO}" =~ "vendor/qcom" ]]; then
			reponame="${CAF}/platform/$(echo ${REPO} | sed -e 's|qcom/opensource|qcom-opensource|')"
		else
			reponame="${CAF}/platform/$REPO"
		fi
		git remote add caf "${reponame}"
		git fetch caf --quiet --tags
		if [ $? -ne 0 ]; then
			echo "$repos" >> ${AOSPCAF_PATH}/notcaf
		else
			git merge ${TAG} --no-edit
			if [ $? -ne 0 ]; then
				echo "$REPO" >> ${AOSPCAF_PATH}/failed
				echo "$red $REPO failed :( $end"
			else
				if [[ "$(git rev-parse HEAD)" != "$(git rev-parse aosp-caf/n-mr2)" ]]; then
					echo "$REPO" >> ${AOSPCAF_PATH}/success
					echo "$grn $REPO succeeded $end"
				else
					echo "$REPO - unchanged"
				fi
			fi
			echo -e ""
		fi
			cd ${AOSPCAF_PATH}
	fi
done

echo -e ""
echo -e "$red These REPO failed $end"
cat ./failed
echo -e ""
echo -e "$grn These succeeded $end"
cat ./success


