#!/bin/bash
#
# /usr/share/atlantis-updater/lib/install_update.sh
#
# (C) Copyright 2025 AtlantisOS Project
# by @NachtsternBuild
#
# License: GNU GENERAL PUBLIC LICENSE Version 3
#
# an additional background script, that install the update, based on the base scripts

# install the update
install_update() {
    ZIP_FILE="$WORKDIR/update.zip"
    # unpack the images
    unpack_zip "$ZIP_FILE" "$WORKDIR"
    # verify the images
    verify_checksums "$WORKDIR"
    # decompress the images
    extract_images "$WORKDIR"
	
	# get the active slot
    load_conf "$SYSTEM_CONF"
    INACTIVE_SLOT=$(get_inactive_slot "$ACTIVE_SLOT")
	
	# install the images to the inactive slot
    install_bootloader "$WORKDIR/bootloader.img"
    install_images "$WORKDIR/system.img" "$WORKDIR/desktop.img" "$INACTIVE_SLOT"
	
	# switch the boot slot
    switch_slot "$SYSTEM_CONF" "$INACTIVE_SLOT"
    # set new system configs
    cp "$SYSTEM_CONF" "$BOOT_CONF"

    {
        echo "VERSION=$REMOTE_VERSION"
        echo "CODENAME=$REMOTE_CODENAME"
        echo "CHANNEL=$REMOTE_CHANNEL"
    } > "$LOCAL_CONF"

    echo "[INFO] Images are installed, the boot slot is: $INACTIVE_SLOT"
}

