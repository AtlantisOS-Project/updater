#!/bin/bash
# update-submodul.sh
# automatic update of submoduls

cd "$(dirname "$0")" || exit 1

echo "[INFO] Updating submodules..."
git submodule update --remote --merge

# commit changes
if ! git diff --quiet -- submodules; then
    git add submodules
    git commit -m "Update submodules" -m "($(date +'%Y-%m-%d %H:%M:%S'))"
    git origin main
    echo "[INFO] Submodule changes committed."
else
    echo "[INFO] No updates available."
fi

