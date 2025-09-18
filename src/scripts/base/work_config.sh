#!/bin/bash
#
# /usr/share/atlantis-updater/lib/base/work_config.sh
#
# (C) Copyright 2025 AtlantisOS Project
# by @NachtsternBuild
#
# License: GNU GENERAL PUBLIC LICENSE Version 3
#
# an base script that save and load configs

# function that load the .conf files
load_conf() {
    local file="$1"
    if [[ -f "$file" ]]; then
        source "$file"
    else
        echo "[ERROR] $file not found."
        exit 1
    fi
}

# function that save new configs 
save_conf() {
    local file="$1"
    shift
    local kvs=("$@")
    > "$file"
    for kv in "${kvs[@]}"; do
        echo "$kv" >> "$file"
    done
}

# function that save the remotet data for the UI updater
save_remote_conf() {
    local conf_file="$1"
    local update_typ="$2"
    local version="$3"
    local codename="$4"
    local channel="$5"
    local description="$6"
    cat > "$conf_file" <<EOF
UPDATE_TYPE="$update_typ"
REMOTE_VERSION="$version"
REMOTE_CODENAME="$codename"
REMOTE_CHANNEL="$channel"
REMOTE_DESCRIPTION="$description"
EOF
    echo "[Updater] Config gespeichert nach $conf_file"
}
