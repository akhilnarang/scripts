#!/usr/bin/env python3
import json
import os
import requests
import sys

DOGBIN = 'https://del.dog'
API = os.path.join(DOGBIN, 'documents')

picks = sys.argv[1].split('|')
commits = ""

for i in picks:
    if i.split(' ')[0] == '-t':
        for j in i.split(' '):
            if j != '' and j != '-t' and j != 'sysserv-pie':
                data = os.popen(f'ssh -p29418 review.aosiprom.com gerrit query "status:open topic:{j}" --format=JSON').read()
                for line in data.split('\n')[:-2]:
                    commits += (json.loads(line)['subject']) + '\n'
    else:
        for j in i.strip().split(' '):
            if '-' in j:
                commitrange=j.split('-')
                changes=range(int(commitrange[0]), int(commitrange[1]))
                for change in changes:
                    data = os.popen(f'ssh -p29418 review.aosiprom.com gerrit query {change} --format=JSON').read()
                    for line in data.split('\n')[:-2]:
                        commits += (json.loads(line)['subject']) + '\n'
            else:
                data = os.popen(f'ssh -p29418 review.aosiprom.com gerrit query {j} --format=JSON').read()
                for line in data.split('\n')[:-2]:
                    commits += (json.loads(line)['subject']) + '\n'

print(f"{DOGBIN}/{json.loads(requests.post(API, commits).content.decode())['key']}")