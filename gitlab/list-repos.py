#!/usr/bin/env python3

from os import getenv
from requests import get

PROJECT_ID = 6775874

headers = {"Authorization": f"Bearer {getenv('GITLAB_TOKEN')}"}

data = {"per_page": 100}

repos = []

response = get(
    f"https://gitlab.com/api/v4/groups/{PROJECT_ID}/projects",
    data=data,
    headers=headers,
)
while True:
    for repo in response.json():
        repos.append(repo["path"])
    try:
        response = get(response.links["next"]["url"], data=data, headers=headers)
    except KeyError:
        break

print(*repos)
