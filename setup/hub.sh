#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

function get_latest_release {
  curl --silent "https://api.github.com/repos/${1:?}/releases/latest" | # Get latest release from GitHub API
    jq -r .tag_name                                                 # Get tag line
}

function install_hub {
    local INSTALLED_VERSION HUB HUB_ARCH CL_YLW CL_RST
    CL_YLW='\033[01;33m'
    CL_RST='\033[0m'
    echoText "Checking and installing hub"
    HUB="$(command -v hub)"
    HUB_ARCH=linux-amd64
    if [ -z "${HUB}" ]; then
        aria2c "$(get_release_assets github/hub | grep ${HUB_ARCH})" -o hub.tgz
        mkdir -p hub
        tar -xf hub.tgz -C hub
        sudo ./hub/*/install --prefix=/usr/local/
        rm -rf hub/ hub.tgz
    else
        INSTALLED_VERSION="v$(hub --version | tail -n1 | awk '{print $3}')"
        LATEST_VERSION="$(get_latest_release github/hub)"
        if [ "${INSTALLED_VERSION}" != "${LATEST_VERSION}" ]; then
            echo -e "${CL_YLW} Outdated version of hub detected, upgrading${CL_RST}"
            aria2c "$(get_release_assets github/hub | grep ${HUB_ARCH})" -o hub.tgz
            mkdir -p hub
            tar -xf hub.tgz -C hub
            sudo ./hub/*/install --prefix=/usr/local/
            rm -rf hub/ hub.tgz
        else
            echo -e "${CL_YLW}hub ${INSTALLED_VERSION} is already installed!${CL_RST}"
        fi
    fi
}

install_hub
