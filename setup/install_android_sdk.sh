#!/usr/bin/env bash

# Script to setup the Android SDK on a Linux System
CUR_DIR="$(cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" && pwd)"
CUR_DIR="${CUR_DIR/setup/}"
SDK_DIR="${HOME}/Android/Sdk"
TOOLS_URL="https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip"
ZIP_NAME=sdk.zip
mkdir -p "${SDK_DIR}"/
cd /tmp/ || exit 1
if axel -a -n 10 "${TOOLS_URL}" -o "${ZIP_NAME}"  || wget "${TOOLS_URL}" -O "${ZIP_NAME}"; then
    unzip -o "${ZIP_NAME}" -d "${SDK_DIR}" && rm "${ZIP_NAME}"
else
    exit 1
fi

# Create repositories.cfg if not present
if [ ! -f ~/.android/repositories.cfg ] ; then
    touch ~/.android/repositories.cfg
fi

if [ -z "${ANDROID_HOME}" ]; then
    printf "\nexport ANDROID_HOME=%s" "${SDK_DIR}" >> ~/.bashrc
fi
if [ -z "${ANDROID_SDK_ROOT}" ]; then
    printf "\nANDROID_SDK_ROOT=%s" "${SDK_DIR}" >> ~/.bashrc
fi

yes | "${SDK_DIR}"/tools/bin/sdkmanager --licenses

while read -r p; do
    "${SDK_DIR}"/tools/bin/sdkmanager "${p}"
done < "${CUR_DIR}/setup"/android-sdk-minimal.txt

cd "${CUR_DIR}" || exit
