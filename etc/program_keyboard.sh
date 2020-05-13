#!/bin/bash

echo "This script will program an Arduino to act as a USB keyboard. The Arduino needs to be plugged in via USB and"
echo "the UART needs to be disconnected. Optionally, an LED can be connected to Digital Pin 2."
echo "Set up your hardware and press enter to continue..."
read

echo "Uploading keyboard program to device..."
make clean
if [ $? != 0 ]; then
  echo "error with gmake. Check the source code and Makefile."
  exit -1
fi

make
if [ $? != 0 ]; then
  echo "error with gmake. Check the source code and Makefile."
  exit -1
fi

make upload
if [ $? != 0 ]; then
  echo "error with gmake or avrdude. Check the source code and Makefile. Confirm  that the correct"
  echo "board model is specified in the Makefile. Make sure avr-gcc/avr-g++/avrdude are installed."
  exit -1
fi
sleep 2

echo "Successfully uploaded the keyboard scan code program. Proceeding to USB reset..."
sleep 2

echo "The USB chip needs to be flashed with the Keyboard frimware."
echo "To do that, you need to jump the USB reset pins on the device. They may not have headers soldered. Locate and"
echo "jump those pads. The LED's might flash, but it's not guaranteed"
echo "Press enter to continue..."
read

dfu-programmer atmega16u2 erase
if [ $? != 5 ]; then
  echo "error erasing USB controller. Try jumping the reset pins again"
  exit -1
fi
sleep 2

dfu-programmer atmega16u2 flash firmware/kbd.hex 
if [ $? != 0 ]; then
  echo "error flashing the keyboard firmware to device. Try re-running this script."
  exit -1
fi
sleep 2

dfu-programmer atmega16u2 reset
if [ $? != 0 ]; then
  echo "error resetting the device. It may have been properly flashed anyway, unplug it for 10 seconds then test."
  exit -1
fi
sleep 2

echo "Successfully uploaded the keyboard scan code emulator and flashed the USB controller as a keyboard!"
echo "Now you need to unplug the deveice from USB and power (it needs to be off) for 5-10 seconds."
echo "Afterwards, plug it in and test the keyboard functionality by connecting the UART bridge to pins 7 & 8"
echo "and connecting to the device with a terminal program at a baud rate of 9600."
exit 0

