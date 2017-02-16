#!/bin/bash
tools_url="https://dl.google.com/android/repository/tools_r25.2.3-linux.zip"
zip_name=$(printf '%s\n' "${tools_url##*/}")
mkdir -p ~/Android/Sdk/ && cd ~/Android/Sdk
wget $tools_url
[ $? -eq 0 ] && unzip $zip_name || exit 1
rm $zip_name
echo 'export ANDROID_HOME=~/Android/Sdk' >> ~/.bashrc
export ANDROID_HOME=~/Android/Sdk
echo "y" | $ANDROID_HOME/tools/android update sdk --no-ui --all --filter android-25
echo "y" | $ANDROID_HOME/tools/android update sdk --no-ui --all --filter extra-android-m2repository
echo "y" | $ANDROID_HOME/tools/android update sdk --no-ui --all --filter extra-google-m2repository
echo "y" | $ANDROID_HOME/tools/android update sdk --no-ui --all --filter build-tools-25.0.2
echo "y" | $ANDROID_HOME/tools/android update sdk --no-ui --all --filter tools
echo "y" | $ANDROID_HOME/tools/android update sdk --no-ui --all --filter platform-tool
echo "y" | $ANDROID_HOME/tools/android update sdk --no-ui --all --filter tools

