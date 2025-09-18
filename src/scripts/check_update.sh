#!/bin/bash
#
# /usr/share/atlantis-updater/lib/check_update.sh
#
# (C) Copyright 2025 AtlantisOS Project
# by @NachtsternBuild
#
# License: GNU GENERAL PUBLIC LICENSE Version 3
#
# an additional background script, that check for updates, based on the base scripts

# check for updates
check_update() {
    echo "[INFO] Loading the latest update.conf..."
    # get the latest update.conf
    info=$(get_release_asset "$REPO" "$INCLUDE_PRERELEASE" "update.conf") || exit 0
    IFS="|" read -r TAG CONF_URL <<< "$info"
    CONF_FILE="$WORKDIR/update.conf"
	
	# download the update.conf
    download_file "$CONF_URL" "$CONF_FILE"
    load_conf "$CONF_FILE"

    REMOTE_VERSION="$VERSION"
    REMOTE_CODENAME="$CODENAME"
    REMOTE_CHANNEL="$CHANNEL"
    REMOTE_DESCRIPTION="$DESCRIPTION"
	
	# check the channel (main/lts)
    if [[ "$LOCAL_CHANNEL" != "$REMOTE_CHANNEL" ]]; then
        echo "[Updater] Channel mismatch (lokal=$LOCAL_CHANNEL, remote=$REMOTE_CHANNEL)."
        exit 0
    fi
	
	# check the system versions
    if [[ "$LOCAL_VERSION" == "$REMOTE_VERSION" ]]; then
        echo "[Updater] System is uptodate"
        exit 0
    fi
	
	# check if is update/upgrade
    if [[ "$LOCAL_CODENAME" != "$REMOTE_CODENAME" ]]; then
    	# upgrade = new codename
        UPDATE_TYPE="Upgrade"
    else
    	# update = only version changes
        UPDATE_TYPE="Update"
    fi

    echo "[Updater] New $UPDATE_TYPE avaible:"
    echo "  Version: $REMOTE_VERSION"
    echo "  Codename: $REMOTE_CODENAME"
    echo "  Channel: $REMOTE_CHANNEL"
    echo "  Notes: $REMOTE_DESCRIPTION"
    
    save_remote_conf "$REMOTE_CONF" "$UPDATE_TYPE" "$REMOTE_VERSION" "$REMOTE_CODENAME" "$REMOTE_CHANNEL" "$REMOTE_CHANNEL"
}
