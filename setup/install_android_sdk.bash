#!/usr/bin/env bash

if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
    echo "This script relies on information from your environment and thus should be sourced."
    exit 1
fi

# Script to setup the Android SDK on a Linux System
CUR_DIR="$(cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd)"
CUR_DIR="${CUR_DIR/setup/}"
TOOLS_URL="https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip"
ZIP_NAME=$(printf '%s\n' "${TOOLS_URL##*/}")
mkdir -p ~/Android/Sdk/; cd ~/Android/Sdk || exit 1
if axel -a -n 10 "${TOOLS_URL}"; then
    unzip -o "${ZIP_NAME}"
else
    exit 1
fi
# Create repositories.cfg if not present
if [ ! -f ~/.android/repositories.cfg ] ; then
    touch ~/.android/repositories.cfg
fi
rm "${ZIP_NAME}"
printf '\nexport ANDROID_HOME=~/Android/Sdk' >> ~/.bashrc
source ~/.bashrc
yes | "${ANDROID_HOME}"/tools/bin/sdkmanager --licenses

source "${CUR_DIR}"/setup/setup_android_sdk_packages.bash "${CUR_DIR}/setup"
cd "${CUR_DIR}"