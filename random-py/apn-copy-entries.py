#!/usr/bin/env python

import sys
from pathlib import Path
from xml.etree import ElementTree

# ./apn-copy-entries.py source.xml destination.xml
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

tags_to_match = ("mcc", "mnc")
tags_to_copy = ("apn")

destination_root = destination_apn_xml.getroot()

combinations = set()

# Define a function to check if a child element is already in the destination root
def is_in_destination(child, destination_root):
    for dest_child in destination_root:
        if child.attrib == dest_child.attrib:
            return True
    return False

# Modify the loop that appends children from the source to the destination
for child in source_apn_xml.getroot():
    # Only consider children with apn='ims'
    if child.attrib.get('apn') == 'ims':
        # Only append the child if it is not already in the destination
        if not is_in_destination(child, destination_root):
            destination_root.append(child)

destination_apn_xml.write(destination, encoding="utf-8")
