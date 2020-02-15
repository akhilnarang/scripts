from humanize import naturalsize
from requests import get

org_size = []
for i in range(1, 6):
    url = f"https://api.github.com/orgs/AndroidDumps/repos" \
          f"?page={i}&per_page=100"
    org_data = get(url).json()
    for repo in org_data:
        org_size.append(int(repo["size"]))
total = sum(org_size * 1024)
print(naturalsize(total))