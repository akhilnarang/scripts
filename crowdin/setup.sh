#!/usr/bin/env bash

# Script to setup environment for crowdin

sudo apt install python-git
curl -sSL https://get.rvm.io | bash -s stable --ruby
rvm all do gem install crowdin-cli

