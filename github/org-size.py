from humanize import naturalsize
from requests import get

org = input("Enter organization name: ")

org_size = []
response = get(f"https://api.github.com/orgs/{org}/repos")
while True:
    for repo in response.json():
        org_size.append(int(repo["size"]))
    try:
        response = get(response.links["next"]["url"])
    except KeyError:
        break

total = sum(org_size * 1024)
print(naturalsize(total))
