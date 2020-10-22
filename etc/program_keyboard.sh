#!/usr/bin/env bash

unset HEXFILE
FIND="$(type -P find)" && HEXFILE="$(${FIND} . -maxdepth 3 -name "kbd.hex" | head -1)"
if [ -z "${HEXFILE}" ]; then
printf "\nCan't find file kbd.hex\n\n"
    exit 1
fi

function check_rv() {
  if [ "$1" -ne 0 ]; then
    shift
    printf "%s" "$*"
    exit 1
  fi
}    

cat << __EOF__
This script will program an Arduino to act as a USB keyboard.
The Arduino needs to be plugged in via USB and the UART needs to
be disconnected. Optionally, an LED can be connected to Digital Pin 2
Set up your hardware and press enter to continue...

__EOF__

read
echo "Uploading keyboard program to device..."
make clean
check_rv $? "error with gmake. Check the source code and Makefile.\n"
make
check_rv $? "error with gmake. Check the source code and Makefile.\n"
make upload
check_rv $? "error with gmake or avrdude. Check the source code and\n" \
              " Makefile. Confirm  that the correct\nboard model is\n" \
              " set in Makefile. Install avr-gcc/avr-g++/avrdude.\n"

cat << __EOF__
Successfully uploaded the keyboard program. Proceeding to USB reset...
The USB chip needs to be flashed with the Keyboard frimware. To do
that, you need to jump the USB reset pins on the device. They may not
have headers soldered. Locate and jump those pads. The LED's might
flash, but it's not guaranteed
Press enter to continue....

__EOF__

read
dfu-programmer atmega16u2 erase
check_rv $? "error erasing USB controller. Try jumping the reset pins again"
sleep 2
dfu-programmer atmega16u2 flash "${HEXFILE}"
check_rv $? "error flashing the keyboard firmware to device.\n" \
              " Try re-running this script.\n"
sleep 2
dfu-programmer atmega16u2 reset
check_rv $? "error resetting the device. It may have been properly flashed\n" \
              " anyway, unplug it for 10 seconds then test.\n"
sleep 2

cat << __EOF__
USB controller as a keyboard! Now you need to unplug the deveice from
USB and power (it needs to be off) for 5-10 seconds. Afterwards, plug
it in and test the keyboard functionality by connecting the UART bridge
to pins 7 & 8 and connecting to the device with a terminal program at a
baud rate of 9600.

__EOF__
exit 0

