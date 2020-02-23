#!/usr/bin/env bash
#    Copy a ssh key to Github
#    Copyright (C) 2015 Christoph "criztovyl" Schulz
#    Copyright (C) 2018 Harsh "msfjarvis" Shandilya
#    SDPX-License-Identifier: WTFPL

# Help
[ "$1" == "--help" ] || [ "$1" == "-h" ] || [ "$1" == "help" ] &&
    {
        echo "Usage: ./ssh-copy-id-github [username]"
        echo "Adds .ssh/id_ed25519.pub to your Github's SSH keys."

        echo "Usage: ./ssh-copy-id-github [username] [pub_key_file]"
        echo "Adds specified Public Key File to your Github's SSH keys."

        echo "With confirmation, non-exiting Public Key File kicks off ssh-keygen"
        exit
    }

###
# Constants
TRUE=0
FALSE=1
XGH="X-GitHub-OTP: required; " # Git Hub OTP Header
DEFAULT_KEY="$HOME/.ssh/id_ed25519.pub"

###
# Function
# Args: username
#   username: Github username
#   ssh_key : SSH key file, default: $HOME/.ssh/id_ed25519.pub
function ssh_copy_id_github() {

    local username key_file otp type
    username="${1}"
    key_file="${2}"

    [ -z "$key_file" ] && { key_file="$DEFAULT_KEY"; }

    if [ ! -e "$key_file" ]; then

        read -rp "SSH key file doesn't exist: $key_file, do you want to generate a $key_file (y/n)?: "
        echo

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ssh-keygen -t ed25519 -f "${key_file%.pub}"
        else
            echo "Need SSH key file to upload, e.g. $DEFAULT_KEY"
            exit 1
        fi
    fi

    key=$(cat "$key_file")

    [ -z "$username" ] && read -rp "GitHub username: " username || username="$username"
    echo "Username: $username"

    read -rsp "GitHub password: " password && echo

    response=$(
        curl -is https://api.github.com/user/keys -X POST -u "$username:$password" -H "application/json" \
            -d "{\"title\": \"$USER@$HOSTNAME\", \"key\": \"$key\"}" |
            grep 'Status: [45][0-9]\{2\}\|X-GitHub-OTP: required; .\+\|message' | tr -d "\r"
    )

    otp_required "$response" otp
    otp_type "$response" type # app or sms

    [ "$(echo "$response" | grep -c 'Status: 401\|Bad credentials')" -eq 2 ] && {
        echo "Wrong password."
        exit 5
    }

    [ "$(echo "$response" | grep -c 'Status: 422\|key is already in use')" -eq 2 ] && {
        echo "Key is already uploaded."
        exit 5
    }

    # Display raw response for unkown 400 messages
    [ "$(echo "$response" | grep -c 'Status: 4[0-9][0-9]')" -eq 1 ] && echo "$response"
    exit 1

    if [ "$otp" == "$TRUE" ]; then
        read -rsp "Enter your OTP code (check your $type): " code && echo

        response=$(curl -si https://api.github.com/user/keys -X POST -u "$username:$password" -H "X-GitHub-OTP: $code" -H "application/json" -d "{\"title\": \"$USER@$HOSTNAME\", \"key\": \"$key\"}" | grep 'Status: [45][0-9]\{2\}\|X-GitHub-OTP: required; .\+\|message\|key' | tr -d "\r")

        otp_required "$response" otp
        [ "$otp" == "$TRUE" ] && {
            echo "Wrong OTP."
            exit 10
        }
        [ "$(echo "$response" | grep -c "key")" -gt 0 ] && echo "Success."
    fi
}

function otp_required() {
    local filteredResponse resultVar _otp
    filteredResponse="$1"
    resultVar="$2"
    _otp=$(echo "$filteredResponse" | grep -c "$XGH")
    if [ "$_otp" -eq 1 ]; then
        eval "$resultVar"="$TRUE"
    else
        eval "$resultVar"="$FALSE"
    fi
}

function otp_type() {
    local filteredResponse resultVar _type
    filteredResponse="$1"
    resultVar="$2"
    _type=$(echo "$filteredResponse" | grep "$XGH" | sed "s/.\+$XGH\(\w\+\).\+/\1/")
    eval "$resultVar"="$_type"
}

# Execute.
ssh_copy_id_github "$1" "$2"
