#!/usr/bin/env bash

set -e

# Clone the repository
git clone "${REPO_LINK}" -b "${REPO_BRANCH}" --verbose --progress "${REPO_NAME}"

# Change directory
cd "${REPO_NAME}"

# Checkout to the desired branch
git checkout "${REPO_BRANCH}"

# Create the repository on Gerrit if it doesn't already exist
if ! ssh -p29418 review.aosip.dev gerrit ls-projects | grep -q "${REPO_NAME}"; then
    ssh -p29418 review.aosip.dev gerrit create-project "${ORG}/${REPO_NAME}" -p "${PARENT-All-Projects}"
fi

# Create the repository on GitHub if it doesn't already exist
if ! curl --silent --header --fail --output /dev/null "Authorization: ${GITHUB_OAUTH_TOKEN:?}" https://api.github.com/repos/"$ORG"/"$REPO_NAME"; then
    curl --silent -H "Authorization: GITHUB_OAUTH_TOKEN" -d '{ "name": "'"${REPO_NAME}"'" }' "https://api.github.com/orgs/${ORG}/repos"
fi

git push ssh://review.aosip.dev:29418/"${ORG}"/"${REPO_NAME}" HEAD:refs/heads/"${BRANCH}" --verbose --progress --force
