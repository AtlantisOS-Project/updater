#!/bin/bash
# github.sh

# function that get the releases from the github api
get_latest_release() {
    local repo="$1"
    local include_prerelease="$2"
    local pattern="$3"
	
	# set basic infos for the github api
    local releases
    releases=$(curl -s "https://api.github.com/repos/$repo/releases")
	
	# with prereleases or not
    local filter
    if [[ "$include_prerelease" == "true" ]]; then
    	# with prereleases
        filter='.[]'
    else
    	# no prereleases
        filter='.[] | select(.prerelease == false)'
    fi
	
	# searching for a matching tag
    local tag url
    tag=$(echo "$releases" | jq -r "$filter | .tag_name" | head -n 1)
    if [[ -z "$tag" || "$tag" == "null" ]]; then
        echo "[INFO] No matching release found."
        return 1
    fi
	
	# create the full url to the file
    url=$(echo "$releases" | jq -r --arg TAG "$tag" --arg PATTERN "$pattern" '
        .[] | select(.tag_name == $TAG) |
        .assets[] | select(.name | test($PATTERN)) |
        .browser_download_url' | head -n 1)
	
    if [[ -z "$url" || "$url" == "null" ]]; then
        echo "[INFO] No matching file found in the release."
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

