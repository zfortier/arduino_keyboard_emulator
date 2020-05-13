#!/bin/bash

echo "This will program an Arduino with the default bootloader so that new"
echo "programs can be uploaded. The UART needs to be disconnected."
echo "Set up your hardware and press enter to continue..."
read

echo "The USB chip needs to be flashed with the USB frimware."
echo "To do that, you need to jump the USB reset pins on the device."
echo "They may not have headers soldered. Locate and jump those pads."
echo "The LED's might flash, but it's not guaranteed."
echo "Press enter to continue..."
read

dfu-programmer atmega16u2 erase
if [ $? != 5 ]; then
  echo "error erasing USB controller. Try jumping the reset pins again"
  exit -1
fi
sleep 2

dfu-programmer atmega16u2 flash firmware/usb.hex 
if [ $? != 0 ]; then
  echo "error flashing the USB firmware to device. Try re-running this script."
  exit -1
fi
sleep 2

dfu-programmer atmega16u2 reset
if [ $? != 0 ]; then
  echo "error resetting the device. It may have been properly flashed anyway."
  echo "unplug it for 10 seconds then test."
  exit -1
fi
sleep 2

echo "Successfully flashed the USB controller with the standard firmware!"
echo "Now you need to unplug the device from power and USB (must power off)."
echo "Then plug it back in, and should function normally."
exit 0

