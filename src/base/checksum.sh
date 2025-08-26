#!/bin/bash
# checksum.sh

# check if the checksum is correct
checksum_ok() {
    local file="$1"
    local expected="$2"
    local actual
    actual=$(sha256sum "$file" | awk '{print $1}')
    [[ "$actual" == "$expected" ]]
}

# verify that the checksum are fine
verify_checksums() {
    local dir="$1"
    pushd "$dir" >/dev/null
    if ! sha256sum -c SHA256SUMS; then
        echo "[ERROR] One or more files do not match the checksum!"
        exit 1
    fi
    popd >/dev/null
    echo "[INFO] Checksums OK."
}

