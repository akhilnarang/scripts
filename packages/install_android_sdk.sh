#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <me@msfjarvis.dev>
# SPDX-License-Identifier: GPL-3.0-only
SDK_DIR="/root/Android/Sdk"

function setup_android_sdk() {

	SDK_TOOLS=commandlinetools-linux-7583922_latest.zip

	trap 'rm -rf /tmp/tools.zip 2>/dev/null' INT TERM EXIT

	CUR_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
	CUR_DIR="${CUR_DIR/packages/}"

    echo "Installing Android SDK"
    mkdir -p "${SDK_DIR}"
    if [ ! -d "${SDK_TOOLS}" ]; then
        wget https://dl.google.com/android/repository/"${SDK_TOOLS}" -O /tmp/tools.zip
    
		unzip -qo /tmp/tools.zip -d "${SDK_DIR}"
		while read -r package; do
			yes | "${SDK_DIR}"/cmdline-tools/bin/sdkmanager --sdk_root="${SDK_DIR}" "${package:?}"
		done < "${CUR_DIR}"/packages/android-sdk-minimal.txt
		rm /tmp/tools.zip
	fi
	
    cd - || exit
	
	mv $SDK_DIR/cmdline-tools $SDK_DIR/latest
	mkdir -p $SDK_DIR/cmdline-tools
	cp -R $SDK_DIR/latest $SDK_DIR/cmdline-tools
	rm -rf $SDK_DIR/latest
}

# Check if sdk already installed
if [ ! -d "${SDK_DIR}" ]; then
	setup_android_sdk
else
	echo "###############################################"
	echo "Already installed."
	echo "###############################################"
fi