#!/usr/bin/env bash

# Script to setup the Android SDK on a Linux System
SCRIPT_DIR="$(cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd)"
TOOLS_URL="https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip"
ZIP_NAME=$(printf '%s\n' "${TOOLS_URL##*/}")
mkdir -p ~/Android/Sdk/; cd ~/Android/Sdk || exit 1
axel -a -n 10 "${TOOLS_URL}"
[ "${?}" -eq 0 ] && unzip "${ZIP_NAME}" || exit 1
rm "${ZIP_NAME}"
echo 'export ANDROID_HOME=~/Android/Sdk' >> ~/.bashrc
source ~/.bashrc
yes | "${ANDROID_HOME}"/tools/bin/sdkmanager --licenses

source "${SCRIPT_DIR}"/setup_android_sdk_packages.bash "${SCRIPT_DIR}"