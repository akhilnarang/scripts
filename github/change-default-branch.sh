#!/usr/bin/env bash

# List of repositories. Add them manually, or adjust the following command
export REPOS=$(curl -s -L https://github.com/AOSiP/platform_manifest/raw/oreo-mr1/snippets/aosip.xml | grep "<project" | awk '{print $3}' | awk -F '"' '{print $2}');

# GitHub API Token - Place your own and don't share it with anyone
export GITHUB_API_TOKEN="";

# The branch you want to change to
export BRANCH="oreo-mr1";

# The organizations whose repositories you want to change default branch of
export ORG="AOSiP";

for r in ${REPOS}; do
    curl -s -X PATCH -H "Authorization: token ${GITHUB_API_TOKEN}" -d '{ "name": "'"$r"'", "default_branch": "'"${BRANCH}"'" }' "https://api.github.com/repos/AOSiP/$r";
done
