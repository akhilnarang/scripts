#!/usr/bin/env bash

# Script to merge translations on Gerrit
# We assume sanely that's there only 1 patchset per commit
# And that they're all under topic:translations

GERRIT_HOST="review.aosiprom.com"
QUERY="topic:translations status:open"
PORT="29418"
COMMITS=$(ssh -p${PORT} ${GERRIT_HOST} gerrit query ${QUERY} | grep number \
		| cut -d: -f2)
for COMMIT in ${COMMITS}; do
	ssh -p29418 ${GERRIT_HOST} gerrit review ${COMMIT},1 --code-review=+2 \
  		--verified=+1 --submit
done
