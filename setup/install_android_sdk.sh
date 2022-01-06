#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <me@msfjarvis.dev>
# SPDX-License-Identifier: GPL-3.0-only

trap 'rm -rf /tmp/tools.zip 2>/dev/null' INT TERM EXIT

CUR_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
CUR_DIR="${CUR_DIR/setup/}"
SDK_TOOLS=commandlinetools-linux-7583922_latest.zip

function setup_android_sdk() {
    echo "Installing Android SDK"
    SDK_DIR="${HOME:?}/Android/Sdk"
    mkdir -p "${SDK_DIR}"
    if [ ! -f "${SDK_TOOLS}" ]; then
        wget https://dl.google.com/android/repository/"${SDK_TOOLS}" -O /tmp/tools.zip
    fi
    unzip -qo /tmp/tools.zip -d "${SDK_DIR}"
    while read -r package; do
        yes | "${SDK_DIR}"/cmdline-tools/bin/sdkmanager --sdk_root="${SDK_DIR}" "${package:?}"
    done < "${CUR_DIR}"/setup/android-sdk-minimal.txt
    rm /tmp/tools.zip
    cd - || exit
}

setup_android_sdk
