#!/usr/bin/env bash

# A gerrit script to create projects based on ROMs manifest

# Just change these 4 variables

# If you're pushing from the server where Gerrit is hosted, let it be as it is
# Else point to the Gerrit server, the IP, or probably review/gerrit.domain.tld
# If your gerrit username is not the user you're running this script as, then prefix this with gerritusername@
GERRIT_HOST="localhost"

# The port on which Gerrit is running [the port you filled in the the sshd listen address while setting up]
GERRIT_PORT="29418"

# Incase your repo name and names in manifest are different

GERRIT_PROJECT_PREFIX="AOSIP/"

# Might need slight modifications
# For AOSiP the format is <project name path remote>.
# Depending on yours the path and the awks will have to be ajusted.
GERRIT_PROJECT_NAMES="$(grep 'aosip' ~/nougat-mr2/.repo/manifests/snippets/aosip.xml | awk '{print $3}' | awk -F'"' '{print $2}' | uniq)"

# Push everything!
for PROJECT_NAME in ${GERRIT_PROJECT_NAMES}
do
    echo "Creating ${GERRIT_PROJECT_PREFIX}${PROJECT_NAME}"
    ssh -p${GERRIT_PORT} ${GERRIT_HOST} gerrit create-project ${GERRIT_PROJECT_PREFIX}${PROJECT_NAME}
done
