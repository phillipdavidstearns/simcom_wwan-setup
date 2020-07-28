#!/bin/bash

# Uninstall files and scripts for simcom_wwan@.service

SCRIPT_PATH="/etc/simcom_wwan"
SERVICE_PATH="/lib/systemd/system"
SERVICE_FILE="simcom_wwan@.service"
IFACE="wwan0"
SERVICE="simcom_wwan@$IFACE.service"

if [ "$EUID" -ne 0 ]
  then echo "[!] Please run as root"
  exit 1
fi

# Remove the service file
if [[ -f "$SERVICE_PATH/$SERVICE_FILE" ]]; then

	echo "[*] Stopping $SERVICE_FILE"
	if (systemctl stop "$SERVICE"); then
		echo "[+] Stopped $SERVICE_FILE"
	else
		echo "[!] Failed to stop $SERVICE_FILE"
		exit 1
	fi

	echo "[*] Disabling $SERVICE"
	if (systemctl disable "$SERVICE"); then
		echo "[+] Disabled $SERVICE"
	else
		echo "[!] Failed to disable $SERVICE"
		exit 1
	fi

	echo "[*] Removing $SERVICE_PATH/$SERVICE_FILE"
	if (rm "$SERVICE_PATH/$SERVICE_FILE"); then
		echo "[+] Removed $SERVICE_PATH/$SERVICE_FILE"
	else
		echo "[!] Failed to remove $SERVICE_PATH/$SERVICE_FILE"
		exit 1
	fi
else
	echo "[-] $SERVICE_PATH/$SERVICE_FILE doesn't exist"
fi

# Remove Scripts
if [[ -d "$SCRIPT_PATH" && "$SCRIPT_PATH" != '/' ]]; then
	echo "[*] Removing $SCRIPT_PATH"
	if (rm -rf "$SCRIPT_PATH"); then
		echo "[+] Removed $SCRIPT_PATH"
	else
		echo "[!] Failed to remove $SCRIPT_PATH"
		exit 1
	fi
else
	echo "[-] Invalid path. $SCRIPT_PATH doesn't exist or is \'/\'"
fi

echo "[*] Reloading systemd configuration"
if (systemctl daemon-reload); then
	echo "[+] Successfully reloaded systemd configuration"
else
	echo "[!] Failed to reload systemd configuration"
	exit 1
fi

echo "[*] Restarting systemd"
if (systemctl daemon-reexec); then
	echo "[+] Successfully restarted systemd"
else
	echo "[!] Failed to restart systemd"
	exit 1
fi

exit 0