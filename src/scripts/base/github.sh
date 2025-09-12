#!/bin/bash
#
# /usr/share/atlantis-updater/lib/base/github.sh
#
# (C) Copyright 2025 AtlantisOS Project
# by @NachtsternBuild
#
# License: GNU GENERAL PUBLIC LICENSE Version 3
#
# an base script that get the url from the release from the github api and download the update

# get a specific asset (e.g. update.conf) from the latest release
get_release_asset() {
    local repo="$1"
    local include_prerelease="$2"
    local filename="$3"
	
	# set basic infos for the github api
    local releases filter tag url
    releases=$(curl -s "https://api.github.com/repos/$repo/releases")
	
	# with prereleases or not
    if [[ "$include_prerelease" == "true" ]]; then
        filter='.[]'
    else
        filter='.[] | select(.prerelease == false)'
    fi

    # get the newest tag
    tag=$(echo "$releases" | jq -r "$filter | .tag_name" | head -n 1)
    if [[ -z "$tag" || "$tag" == "null" ]]; then
        echo "[INFO] No release found."
        return 1
    fi

    # search for the given filename in assets
    url=$(echo "$releases" | jq -r --arg TAG "$tag" --arg FILE "$filename" '
        .[] | select(.tag_name == $TAG) |
        .assets[] | select(.name == $FILE) |
        .browser_download_url' | head -n 1)

    if [[ -z "$url" || "$url" == "null" ]]; then
        echo "[INFO] Asset $filename not found in release $tag."
        return 1
    fi

    echo "$tag|$url"
}

# function that download the file based on the url
download_file() {
    local url="$1"
    local out="$2"
    echo "[INFO] Loading $url ..."
    curl -L -o "$out" "$url"
}

