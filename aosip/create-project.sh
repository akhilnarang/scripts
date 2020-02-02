#!/usr/bin/env bash
source ~/scripts/functions
echo "Cloning repository"
git clone "${REPO_LINK}" -b "${REPO_BRANCH}" --verbose --progress
ssh -p29418 review.aosip.dev gerrit create-project "${ORG}/${REPO_NAME}" -p All-Projects -t REBASE_IF_NECESSARY
curl -s -H "Authorization: token ${GITHUB_OAUTH_TOKEN:?}" -d '{ "name": "'"${REPO_NAME}"'" }' "https://api.github.com/orgs/${ORG}/repos"
git checkout "${REPO_BRANCH}"
git push ssh://review.aosiprom.com:29418/"${ORG}"/"${REPO_NAME}" HEAD:refs/heads/"${BRANCH}" --verbose --progress
sendAOSiP "Created and pushed \`$ORG/$REPO_NAME\`"
