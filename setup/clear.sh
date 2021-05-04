#!/usr/bin/env bash

# Copyright (C) 2020 Alexander Koskovich
# SPDX-License-Identifier: GPL-3.0-only

# Master is the only supported branch for now due to the forced removal
# of Python 2 from the repository, this will change once Android 11 releases.

# Build dependencies.
sudo swupd bundle-add AOSP-dev git

# UDEV
echo "Setting up ADB UDEV rules..."
sudo curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules
sudo chmod 644 /etc/udev/rules.d/51-android.rules
sudo chown root /etc/udev/rules.d/51-android.rules
sudo udevadm control --reload-rules

# REPO
echo "Setting up Repo..."
sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://storage.googleapis.com/git-repo-downloads/repo
sudo chmod a+rx /usr/local/bin/repo

echo "You're now ready to start contributing to AOSP!"

echo "Please note, Clear Linux does not have ADB in their repos"
echo "so you will need to download yourself and append to PATH."
