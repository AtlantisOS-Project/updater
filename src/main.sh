#!/bin/bash
# /usr/lib/atlantis-updater/main.sh 
# the background script, that interact with the GUI

set -euo pipefail

# standard config
WORKDIR="/tmp/atlantis-updater"
ATLANTIS_DIR="/atlantis"
BOOT_DIR="/boot"
REPO="AtlantisOS-Project/atlantis-build"
INCLUDE_PRERELEASE="false"
MODE="full" # default mode

# read the flag for the updater
for arg in "$@"; do
    case $arg in
        --workdir=*) 
        	WORKDIR="${arg#*=}" 
        	;;
        --atlantis=*) 
        	ATLANTIS_DIR="${arg#*=}" 
        	;;
        --boot=*) 
        	BOOT_DIR="${arg#*=}" 
        	;;
        --repo=*) 
        	REPO="${arg#*=}" 
        	;;
        --prerelease=*) 
        	INCLUDE_PRERELEASE="${arg#*=}" 
        	;;
        --check) 
        	MODE="check" 
        	;;
        --download) 
        	MODE="download" 
        	;;
        --install) 
        	MODE="install" 
        	;;
        --full) 
        	MODE="full" 
        	;;
        --reboot)
        	MODE="reboot" 
        *) 
        	echo "[WARNING] Ignore unknown argument: $arg" 
        	;;
    esac
done

# config files
LOCAL_CONF="$ATLANTIS_DIR/updater/local-release.conf"
SYSTEM_CONF="$ATLANTIS_DIR/system/atlantis.conf"
BOOT_CONF="$BOOT_DIR/atlantis.conf"

# load the other parts
source ./config.sh
source ./github.sh
source ./checksum.sh
source ./images.sh
source ./slots.sh
source ./installer.sh

mkdir -p "$WORKDIR"

# loading local infos
load_conf "$LOCAL_CONF"
LOCAL_VERSION="$VERSION"
LOCAL_CODENAME="$CODENAME"
LOCAL_CHANNEL="$CHANNEL"

# --- Update prüfen ---
do_check() {
    echo "[Updater] Loading the latest update.conf..."
    # get the latest update.conf
    info=$(get_release_asset "$REPO" "$INCLUDE_PRERELEASE" "update.conf") || exit 0
    IFS="|" read -r TAG CONF_URL <<< "$info"
    CONF_FILE="$WORKDIR/update.conf"
	
	# download the update.conf
    download_file "$CONF_URL" "$CONF_FILE"
    load_conf "$CONF_FILE"

    REMOTE_VERSION="$VERSION"
    REMOTE_CODENAME="$CODENAME"
    REMOTE_CHANNEL="$CHANNEL"
    REMOTE_DESCRIPTION="$DESCRIPTION"
	
	# check the channel (main/lts)
    if [[ "$LOCAL_CHANNEL" != "$REMOTE_CHANNEL" ]]; then
        echo "[Updater] Channel mismatch (lokal=$LOCAL_CHANNEL, remote=$REMOTE_CHANNEL)."
        exit 0
    fi
	
	# check the system versions
    if [[ "$LOCAL_VERSION" == "$REMOTE_VERSION" ]]; then
        echo "[Updater] System is uptodate"
        exit 0
    fi
	
	# check if is update/upgrade
    if [[ "$LOCAL_CODENAME" != "$REMOTE_CODENAME" ]]; then
    	# upgrade = new codename
        UPDATE_TYPE="Upgrade"
    else
    	# update = only version changes
        UPDATE_TYPE="Update"
    fi

    echo "[Updater] New $UPDATE_TYPE avaible:"
    echo "  Version: $REMOTE_VERSION"
    echo "  Codename: $REMOTE_CODENAME"
    echo "  Channel: $REMOTE_CHANNEL"
    echo "  Notes: $REMOTE_DESCRIPTION"
}

# --- Download Schritt ---
do_download() {
	# check for a new update
    do_check
    
    # get the latest release
    info=$(get_latest_release "$REPO" "$INCLUDE_PRERELEASE" ".*update\\.zip$") || exit 0
    IFS="|" read -r TAG ZIP_URL <<< "$info"
    ZIP_FILE="$WORKDIR/update.zip"
    
    echo "[Updater] Downloading Update..."
    # download the update
    download_file "$ZIP_URL" "$ZIP_FILE"
}

# install the update
do_install() {
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

    echo "[Updater] Images are installed, the boot slot is: $INACTIVE_SLOT"
}

# reboot the system
do_reboot() {
	echo "[INFO] Rebooting system."
	sudo reboot
}

# dispatch the flags
case $MODE in
    check) 
    	do_check 
    	;;
    download) 
    	do_download 
    	;;
    install) 
    	do_install 
    	;;
    full) 
    	do_check && do_download && do_install
    	;;
    reboot) 
    	do_reboot 
    	;;
    *) 
    	echo "[ERROR] Unkown mode: $MODE" 
    	exit 1 
    	;;
esac

