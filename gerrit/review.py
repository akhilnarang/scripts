#!/usr/bin/python3
"""
Script to review a bunch of gerrit commits based on a specified query
"""

# pylint: disable=invalid-name

import os
import json

commits = {}
query = 'topic:dnm-gsi'
gerrit = 'review.aosiprom.com'
action = '--abandon'
code_review = '-2'
verified = '-1'

print('Fetching data')
data = os.popen(f'ssh -p29418 {gerrit} gerrit query {query} --patch-sets --format=JSON').read()
data = data.split('\n')

print('Parsing data')
for line in data[:-2]:
    t = json.loads(line)
    commits[t['number']] = len(t['patchSets'])

for commit, patchset in commits.items():
    print(f'Working on commit {commit}')
    os.system(f'ssh -p29418 {gerrit} gerrit review --code-review={code_review}'
              f' --verified={verified}  {commit},{patchset} {action}')
