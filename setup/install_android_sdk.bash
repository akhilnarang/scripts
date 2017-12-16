#!/usr/bin/env bash

# Script to setup the Android SDK on a Linux System

tools_url="https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip"
zip_name=$(printf '%s\n' "${tools_url##*/}")
mkdir -p ~/Android/Sdk/ && cd ~/Android/Sdk
wget $tools_url
[ $? -eq 0 ] && unzip $zip_name || exit 1
rm $zip_name
echo 'export ANDROID_HOME=~/Android/Sdk' >> ~/.bashrc
export ANDROID_HOME=~/Android/Sdk
yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses
