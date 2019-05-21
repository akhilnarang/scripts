#!/usr/bin/env bash

# List of repositories. Add them manually, or adjust the following command
REPOS=$(curl -s -L https://github.com/AOSiP/platform_manifest/raw/oreo-mr1/snippets/aosip.xml | grep "<project" | awk '{print $3}' | awk -F '"' '{print $2}')

# GitHub API Token - Place your own and don't share it with anyone
GITHUB_API_TOKEN=""

# The organization where you want to create repositories
ORG="AOSiP"

for r in ${REPOS}; do
    curl -s -X POST -H "Authorization: token ${GITHUB_API_TOKEN}" -d '{ "name": "'"$r"'" }' "https://api.github.com/orgs/${ORG}/repos"
done
