#!/bin/bash
# images.sh

# function that unzip the main update file
unpack_zip() {
    local zip="$1"
    local dest="$2"
    echo "[Updater] Unzip $zip to $dest..."
    unzip -o "$zip" -d "$dest"
    echo "[Updater] Finished."
}

# function that extract the images via unxz
extract_images() {
    local dir="$1"
    for img in "$dir"/*.img.xz; do
        if [[ -f "$img" ]]; then
            echo "[INFO]  Extracting $img..."
            unxz -kf "$img"
            echo "[INFO] Finished."
        fi
    done
}

