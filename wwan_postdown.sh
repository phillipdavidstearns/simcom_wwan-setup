#!/bin/bash

MODULE="simcom_wwan"
IFACE="wwan0"
DEV="ttyUSB2"

function usage {
	echo -e "\nUsage: wann_postdown [-d [device]] [-i [interface]]"
	echo -e "NOTE: Some network changes require your password"
	echo -e "\t-d\t\tspecify device (default: /dev/ttyUSB2)"
	echo -e "\t-i\t\tspecify interface (default: wwan0)"
	echo -e "\t-h\t\tdisplay this help message"
	echo -e "\n"
}

while getopts "d:i:h" opt; do
	case ${opt} in
		h)
			usage
			exit 1
			;;
		i)
			IFACE=${OPTARG}
			;;
		d)
			DEV=${OPTARG}
			;;
		:)
			echo "[!] Option requires an argument."
			exit 1
			;;
		\?)
			echo "[!] Invalid option. Run with -h to view usage."
			exit 1
			;;
	esac
done
shift $((OPTIND -1))

if [ "$EUID" -ne 0 ]
  then echo "[!] Please run as root"
  exit 1
fi

# Check for kernel module
if (lsmod | grep "$MODULE" >/dev/null 2>&1); then
	# Check for interface
	if (ifconfig -a | grep "$IFACE" >/dev/null 2>&1); then
		# Bring interface down
		if (ifconfig "$IFACE" down >/dev/null 2>&1); then
			# Check for simcom tty device
			if (ls /dev | grep "$DEV" >/dev/null 2>&1); then
				# Send AT command to disconnect NIC
				if (echo -e 'AT$QCRMCALL=0,1\r' > /dev/$DEV); then
					echo "[+] $IFACE at /dev/$DEV is disconnected"
					exit 0
				else
					echo "[!] unable to communicate with $DEV"
					exit 1
				fi
			else
				echo "[!] /dev/$DEV not found"
				exit 1
			fi
		else
			echo "[!] Could not bring down $IFACE."
			exit 1
		fi
	else
		echo "[!] interface $IFACE not found"
		exit 1
	fi
else
	echo "[!] $MODULE module not found"
	exit 1
fi