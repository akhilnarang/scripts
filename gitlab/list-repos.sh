#!/usr/bin/env bash

PROJECT_ID=6775874

curl "https://gitlab.com/api/v4/groups/${PROJECT_ID}/projects" -H "Authorization: Bearer ${GITLAB_TOKEN}" -G -d per_page=100
