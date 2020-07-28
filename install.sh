#!/bin/bash

# Install files and scripts for simcom_wwan@.service

PRE_SCRIPT_FILE="wwan_preup.sh"
POST_SCRIPT_FILE="wwan_postdown.sh"
SCRIPT_PATH="/etc/simcom_wwan"
SERVICE_PATH="/lib/systemd/system"
SERVICE_FILE="simcom_wwan@.service"
IFACE="wwan0"
SERVICE="simcom_wwan@$IFACE.service"

if [ "$EUID" -ne 0 ]
  then echo "[!] Please run as root"
  exit 1
fi

if [[ -d "$SCRIPT_PATH" ]]; then
	echo "[-] $SCRIPT_PATH already exists"
else
	echo "[+] Creating directory $SCRIPT_PATH"
	mkdir "$SCRIPT_PATH"
fi

echo "[+] Copying $PRE_SCRIPT_FILE to $SCRIPT_PATH"
if (cp "./$PRE_SCRIPT_FILE" "$SCRIPT_PATH"); then
	echo "[+] Successfully copied $PRE_SCRIPT_FILE to $SCRIPT_PATH"
else
	echo "[!] Failed to copy $PRE_SCRIPT_FILE to $SCRIPT_PATH"
	exit 1
fi

echo "[+] Copying $POST_SCRIPT_FILE to $SCRIPT_PATH"
if (cp "./$POST_SCRIPT_FILE" "$SCRIPT_PATH"); then
	echo "[+] Successfully copied $POST_SCRIPT_FILE to $SCRIPT_PATH"
else
	echo "[!] Failed to copy $POST_SCRIPT_FILE to $SCRIPT_PATH"
	exit 1
fi

echo "[+] Copying $SERVICE_FILE to $SERVICE_PATH"
if (cp "./$SERVICE_FILE" "$SERVICE_PATH"); then
	echo "[+] Successfully copied $SERVICE_FILE to $SERVICE_PATH"
else
	echo "[!] Failed to copy $SERVICE_FILE to $SERVICE_PATH"
	exit 1
fi

echo "[+] Reloading systemd manager configuration"

if (systemctl daemon-reload); then
	echo "[+] Successfully installed $SERVICE_FILE!"
	echo "[+] To start, run: $ sudo systemctl start simcom_wwan@$IFACE.service"
else
	echo "[!] Reloading systemd manager configuration failed"
	exit 1
fi

exit 0
