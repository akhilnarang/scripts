#!/usr/bin/env bash
[[ -z "${API_KEY}" ]] && echo "API_KEY not defined, exiting!" && exit 1
CHAT_ID="-1001185331716"
curl -s "https://api.telegram.org/bot${API_KEY}/sendmessage" --data "text=$BUILD_URL&chat_id=$CHAT_ID&parse_mode=HTML"
CHAT_ID="@ResurrectionRemixChannel"
for device in $(git diff HEAD@\{1\}..HEAD --name-only); do
    d=${device/.json/}
    CHAT_ID="-1001185331716"
    authors="$(git log HEAD@\{1\}..HEAD --pretty=format:"%an")"
    newhash="$(git rev-parse HEAD)"
    oldhash="$(git rev-parse HEAD@\{1\})"
    text="$device - https://github.com/ResurrectionRemix-Devices/api/compare/$oldhash...$newhash - $authors"
    curl -s "https://api.telegram.org/bot${API_KEY}/sendmessage" --data "text=$text&chat_id=$CHAT_ID&parse_mode=HTML"
    CHAT_ID="@ResurrectionRemixChannel"
    msg=$(mktemp)
    zip=$(jq -r .response[].filename "${device}")
    filesize=$(($(($(jq -r .response[].size "${device}") / 1024)) / 1024))
    sha=$(jq -r .response[].id "${device}")
    {
        echo "<b>New Build for ${d} available</b>"
        echo "<a href=\"https://get.resurrectionremix.com/?dir=$d\">${zip}</a>"
        echo
        echo "<b>FileSize:</b> $filesize MB"
        echo "<b>SHA256:</b> <code>$sha</code>"
    } >"${msg}"
    MESSAGE=$(cat "$msg")
    curl -s "https://api.telegram.org/bot${API_KEY}/sendmessage" --data "text=$MESSAGE&chat_id=$CHAT_ID&parse_mode=HTML"
done
