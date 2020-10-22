#!/bin/bash

install_path=$(pwd)
if [ ! "$(basename ${install_path})" == "etc" ] \
	&& [ -d "${install_path}/etc" ]; then
  install_path="${install_path}/etc"
else
    printf "Must run from inside the keyboard_over_serial directory\n\n"
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

printf "%s\n%s\n%s\n\n" \
       "This will program an Arduino with the default bootloader so that new" \
       "programs can be uploaded. The UART needs to be disconnected." \
       "Set up your hardware and press enter to continue..."
read

printf "%s\n%s\n%s\n%s\n%s\n\n" \
       "The USB chip needs to be flashed with the USB frimware." \
       "To do that, you need to jump the USB reset pins on the device." \
       "They may not have headers soldered. Locate and jump those pads." \
       "The LED's might flash, but it's not guaranteed." \
       "Press enter to continue..."
read

dfu-programmer atmega16u2 erase
check_rv $? 5 "error erasing USB controller. Try jumping the reset pins again"

dfu-programmer atmega16u2 flash "${install_path}/firmware/usb.hex"
check_rv $? 0 "error flashing the USB firmware. Try re-running this script."

dfu-programmer atmega16u2 reset
check_rv $? 0 "error flashing the USB firmware. Try re-running the script.\n" \
              "error resetting device. It may have been flashed anyway.\n" \
              "unplug it for 10 seconds then test."

printf "%s\n%s\n%s\n\n" \
       "Successfully flashed the USB controller with the standard firmware!" \
       "Now unplug the device from power and USB (must power off)." \
       "Then plug it back in, and should function normally."

