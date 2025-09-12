#!/bin/bash
#
# /usr/share/atlantis-updater/lib/base/installer.sh
#
# (C) Copyright 2025 AtlantisOS Project
# by @NachtsternBuild
#
# License: GNU GENERAL PUBLIC LICENSE Version 3
#
# an base script that install the bootloader.img, system.img, desktop.img

# function that install the bootloader.img
install_bootloader() {
    local boot_img="$1"
    local legacy_boot="${LEGACY_BOOT:-false}"
    local mnt_efi="/mnt/efi"
    
	# no bootloader.img
    if [[ ! -f "$boot_img" ]]; then
        echo "[INFO] bootloader.img not found, skipping."
        return 1
    fi

    # UEFI standalone Bootloader 
    if [[ -d /sys/firmware/efi ]]; then
        echo "[INFO] UEFI detected → installing bootloader.img"
        mkdir -p "$mnt_efi"
        mount "$EFI" "$mnt_efi"
        # bootloader.imgwith BOOTX64.efi and Grub
        rsync -ah --info=progress2 "$boot_img/" "$mnt_efi/"
        umount "$mnt_efi"
        echo "[INFO] UEFI bootloader installed successfully."
    fi

    # optional legacy BIOS GRUB 
    if [[ "$legacy_boot" == "true" ]]; then
        echo "[INFO] Legacy BIOS boot requested → installing GRUB in MBR of $DISK"
        # needs chroot to use system functions
        mount --bind /dev "$MNT_ROOT/dev"
        mount --bind /proc "$MNT_ROOT/proc"
        mount --bind /sys "$MNT_ROOT/sys"
		# install grub 
        chroot "$MNT_ROOT" grub-install --target=i386-pc "$DISK" --boot-directory=/boot --recheck
        chroot "$MNT_ROOT" update-grub
		
        umount "$MNT_ROOT/dev" "$MNT_ROOT/proc" "$MNT_ROOT/sys"
        echo "[INFO] Legacy BIOS GRUB installed successfully."
    fi
}

# TODO: optimize installation for the installer 
# function that install the other images
install_images() {
    local system_img="$1"
    local desktop_img="$2"
    local inactive_slot="$3"

    mkdir -p /atlantis/system

    if [[ -f "$system_img" ]]; then
        echo "[INFO] Copy system.img to the inactive slot..."
        cp "$system_img" "/atlantis/system/system_${inactive_slot}.img"
    else
        echo "[ERROR] system.img not found!"
        exit 1
    fi

    if [[ -f "$desktop_img" ]]; then
        echo "[INFO] Copy desktop.img to inactive slot..."
        cp "$desktop_img" "/atlantis/system/desktop_${inactive_slot}.img"
    fi
}

