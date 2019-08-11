#!/usr/bin/env bash

# Actually install some packages too so this thing isn't useless
while read -r p; do
    "${ANDROID_HOME}"/tools/bin/sdkmanager "${p}"
done < "${1:?}"/android-sdk-minimal.txt
