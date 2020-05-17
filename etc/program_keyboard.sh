#!/bin/bash

RUN_DIR=''
if [ $(basename $(pwd)) == "Keyboard_Over_Serial" ]; then
    RUN_DIR="$(pwd)/etc"
elif [ $(basename $(pwd)) == "etc" ]; then
    RUN_DIR=$(pwd)
else
    printf "\nMust run from inside the Keyboard_Over_Serial repoistory!\n\n"
    exit 1
fi

function check_rv() {
  rv=$1
  shift
  expected_rv=$1
  shift
  if [ "${rv}" -ne "${expected_rv}" ]; then
    printf "$*"
    exit 1
  fi
}    

printf "\n%s\n%s\n%s\n\n%s\n" \
    "This script will program an Arduino to act as a USB keyboard." \
    " The Arduino needs to be plugged in via USB and the UART needs to" \
    " be disconnected. Optionally, an LED can be connected to Digital Pin 2" \
    " Set up your hardware and press enter to continue..."
read
echo "Uploading keyboard program to device..."
make clean
check_rv $? 0 "error with gmake. Check the source code and Makefile.\n"
make
check_rv $? 0 "error with gmake. Check the source code and Makefile.\n"
make upload
check_rv $? 0 "error with gmake or avrdude. Check the source code and\n" \
              " Makefile. Confirm  that the correct\nboard model is\n" \
              " set in Makefile. Install avr-gcc/avr-g++/avrdude.\n"
printf "\n%s\n%s\n%s\n%s\n\n%s\n\n%s\n\n" \
    "Successfully uploaded the keyboard program. Proceeding to USB reset..." \
    "The USB chip needs to be flashed with the Keyboard frimware. To do" \
    " that, you need to jump the USB reset pins on the device. They may not" \
    " have headers soldered. Locate and jump those pads. The LED's might " \
    " flash, but it's not guaranteed" \
    " Press enter to continue...."
read
dfu-programmer atmega16u2 erase
check_rv $? 0 "error erasing USB controller. Try jumping the reset pins again"
sleep 2
dfu-programmer atmega16u2 flash ${RUN_DIR}/firmware/kbd.hex
check_rv $? 0 "error flashing the keyboard firmware to device.\n" \
              " Try re-running this script.\n"
sleep 2
dfu-programmer atmega16u2 reset
check_rv $? 0 "error resetting the device. It may have been properly flashed\n" \
              " anyway, unplug it for 10 seconds then test.\n"
sleep 2
printf "\n%s\n%s\n%s\n%s\n%s\n" \
        " USB controller as a keyboard! Now you need to unplug the deveice from" \
        " USB and power (it needs to be off) for 5-10 seconds. Afterwards, plug" \
        " it in and test the keyboard functionality by connecting the UART bridge" \
        " to pins 7 & 8 and connecting to the device with a terminal program at a" \
        "baud rate of 9600."
exit 0
