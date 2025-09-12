#!/bin/bash
#
# /usr/share/atlantis-updater/lib/base/reboot_system.sh
#
# (C) Copyright 2025 AtlantisOS Project
# by @NachtsternBuild
#
# License: GNU GENERAL PUBLIC LICENSE Version 3
#
# an base script that reboot the system

# reboot the system
reboot_system() {
	echo "[INFO] Rebooting system."
	# perhaps I am using pkexec instead of sudo here, 
	# or generally the updater is run with root privileges, 
	# or the area where root privileges are required.
	sudo reboot
}

