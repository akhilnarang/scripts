#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

CUR_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
CUR_DIR="${CUR_DIR/setup/}"
SDK_TOOLS=commandlinetools-linux-6200805_latest.zip

function setup_android_sdk() {
    echo "Installing Android SDK"
    mkdir -p "${HOME:?}"/Android/Sdk
    cd "${HOME}"/Android/Sdk || return 1
    if [ ! -f "${SDK_TOOLS}" ]; then
        aria2c https://dl.google.com/android/repository/"${SDK_TOOLS}"
    fi
    unzip -qo "${SDK_TOOLS}"
    while read -r package; do
        yes | ./tools/bin/sdkmanager --sdk_root="$(pwd)" "${package:?}"
    done < "${CUR_DIR}"/setup/android-sdk-minimal.txt
    rm "${SDK_TOOLS}"
    cd - || exit
}

setup_android_sdk
