#!/usr/bin/env bash

# Script to add a new username to a Linux System

export username="${1}"
if [ -z "${username}" ]
then
echo -e "Please enter a username"
read -r username
fi
sudo useradd "${username}" -m -s /bin/bash
passwd "${username}"
chage -d 0 "${username}"
