#!/bin/bash

RUN_DIR=''
if [ "$(basename $(pwd))" == "Keyboard_Over_Serial" ]; then
    RUN_DIR="$(pwd)/etc"
elif [ "$(basename $(pwd))" == "etc" ]; then
    RUN_DIR="$(pwd)"
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

printf "\n%s\n%s\n\n%s\n" \
    "This will program an Arduino with the default bootloader so that new" \
    "programs can be uploaded. The UART needs to be disconnected." \
    "Set up your hardware and press enter to continue..."
read

printf "\n%s\n%s\n%s\n%s\n\n%s\n" \
    "The USB chip needs to be flashed with the USB frimware." \
    "To do that, you need to jump the USB reset pins on the device." \
    "They may not have headers soldered. Locate and jump those pads." \
    "The LED's might flash, but it's not guaranteed." \
    "Press enter to continue..."
read

dfu-programmer atmega16u2 erase
check_rv $? 0 "error erasing USB controller. Try jumping the reset pins again"
dfu-programmer atmega16u2 flash ${RUN_DIR}/firmware/usb.hex 
check_rv $? 0 "error flashing the usb firmware. Try re-running this script.\n"
dfu-programmer atmega16u2 reset
check_rv $? 0 "error resetting device. It may have been properly flashed\n" \
              " anyway, unplug it for 10 seconds then test.\n"
printf "%s\n%s\n%s\n\n" \
    "Successfully flashed the USB controller with the standard firmware!" \
    "Now you need to unplug device from power and USB (must power off)." \
    "Then plug back in, and it should function normally."

