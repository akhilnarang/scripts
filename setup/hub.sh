#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

function get_release_assets () {
    local REPOSITORY RELEASE_TAG RELEASE_ID TMP_FILE;
    REPOSITORY="${1:?}";
    RELEASE_TAG="${2:-latest}";
    TMP_FILE="$(mktemp)";
    if [ "${RELEASE_TAG}" == "latest" ]; then
        RELEASE_ID=$(curl --silent "https://api.github.com/repos/${1:?}/releases/latest" | # Get the latest release from GitHub API
        jq -r .id);
    else
        curl --silent "https://api.github.com/repos/${REPOSITORY}/releases" | jq '.[] | {id: .id, name: .tag_name}' > "${TMP_FILE}";
        RELEASE_ID=$(jq -r '"\(.id) \(.name)"' "${TMP_FILE}" | grep "${RELEASE_TAG}" | awk '{print $1}');
    fi;
    curl --silent "https://api.github.com/repos/${REPOSITORY}/releases/${RELEASE_ID}" | jq -r .assets[].browser_download_url;
    [ -f "${TMP_FILE}" ] && rm -f "${TMP_FILE}"
}

function get_latest_release {
  curl --silent "https://api.github.com/repos/${1:?}/releases/latest" | # Get latest release from GitHub API
    jq -r .tag_name                                                 # Get tag line
}

function install_hub {
    local INSTALLED_VERSION HUB HUB_ARCH CL_YLW CL_RST
    CL_YLW='\033[01;33m'
    CL_RST='\033[0m'
    echo "Checking and installing hub"
    HUB="$(command -v hub)"
    HUB_ARCH=linux-amd64
    if [ -z "${HUB}" ]; then
        aria2c "$(get_release_assets github/hub | grep ${HUB_ARCH})" -o hub.tgz || wget "$(get_release_assets github/hub | grep ${HUB_ARCH})" -O hub.tgz
        mkdir -p hub
        tar -xf hub.tgz -C hub
        sudo ./hub/*/install --prefix=/usr/local/
        rm -rf hub/ hub.tgz
    else
        INSTALLED_VERSION="v$(hub --version | tail -n1 | awk '{print $3}')"
        LATEST_VERSION="$(get_latest_release github/hub)"
        if [ "${INSTALLED_VERSION}" != "${LATEST_VERSION}" ]; then
            echo -e "${CL_YLW} Outdated version of hub detected, upgrading${CL_RST}"
            wget "$(get_release_assets github/hub | grep ${HUB_ARCH})" -O=hub.tgz
            mkdir -p hub
            tar -xf hub.tgz -C hub
            sudo ./hub/*/install --prefix=/usr/local/
            rm -rf hub/ hub.tgz
        else
            echo -e "${CL_YLW}hub ${INSTALLED_VERSION} is already installed!${CL_RST}"
        fi
    fi
}

[[ $(command -v jq) ]] && install_hub || echo "Please install jq"
