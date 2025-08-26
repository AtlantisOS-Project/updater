#!/bin/bash
# main.sh
# the main updater of AtlantisOS
# now only without GUI, later in GTK4

set -euo pipefail

# load the other moduls
source ./config.sh
source ./github.sh
source ./checksum.sh
source ./images.sh
source ./slots.sh
source ./installer.sh

# some configurations
LOCAL_CONF="/atlantis/updater/local-release.conf"
SYSTEM_CONF="/atlantis/system/atlantis.conf"
BOOT_CONF="/boot/atlantis.conf"
WORKDIR="/tmp/atlantis-updater"
REPO="AtlantisOS-Project/atlantis-build"
INCLUDE_PRERELEASE="false"

# create the working dir
mkdir -p "$WORKDIR"

# load local configs
echo "[Updater] Loading local configuration..."
load_conf "$LOCAL_CONF"
LOCAL_VERSION="$VERSION"
LOCAL_CODENAME="$CODENAME"
LOCAL_CHANNEL="$CHANNEL"

echo "[Updater] Current system:"
echo "  Version:  $LOCAL_VERSION"
echo "  Codename: $LOCAL_CODENAME"
echo "  Channel:  $LOCAL_CHANNEL"

# get the releases
# perhaps there will be a separation here between the main update.zip and update.conf.
info=$(get_latest_release "$REPO" "$INCLUDE_PRERELEASE" ".*update\\.zip$") || exit 0
IFS="|" read -r TAG ZIP_URL <<< "$info"
ZIP_FILE="$WORKDIR/update.zip"

echo "[Updater] Release found: $TAG"
download_file "$ZIP_URL" "$ZIP_FILE"

# unzip the zip files
unpack_zip "$ZIP_FILE" "$WORKDIR"

# check if update.conf and sha256sum are in the update
if [[ ! -f "$WORKDIR/update.conf" || ! -f "$WORKDIR/SHA256SUMS" ]]; then
    echo "[ERROR] update.conf or SHA256SUMS is missing from the archive!"
    exit 1
fi

# load the configs from the update.conf
load_conf "$WORKDIR/update.conf"
REMOTE_VERSION="$VERSION"
REMOTE_CODENAME="$CODENAME"
REMOTE_CHANNEL="$CHANNEL"
REMOTE_DESCRIPTION="$DESCRIPTION"

echo "[Updater] Remote-Version:"
echo "  Version:  $REMOTE_VERSION"
echo "  Codename: $REMOTE_CODENAME"
echo "  Channel:  $REMOTE_CHANNEL"
echo "  Notes:  $REMOTE_DESCRIPTION"

# check the update channel
if [[ "$LOCAL_CHANNEL" != "$REMOTE_CHANNEL" ]]; then
    echo "[Updater] Update channel does not match (lokal=$LOCAL_CHANNEL, remote=$REMOTE_CHANNEL)."
    exit 0
fi

# get the typ of the update (update/upgrade)
# different codenames = upgrade
# only different versions = update
if [[ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then
	if [[ "$LOCAL_CODENAME" != "$REMOTE_CODENAME" ]]; then
    	UPDATE_TYPE="Upgrade"
	else
    	UPDATE_TYPE="Update"
	fi
else
	echo "[Updater] System is uptodate."
	exit 0
fi

echo "[Updater] Found $UPDATE_TYPE available!"
read -rp "Would you like to continue? [y/N] " yn
if [[ "$yn" != "y" && "$yn" != "Y" ]]; then
    echo "[WARNING] Cancelled!"
    exit 0
fi

# verify the checksums
verify_checksums "$WORKDIR"

# unpack the images
extract_images "$WORKDIR"

# get the active/inactive slot
echo "[Updater] Loading current slot configuration..."
load_conf "$SYSTEM_CONF"

if [[ -z "${ACTIVE_SLOT:-}" ]]; then
    echo "[ERROR] ACTIVE_SLOT is not set!"
    exit 1
fi

INACTIVE_SLOT=$(get_inactive_slot "$ACTIVE_SLOT")
echo "[Updater] Active Slot: $ACTIVE_SLOT"
echo "[Updater] Inactive Slot: $INACTIVE_SLOT"

# install the bootloader.img
# not absolutely necessary
BOOTLOADER_IMG="$WORKDIR/bootloader.img"
install_bootloader "$BOOTLOADER_IMG"

# install the system.img/desktop.img in the inactive slot
SYSTEM_IMG="$WORKDIR/system.img"
DESKTOP_IMG="$WORKDIR/desktop.img"
install_images "$SYSTEM_IMG" "$DESKTOP_IMG" "$INACTIVE_SLOT"

# swicht the slot and update the atlantis.conf
switch_slot "$SYSTEM_CONF" "$INACTIVE_SLOT"
cp "$SYSTEM_CONF" "$BOOT_CONF"

# update the local-release.conf
{
    echo "VERSION=$REMOTE_VERSION"
    echo "CODENAME=$REMOTE_CODENAME"
    echo "CHANNEL=$REMOTE_CHANNEL"
} > "$LOCAL_CONF"

echo "[Updater] Update complete. New active slot: $INACTIVE_SLOT"
# TODO: reboot logic
echo "[Updater] Now reboot the system."
