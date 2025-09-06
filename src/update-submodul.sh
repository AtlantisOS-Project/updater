#!/bin/bash
# update-submodul.sh
# automatic update of submoduls

cd "$(dirname "$0")" || exit 1

echo "[INFO] Updating submodules..."
git submodule update --remote --merge
git add .

# commit changes
if output=$(git diff-index HEAD --name-only 2>&1); then
    if [[ -n "$output" ]]; then
    	git status
    	sleep 4
    	git commit -m "Update submodules" -m "($(date +'%Y-%m-%d %H:%M:%S'))"
    	git push origin main
    	echo "[INFO] Submodule changes committed."
	else
    	echo "[INFO] No updates available."
	fi
fi
