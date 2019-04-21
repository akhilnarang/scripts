#!/usr/bin/python3

import os
import json

commits = []
patchsets = []
query='status:open topic:translations'
gerrit='review.aosiprom.com'
action='--submit'
code_review='+2'
verified='+1'

print('Fetching data')
data=os.popen(f'ssh -p29418 {gerrit} gerrit query {query} --patch-sets --format=JSON').read()
data=data.split('\n')

print('Parsing data')
for line in data[:-2]:
    t = json.loads(line)
    commits.append(t['number'])
    patchsets.append(len(t['patchSets']))

for f in range(len(commits)):
    print(f'Working on commit {commits[f]}')
    os.system(f'ssh -p29418 {gerrit} gerrit review --code-review={code_review} --verified={verified}  {commits[f]},{patchsets[f]} {action}')
