#!/usr/bin/env bash

# The branch you want to change to
BRANCH="pie"

# The organizations whose repositories you want to change default branch of
ORG="AOSiP"

# The name of your manifest repository
MANIFEST="platform_manifest"

# List of repositories. Add them manually, or adjust the following command
REPOS=$(curl -s -L https://github.com/${ORG}/${MANIFEST}/raw/${BRANCH}/snippets/aosip.xml | grep "<project" | awk '{print $3}' | awk -F '"' '{print $2}')

for REPO in ${REPOS}; do
    echo "Changing branch for $REPO"
    curl -s -X PATCH -H "Authorization: token ${GITHUB_OAUTH_TOKEN}" -d '{ "name": "'"${REPO}"'", "default_branch": "'"${BRANCH}"'" }' "https://api.github.com/repos/${ORG}/${REPO}"
done
