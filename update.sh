#!/bin/bash

SERVICE_FILE="simcom_wwan@.service"

if [ "$EUID" -ne 0 ]
  then echo "[!] Please run as root"
  exit 1
fi

echo "[+] Uninstalling $SERVICE_FILE"

if (/bin/bash uninstall.sh); then
	echo "[+] Sucessfully uninstalled $SERVICE_FILE"
else
	echo "[!] Encountered errors while attempting to uninstall $SERVICE_FILE"
fi

echo "[+] Installing $SERVICE_FILE"

if (/bin/bash install.sh); then
	echo "[+] Sucessfully installed $SERVICE_FILE"
	exit 1
else
	echo "[!] Encountered errors while attempting to install $SERVICE_FILE"
	exit 0
fi