#!/usr/bin/env bash

#COLORS -
red=$'\e[1;31m'
grn=$'\e[1;32m'
blu=$'\e[1;34m'
end=$'\e[0m'


# Assumes source is in users home in a directory called "caf"
export AOSP-CAF_PATH="${HOME}/caf"

# Set the tag you want to merge
export TAG="LA.UM.5.7.r1-08900-8x98.0"

# Set the base URL for all repositories to be pulled from
export CAF="https://source.codeaurora.org"

do_not_merge="device/qcom/common external/ant-wireless/antradio-library external/bash external/busybox external/connectivity external/exfat external/fuse external/ntfs-3g hardware/qcom/bt hardware/qcom/bt-caf hardware/qcom/keymaster hardware/qcom/wlan hardware/qcom/wlan-caf hardware/ril hardware/ril-caf vendor/aosp vendor/qcom/opensource/softap"

vendor_repos="vendor/qcom/opensource/dataservices vendor/qcom/opensource/dpm vendor/qcom/opensource/fm"

# AOSP-CAF manifest is setup with repo name first, then repo path, so the path attribute is after 3 spaces, and the path itself within "" in it
repos="$(grep 'remote="aosp-caf"' ${AOSP-CAF_PATH}/.repo/manifests/manifests/caf.xml  | awk '{print $3}' | awk -F '"' '{print $2}')"

cd ${AOSP-CAF_PATH}

for filess in failed success; do
	rm $filess 2> /dev/null
	touch $filess
done

for REPO in ${repos}; do
	echo -e ""
	if [[ "${do_not_merge}" =~ "${REPO}" ]]; then
		echo -e "${REPO} is not to be merged";
	else
		echo "$blu Merging $REPO $end"
		echo -e ""
		cd $REPO;
		git checkout n-mr1
		git fetch aosp-caf n-mr1
		git reset --hard aosp-caf/n-mr1
		git remote rm caf 2> /dev/null
		if [[ "${REPO}" == "device/qcom/sepolicy" ]]; then
			reponame="${CAF}/${REPO}";
		elif [[ "${REPO}" =~ "${vendor_repos}" ]]; then
			reponame="${CAF}/$(echo ${REPO} | sed -e 's/qcom\/opensource/qcom-opensource/')";
		else
			reponame="${CAF}/platform/$REPO";
		fi
		git remote add caf "${reponame}";
		git fetch caf --quiet --tags;
		git merge ${TAG} --no-edit;
		if [ $? -ne 0 ]; then
			echo "$REPO" >> ${AOSP-CAF_PATH}/failed
			echo "$red $REPO failed :( $end"
		else
			echo "$REPO" >> ${AOSP-CAF_PATH}/success
			echo "$grn $REPO succeeded $end"
		fi
		echo -e ""
		cd ${AOSP-CAF_PATH};
	fi
done

echo -e ""
echo -e "$red These REPO failed $end"
cat ./failed
echo -e ""
echo -e "$grn These succeeded $end"
cat ./success


