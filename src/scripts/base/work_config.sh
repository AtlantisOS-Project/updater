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

