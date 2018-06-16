#!/usr/bin/env bash

# A gerrit script to change the merge type of all repositories

# Just change these 4 variables

# If you're pushing from the server where Gerrit is hosted, let it be as it is
# Else point to the Gerrit server, the IP, or probably review/gerrit.domain.tld
# If your gerrit username is not the user you're running this script as, then prefix this with gerritusername@
GERRIT_HOST="localhost"

# The port on which Gerrit is running [the port you filled in the the sshd listen address while setting up]
GERRIT_PORT="29418"

GERRIT_PROJECT_NAMES="$(ssh -p${GERRIT_PORT} ${GERRIT_HOST} gerrit ls-projects)"

# Must be one of FAST_FORWARD_ONLY|MERGE_IF_NECESSARY|REBASE_IF_NECESSARY|MERGE_ALWAYS|CHERRY_PICK
# Check your gerritsite/Documentation/project-configuration.html#submit_type to decide which
SUBMIT_TYPE="REBASE_IF_NECESSARY"

# Do it!
for PROJECT_NAME in ${GERRIT_PROJECT_NAMES}
do
    echo "Changing ${PROJECT_NAME} submit type to ${SUBMIT_TYPE}"
    ssh -p${GERRIT_PORT} ${GERRIT_HOST} gerrit set-project ${PROJECT_NAME} -t ${SUBMIT_TYPE}
done
