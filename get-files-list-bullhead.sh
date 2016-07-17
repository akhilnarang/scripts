#!/bin/bash
curl https://sourceforge.net/projects/thuglife/files/bullhead/ | grep "https://sourceforge.net/projects/thuglife/files/bullhead/thuglife-bullhead-" | awk '{print $2}' | cut -d'"' -f2 | cut -d'/' -f8

