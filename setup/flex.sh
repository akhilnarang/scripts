#!/usr/bin/env bash

cd /tmp || exit 1
git clone git://github.com/akhilnarang/flex.git
cd flex || exit 1
./autogen.sh
./configure
make -j"$(nproc)"
sudo make install
rm -rf "${PWD}"
cd - || exit 1
