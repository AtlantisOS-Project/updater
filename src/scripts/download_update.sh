#!/bin/bash
#
# /usr/share/atlantis-updater/lib/download_update.sh
#
# (C) Copyright 2025 AtlantisOS Project
# by @NachtsternBuild
#
# License: GNU GENERAL PUBLIC LICENSE Version 3
#
# an additional background script, that download the update, based on the base scripts

# download the update
download_update() {
	# check for a new update
    check_update
    
    # get the latest release
    info=$(get_latest_release "$REPO" "$INCLUDE_PRERELEASE" ".*update\\.zip$") || exit 0
    IFS="|" read -r TAG ZIP_URL <<< "$info"
    ZIP_FILE="$WORKDIR/update.zip"
    
    echo "[INFO] Downloading Update..."
    # download the update
    download_file "$ZIP_URL" "$ZIP_FILE"
}

