#!/usr/bin/env bash

# Script to setup environment for crowdin
# shellcheck disable=SC1010

# Install crowdin-cli
wget https://artifacts.crowdin.com/repo/deb/crowdin3.deb -O crowdin.deb
sudo dpkg -i crowdin.deb
echo "crowdin-cli installed"
echo ""

# Test crowdin-cli
echo "Your crowdin version:"
crowdin --version