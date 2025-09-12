#!/bin/bash
#
# /usr/share/atlantis-updater/lib/base/slots.sh
#
# (C) Copyright 2025 AtlantisOS Project
# by @NachtsternBuild
#
# License: GNU GENERAL PUBLIC LICENSE Version 3
#
# an base script that set a new active slot

# function that get the inactive slot
get_inactive_slot() {
    local active="$1"
    if [[ "$active" == "a" ]]; then
        echo "b"
    else
        echo "a"
    fi
}

# function that switch the slots
switch_slot() {
    local conf_file="$1"
    local new_slot="$2"
    save_conf "$conf_file" "ACTIVE_SLOT=$new_slot"
}

