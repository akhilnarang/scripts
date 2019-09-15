#!/usr/bin/env python3
import json
import os
import sys

import requests

DOGBIN = 'https://del.dog'
DOGBIN_API = os.path.join(DOGBIN, 'documents')
GERRIT = 'https://review.aosiprom.com'
GERRIT_API = os.path.join(GERRIT, 'changes/?q=')


def query_changes(query):
    changes = requests.get(GERRIT_API+query).text[5:]
    ret = ""
    for line in json.loads(changes):
        ret += line['subject'] + '\n'
    return ret

def main():
    if len(sys.argv) != 2:
        print('No picks included')
        exit(1)

    picks = sys.argv[1].split('|')
    commits = ""

    for i in picks:
        if i.strip().split(' ')[0] == '-t':
            for j in i.split(' '):
                if j not in ('', '-t', 'sysserv-pie'):
                    commits += query_changes('status:open topic:{}'.format(j))
        else:
            for j in i.strip().split(' '):
                if '-' in j:
                    commitrange = j.split('-')
                    try:
                        changes = range(int(commitrange[0]), int(commitrange[1]))
                    except ValueError:
                        continue
                    for change in changes:
                        commits += query_changes(str(change))
                else:
                    commits += query_changes(str(j))

    print("{}/{}".format(DOGBIN, json.loads(requests.post(DOGBIN_API, commits).content.decode())['key']))

if __name__ == '__main__':
    main()
