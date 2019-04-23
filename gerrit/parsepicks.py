#!/usr/bin/env python3
import json
import os
import sys

import requests


def query_changes(query):
    changes = os.popen(f'ssh -p29418 review.aosiprom.com gerrit query "{query}" --format=JSON')
    changes = changes.read().split('\n')[:-2]
    ret = ""
    for line in changes:
        ret += json.loads(line)['subject'] + '\n'
    return ret

DOGBIN = 'https://del.dog'
API = os.path.join(DOGBIN, 'documents')

picks = sys.argv[1].split('|')
commits = ""

for i in picks:
    if i.split(' ')[0] == '-t':
        for j in i.split(' '):
            if j not in ('', '-t', 'sysserv-pie'):
                commits += query_changes(f'status:open {j}')
    else:
        for j in i.strip().split(' '):
            if '-' in j:
                commitrange = j.split('-')
                changes = range(int(commitrange[0]), int(commitrange[1]))
                for change in changes:
                    commits += query_changes(change)
            else:
                commits += query_changes(j)

print(f"{DOGBIN}/{json.loads(requests.post(API, commits).content.decode())['key']}")
