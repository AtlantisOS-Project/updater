#!/bin/bash
#
# /usr/share/atlantis-updater/updater.sh 
#
# (C) Copyright 2025 AtlantisOS Project
# by @NachtsternBuild
#
# License: GNU GENERAL PUBLIC LICENSE Version 3
#
# the background script, that interact with the GUI
#
# TODO: basic scripts as part of atl to facilitate use for updaters and installers
# TODO: simpler updates for the app container too (depends atl)

set -euo pipefail

# path definition
SCRPITS="/usr/share/atlantis-updater/lib/base"
BASE_SCRIPTS="$SCRPITS/base"

# load the base scripts
source "$BASE_SCRIPTS/work_config.sh"
source "$BASE_SCRIPTS/github.sh"
source "$BASE_SCRIPTS/checksum.sh"
source "$BASE_SCRIPTS/images.sh"
source "$BASE_SCRIPTS/slots.sh"
source "$BASE_SCRIPTS/installer.sh"
source "$BASE_SCRIPTS/rebooot_system.sh"
# load the additional scripts
source "$SCRPITS/check_update.sh"
source "$SCRPITS/download_update.sh"
source "$SCRPITS/install_update.sh"

# standard config
WORKDIR="/tmp/atlantis-updater"
ATLANTIS_DIR="/atlantis"
BOOT_DIR="/boot"
REPO="AtlantisOS-Project/atlantis-build"
INCLUDE_PRERELEASE="false"
MODE="full" # default mode

# config files
LOCAL_CONF="$ATLANTIS_DIR/updater/local-release.conf"
REMOTE_CONF="$ATLANTIS_DIR/updater/update-remote.conf"
SYSTEM_CONF="$ATLANTIS_DIR/system/atlantis.conf"
BOOT_CONF="$BOOT_DIR/atlantis.conf"


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


# create the working dir
mkdir -p "$WORKDIR"

# loading local infos
load_conf "$LOCAL_CONF"
LOCAL_VERSION="$VERSION"
LOCAL_CODENAME="$CODENAME"
LOCAL_CHANNEL="$CHANNEL"

# start action by the flags $MODE
case $MODE in
    check) 
    	check_update
    	;;
    download) 
    	download_update 
    	;;
    install) 
    	install_update 
    	;;
    full) 
    	do_check && do_download && do_install
    	;;
    reboot) 
    	reboot_system
    	;;
    *) 
    	echo "[ERROR] Unkown mode: $MODE" 
    	exit 1 
    	;;
esac

