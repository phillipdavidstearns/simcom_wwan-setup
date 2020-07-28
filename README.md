# Setup the Waveshare SIM7600G for Jetson Nano

This guide is heavily adapted from the guide published on the waveshare site, available [here](https://www.waveshare.com/wiki/SIM7600G-H_4G_for_Jetson_Nano).

Notes: There seem to be numerous errors and omissions in the instructions as provided by Waveshare. This guide documents my process so that others may avoid many wasted hours of effort. It turns out that you don't need `udhcpc` if you already have `dhclient` installed. You also don't need `minicom` or `screen`. There is a way to send and view serial using two terminal windows and built in commands `cat` and `echo`.

## Assumptions

* Your host system is either Linux or OSX
* High degree of comfort with the commandline (i.e. compiling from source)

## Requirements

* Jetson Nano B01
* Waveshare SIM7600G-H Hat for Jetson Nano
* Activated SIM with talk/text/data (Mint is tested and works)
* High-speed internet connection (for host and Jetson)

## Hardware Setup

1. Power off the Jetson Nano
1. Install your activated SIM card in the holder on the underside of the SIM7600G-H hat.
1. Install the SIM7600G-H hat by seating it firmly on the J-41 40-pin header making sure it's aligned properly.
1. Connect the provided USB - micro USB adapter between the Nano and the hat.
1. Remove the protective tape covering the `RXD` and `TXD` dip switch to set them both to `ON`
1. Power on the Jetson Nano.

* The `PWR` indicator should come on.
* After a moment, the `NET` light should start blinking. 

1. Log into your Jetson Nano over `ssh` and complete the rest of the steps.

## Software Setup

1. `$ sudo apt-get update`
1. `$ sudo apt-get install p7zip python3-serial minicom Jetson.GPIO -y`
1. `$ wget https://www.waveshare.com/w/upload/9/9b/SIM7600X_4G_for_JETSON_NANO.7z`
1. `$ p7zip --uncompress https://www.waveshare.com/w/upload/9/9b/SIM7600X_4G_for_JETSON_NANO.7z`

## Enable the Hardware (only necessary for testing before the kernel module is installed)

1. `$ echo 200 > /sys/class/gpio/export`
1. `$ echo out > /sys/class/gpio/gpio200/direction`
1. `$ echo 1 > /sys/class/gpio/gpio200/value`
1. `$ echo 0 > /sys/class/gpio/gpio200/value`

## Testing

### Setting up `minicom`

NOTE: It's also possible (and possibly easier) to use `screen`. If you don't have time to deal with this, skip to the "Pure bash shell" instructions at the end of this section.

At this point, the instructions provided by Waveshare call for using `minicom`, but don't provide any hint that it needs to be setup. Instructions for setup can be found [here](https://wiki.emacinc.com/wiki/Getting_Started_With_Minicom) and are summarized below.

1. `$ sudo minicom -s` will greet you with a `configuration` menu

```
            +-----[configuration]------+
            | Filenames and paths      |
            | File transfer protocols  |
            | Serial port setup        |
            | Modem and dialing        |
            | Screen and keyboard      |
            | Save setup as dfl        |
            | Save setup as..          |
            | Exit                     |
            | Exit from Minicom        |
            +--------------------------+
```

1. Arrow down to `Modem and Dialing` and press `enter`
1. Remove "Dialing prefix", "Dialing suffix", and "Hang-up string" entries to match:

```
 +--------------------[Modem and dialing parameter setup]---------------------+
 |                                                                            |
 | A - Init string .........                                                  |
 | B - Reset string ........                                                  |
 | C - Dialing prefix #1....                                                  |
 | D - Dialing suffix #1....                                                  |
 | E - Dialing prefix #2....                                                  |
 | F - Dialing suffix #2....                                                  |
 | G - Dialing prefix #3....                                                  |
 | H - Dialing suffix #3....                                                  |
 | I - Connect string ...... CONNECT                                          |
 | J - No connect strings .. NO CARRIER            BUSY                       |
 |                           NO DIALTONE           VOICE                      |
 | K - Hang-up string ......                                                  |
 | L - Dial cancel string .. ^M                                               |
 |                                                                            |
 | M - Dial time ........... 45      Q - Auto bps detect ..... No             |
 | N - Delay before redial . 2       R - Modem has DCD line .. Yes            |
 | O - Number of tries ..... 10      S - Status line shows ... DTE speed      |
 | P - DTR drop time (0=no). 1       T - Multi-line untag .... No             |
 |                                                                            |
 | Change which setting?     Return or Esc to exit. Edit A+B to get defaults. |
 +----------------------------------------------------------------------------+
```
 
1. Escape to the `configuration` menu
1. Select `Screen and keyboard` and press `enter`.
1. Press `q` to toggle `Local echo` to `Yes`
1. Escape to the `configuration` menu
1. Select `Save setup as dfl` and press `enter`
1. Select `Exit from Minicom` and press `enter`

### On To Testing

For a full list of commands, see the [AT Command Manual](https://www.waveshare.com/w/upload/5/54/SIM7500_SIM7600_Series_AT_Command_Manual_V1.08.pdf).

#### With `minicom`

1. `$ sudo minicom -D /dev/ttyUSB2`
1. Enter `ATI`
1. If you can't see your local echo, you may need to enable it:
	1. Press `ctrl+a` then `z` to bring up the options menu.
	1. Press `e` to enable echo
	1. `esc` to return to the console  

```
ATI

Manufacturer: SIMCOM INCORPORATED
Model: SIMCOM_SIM7600G-H
Revision: SIM7600M22_V2.0
IMEI: 868822040061788
+GCAP: +CGSM

OK
```

#### With Python

1. `$ cd SIM7600X_4G_for_JETSON_NANO/AT`
1. `$ sudo python3 AT.py`

If you wait long enough, you'll get the following output:

```
SIM7600X is ready
Please input the AT command:
```

1. Enter `ATI` to get product identification info:

```
Please input the AT command:ATI

Manufacturer: SIMCOM INCORPORATED
Model: SIMCOM_SIM7600G-H
Revision: SIM7600M22_V2.0
IMEI: 868822040061788
+GCAP: +CGSM

OK
```

#### Pure bash shell

1. `ssh` into your Jetson Nano.
1. Start listening to the SIM7600G-H serial device: `$ cat < /dev/ttyUSB2`
1. Open a second terminal window and `ssh` into your Jetson Nano and complete the following steps.
1. Switch to root user: `$ sudo su`
1. Send a request for product identification info: `# echo -e 'ATI\r' > /dev/ttyUSB2`
1. Now check the first terminal window for the output.

## 4G connection

### Download

1. `$ cd`
1. `$ mkdir Simcom_wwan`
1. `$ cd Simcom_wwan`
1. `$ wget https://www.waveshare.com/w/upload/4/46/Simcom_wwan.zip`
1. `$ unzip Simcom_wwan.zip`

## Compile, and Install Driver

Got help figuring this one out from [here](https://stackoverflow.com/questions/3140478/fatal-module-not-found-error-using-modprobe).

1. Modify the Makefile (basically rewrite it): `$ nano Makefile`

```
obj-m:=simcom_wwan.o
simcom_wwanmodule-objs:=module
MAKE:=make
PWD=$(shell pwd)
VER=$(shell uname -r)
KERNEL_BUILD=/lib/modules/$(VER)/build
INSTALL_ROOT=/

default:
        $(MAKE) -C $(KERNEL_BUILD) M=$(PWD) modules
clean:
        $(MAKE) -C $(KERNEL_BUILD) M=$(PWD) clean
install:
        $(MAKE) -C $(KERNEL_BUILD) M=$(PWD) INSTALL_MOD_PATH=$(INSTALL_ROOT) modules_install
```

1. Press `ctrl+x` then `y` then `enter` to save and exit.
1. `$ sudo make clean && sudo make && sudo install`
1. `$ sudo depmod -a`
1. `$ sudo modprobe -v simcom_wwan`
1. Look for `simcom_wwan` in loaded modules list to confirm successful installation: `$ sudo lsmod`
1. Check kernel messages for successful installation: `$ sudo dmesg`

```
[ 1689.111826] simcom_wwan: loading out-of-tree module taints kernel.
[ 1689.122659] simcom usbnet bind here
[ 1689.125414] simcom_wwan 1-2.3:1.5 wwan0: register 'simcom_wwan' at usb-70090000.xusb-2.3, SIMCOM wwan/QMI device, f6:2d:53:fe:c8:5c
[ 1689.125486] usbcore: registered new interface driver simcom_wwan
```

## Setup Network Interface `wwan0`

1. Check if the `wwan0` interface is present: `$ ifconfig wwan0`
1. Enable the `wwan0` interface: `$ sudo ifconfig wwan0 up`
1. Switch to root user: `$ sudo su`
1. Define network mode as automatic: `# echo -e 'AT+CNMP=2\r' > /dev/ttyUSB2`
1. Connect the NIC to the network: `# echo -e 'AT$QCRMCALL=1,1\r' > /dev/ttyUSB2`
1. Allocate IP: `$ sudo dhclient -1 -v wwan0`

Now you can use 4G network!

## Installing as `systemd` service

There are scripts included in this repo that allow you to install 4G connectivity at boot using `systemd` service files, a preup script and a poststop script to automate the steps in the "Setup Network Interface `wwan0`" section above.

It's recommended that you clone the repo locally on the Jetson Nano.

1. `$ git clone https://github.com/phillipdavidstearns/simcom_wwan-setup.git`
1. `$ cd simcom_wwan-setup`
1. `$ chmod +x install.sh uninstall.sh update.sh`
1. To install: `$ sudo ./install`
1. To uninstall: `$ sudo ./uninstall` 
1. To update: `$ git pull; sudo ./update.sh`

* This service is disabled by default and will not start at boot.
* To enable, run `$ sudo systemctl enable simcom_wwan@wwan0.service`
* To disable, run `$ sudo systemctl disable simcom_wwan@wwan0.service`
* To start the service and 4G LTE connectivity: `$ sudo systemctl start simcom_wwan@wwan0.service`
* To stop the service and 4G LTE connectivity: `$ sudo systemctl stop simcom_wwan@wwan0.service`
* To check the status of the service: `$ sudo systemctl status simcom_wwan@wwan0.service`