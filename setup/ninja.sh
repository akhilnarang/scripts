#!/usr/bin/env bash

cd /tmp || exit 1
git clone git://github.com/akhilnarang/ninja.git
cd ninja || exit 1
./configure.py --bootstrap
sudo install ./ninja /usr/local/bin/ninja
rm -rf "${PWD}"
cd - || exit 1
