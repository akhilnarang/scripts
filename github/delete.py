#!/usr/bin/env python3

from requests import get, delete
from os import getenv

GITHUB_OAUTH_TOKEN = getenv("GITHUB_OAUTH_TOKEN")

if GITHUB_OAUTH_TOKEN is None:
    GITHUB_OAUTH_TOKEN = input("Enter your Github API token: ")

headers = {"Authorization": "token " + GITHUB_OAUTH_TOKEN}

org = input("Enter organization name: ")


response = get(f"https://api.github.com/orgs/{org}/repos", headers=headers)
while True:
    for repo in response.json():
        print(f"Working on {repo['name']}")
        delete(
            f"https://api.github.com/repos/{org}/{repo['name']}",
            headers=headers,
        )
    try:
        response = get(response.links["next"]["url"], headers=headers)
    except KeyError:
        break
