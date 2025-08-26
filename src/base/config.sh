#!/bin/bash
# config.sh

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

