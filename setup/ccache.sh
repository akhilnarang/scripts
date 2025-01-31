#!/usr/bin/env bash

cd /tmp || exit 1
git clone https://github.com/ccache/ccache.git
cd ccache || exit 1
mkdir -p build && cd build || exit 1
cmake -DHIREDIS_FROM_INTERNET=ON -DZSTD_FROM_INTERNET=ON -DCMAKE_BUILD_TYPE=Release ..
make -j"$(nproc)"
sudo make install
rm -rf "${PWD}"
cd - || exit 1
