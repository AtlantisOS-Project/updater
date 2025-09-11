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
# Use for init:
# Example UI base
# git clone git@github.com:AtlantisOS-Project/atlantis-UI-base.git tmp-upstream
# cd tmp-upstream
# git subtree split --prefix=src -b src-only
# cd ../
# git subtree add --prefix=modules/ ./tmp-upstream src-only --squash

set -euo pipefail
cd "$(dirname "$0")" || exit 1

CONF_FILE="subtrees.conf"

echo "[INFO] Rebase local main onto origin/main..."
git pull origin main

echo "[INFO] Updating all subtrees..."
while IFS= read -r line; do
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
        echo "[INFO] Updating subtree: $name"
        if ! git subtree pull --prefix="$prefix" "$repo" "$branch" --squash; then
            echo "[WARN] Failed to update $name"
        fi
    fi
done < "$CONF_FILE"

# adding everything
git add .

# commit changes
if output=$(git diff-index HEAD --name-only 2>&1); then
    if [[ -n "$output" ]]; then
    	echo "[INFO] Committing subtree updates..."
   		git commit -m "Update subtrees ($(date +'%Y-%m-%d %H:%M:%S'))"
    	git push origin main
    	echo "[INFO] Subtree changes committed and pushed."
	else
    	echo "[INFO] No updates available."
	fi
fi
