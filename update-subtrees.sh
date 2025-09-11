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
# git clone git@github.com:AtlantisOS-Project/atlantis-UI-base.git tmp-upstream
#
# src only:
# cd tmp-upstream
# git subtree split --prefix=src -b src-only
# cd ../
# git subtree add --prefix=modules/ ./tmp-upstream src-only --squash
#
# deb only:
# cd tmp-upstream
# git subtree split --prefix=deb -b deb-only
# cd ../
# git subtree add --prefix=deb ./tmp-upstream deb-only --squash

set -euo pipefail

cd "$(dirname "$0")" || exit 1

CONF_FILE="../subtrees.conf"
UPSTREAM_DIR="./tmp-upstream"

# update upstream
echo "[INFO] Updating upstream repository..."
if [[ ! -d "$UPSTREAM_DIR/.git" ]]; then
    echo "[ERROR] Upstream repo not found in $UPSTREAM_DIR"
    exit 1
fi

cd "$UPSTREAM_DIR"
git fetch origin
git checkout main
git pull origin main

# recreate splitted branches
echo "[INFO] Generating split branches..."
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

        # create split branch
        echo "[INFO] Creating split branch for $name ($prefix)"
        if git show-ref --verify --quiet "refs/heads/$branch"; then
            git branch -D "$branch"
        fi
        git subtree split --prefix="$prefix" -b "$branch"
    fi
done < "$CONF_FILE"

# switch to root
cd ../

# update subtrees in the main repo
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

        echo "[INFO] Pulling subtree: $name"
        #if ! git subtree pull --prefix="$prefix" "$repo" "$branch" --squash; then
        #    echo "[WARN] Failed to update $name"
        #fi
    fi
done < "$CONF_FILE"

# adding everything
git add .

# commit changes
if output=$(git diff-index HEAD --name-only 2>&1); then
    if [[ -n "$output" ]]; then
    	echo "[INFO] Committing subtree updates..."
   		#git commit -m "Update subtrees ($(date +'%Y-%m-%d %H:%M:%S'))"
    	# git push origin main
    	echo "[INFO] Subtree changes committed and pushed."
	else
    	echo "[INFO] No updates available."
	fi
fi
