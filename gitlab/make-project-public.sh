#!/usr/bin/env bash

# visibility can be one of 'public', 'private', or 'internal'

PROJECT="exconfidential%2fsprd%2fbuild"

curl -X PUT "https://gitlab.com/api/v4/projects/${PROJECT}" -H "Authorization: Bearer ${GITLAB_TOKEN}" -d "{ 'visibility': 'public' }"
