#!/bin/bash
# update-subtrees.sh
# build-deb-debuild.sh
#
# (C) Copyright 2025 AtlantisOS Project
# by @NachtsternBuild
#
# License: GNU GENERAL PUBLIC LICENSE Version 3
#
# automatic update of git subtrees based on subtrees.conf

set -euo pipefail
cd "$(dirname "$0")" || exit 1

CONF_FILE="subtrees.conf"

echo "[INFO] Updating all subtrees..."

while IFS= read -r line; do
    # Abschnitt starten
    if [[ $line =~ ^\[subtree\ \"(.+)\"\]$ ]]; then
        name="${BASH_REMATCH[1]}"
        prefix=""
        repo=""
        branch=""
    elif [[ $line =~ ^prefix\ *=\ *(.*)$ ]]; then
        prefix="${BASH_REMATCH[1]}"
    elif [[ $line =~ ^repo\ *=\ *(.*)$ ]]; then
        repo="${BASH_REMATCH[1]}"
    elif [[ $line =~ ^branch\ *=\ *(.*)$ ]]; then
        branch="${BASH_REMATCH[1]}"
        # if everything there, start the update
        echo "[INFO] Updating subtree: $name"
        git subtree pull --prefix="$prefix" "$repo" "$branch" --squash || {
            echo "[WARN] Failed to update $name"
        }
    fi
done < "$CONF_FILE"

# add everything
git add .

# Commit nur, wenn sich was geändert hat

if output=$(git diff-index HEAD --name-only 2>&1); then
    if [[ -n "$output" ]]; then
	    git status
	    sleep 4
	    git commit -am "Update subtrees ($(date +'%Y-%m-%d %H:%M:%S'))"
	    sleep 2
	    git push origin main
	    echo "[INFO] Subtree changes committed."
	else
	    echo "[INFO] No updates available."
	fi
fi
