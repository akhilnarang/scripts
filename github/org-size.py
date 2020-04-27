#!/usr/bin/env python3

from humanize import naturalsize
from requests import get
from os import getenv

GITHUB_OAUTH_TOKEN = getenv("GITHUB_OAUTH_TOKEN")

if GITHUB_OAUTH_TOKEN is None:
    GITHUB_OAUTH_TOKEN = input(
        "Enter your Github API token or try without one, which may result in you getting rate-limited soon: "
    )

headers = {"Authorization": "token " + GITHUB_OAUTH_TOKEN}

org = input("Enter organization name: ")

org_size = []
repo_count = 0
response = get(f"https://api.github.com/orgs/{org}/repos", headers=headers)
while True:
    for repo in response.json():
        org_size.append(int(repo["size"]))
        repo_count += 1
    try:
        response = get(response.links["next"]["url"], headers=headers)
    except KeyError:
        break

total = sum(org_size * 1024)
print(f'{org} has {repo_count} repositories which sum up to {naturalsize(total)}')
