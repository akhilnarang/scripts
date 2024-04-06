#!/usr/bin/env python

import sys
from pathlib import Path
from xml.etree import ElementTree

# ./apn.py source.xml destination.xml
# If no arguments are provided, the user will be prompted to enter the file paths

if len(sys.argv) < 3:
    source = input("Enter the source XML path: ")
    destination = input("Enter the destination XML path: ")
else:
    source = sys.argv[1]
    destination = sys.argv[2]

source_path = Path(source)
destination_path = Path(destination)

if not source_path.exists() or not destination_path.exists():
    print("Please ensure that both the files exist")
    sys.exit(1)

source_apn_xml = ElementTree.parse(source_path)
destination_apn_xml = ElementTree.parse(destination_path)

tags_to_match = ("apn", "mcc", "mnc")
tags_to_copy = ("network_type_bitmask", "type")
required_tags = tags_to_match + tags_to_copy

mapping = {}

for child in source_apn_xml.getroot():
    if not all(tag in child.attrib for tag in required_tags):
        continue
    mapping["|".join([child.attrib[tag] for tag in tags_to_match])] = {
        tag: child.attrib[tag] for tag in tags_to_copy
    }


for child in destination_apn_xml.getroot():
    if not all(tag in child.attrib for tag in tags_to_match):
        continue
    key = "|".join([child.attrib[tag] for tag in tags_to_match])
    if key in mapping:
        for tag in tags_to_copy:
            child.attrib[tag] = mapping[key][tag]

destination_apn_xml.write(destination, encoding="utf-8")
