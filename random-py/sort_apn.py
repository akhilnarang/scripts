#!/usr/bin/env python

import sys
from pathlib import Path
from xml.etree import ElementTree

# ./sort_apn.py apns-conf.xml
# If no arguments are provided, the user will be prompted to enter the file paths

if len(sys.argv) < 2:
    apns = input("Enter the apns-conf XML path: ")
else:
    apns = sys.argv[1]

apns_path = Path(apns)

if not apns_path.exists():
    print("Please ensure that the files exist")
    sys.exit(1)

def sort_apns(apns_path):
    # Parse the XML file into an ElementTree
    tree = ElementTree.parse(apns_path)
    root = tree.getroot()

    # Sort the children of the root by 'mcc' and 'mnc'
    root[:] = sorted(root, key=lambda child: (child.attrib.get('mcc', ''), child.attrib.get('mnc', '')))

    # Write the sorted ElementTree back into the XML file
    with open(apns_path, 'wb') as f:
        f.write(ElementTree.tostring(root, encoding='utf-8'))

# Call the function with the XML file path
sort_apns(apns_path)
