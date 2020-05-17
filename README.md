### Overview

This project is intended to provide a clean and reliable mechanism for 
programming a microcontroller to emulate a USB keyboard, using this set up:
```
  +--------------------+  USB                                (RasPi Zero)
  |      PC/Laptop     |<-----> UART-USB Bridge         +-------------------+
  | (Serial Interface) |         (ex: CP2102)           | Target System USB |
  +--------------------+             ^                  +-------------------+
                                     |                             ^
                         Tx -> Pin 7 |                             |
                         Rx -> Pin 8 |                             | USB -> USB
                                     |  (Arduino Uno or Pro Mini)  |
                              +----- V --------------------------- V -+
                              |  MCU Board IO Pins <-> MCU Board USB  |
                              +---------------------------------------+
```
Once everything is programmed and connected correctly, you should be able to
connect to the MCU using a serial terminal program on a PC or laptop. Keyboard
input to the terminal program will be relayed through the MCU to the target.
This sounds like an extremely simple setup, and it is.... mostly. There are
enough 'gotchas' lurking that I felt it was worth the extra effort to package
everything up into an easily usable bundle, to prevent future headaches.

#### Details

This program allows an Arduino Uno R3 to simulate a USB keyboard on it's USB
port. The Uno reads it's input from a Software Serial connection, translates to
the corresponding USB scan code, constructs the IEEE standardized keystroke
data buffer, and sends that data buffer to the target system via the USB port. 

The input connection to the Arduino is from a computer running a serial
terminal program, using a UART-USB bridge adapter connected to the USB port.
The adapters  Rx/Tx pins are wired to the appropriate digital I/O pins on the
Arduino, and *the ground pin of the bridge adapter bonded to the ground pin on
the Arduino*. The shared ground is needed to prevent Arduino from picking up
noise on the serial connection from a floating ground and treating it as valid
traffic-- and writing lots of garbage to the output... It's best to just bond
all of the grounds from each of the 4 silicon boards and avoid any problems.

### Programming Steps

Connect the Arduino:
```
  (Arduino 7) -> (UART Tx) 
  (Arduino 8) -> (UART Rx)
  (Arduino Ground) -> (UART Ground) -> (RasPi Ground)
```

#### To Use as keyboard, flash with keyboard firmware:
```
bash-$ ./etc/program_keyboard.sh
[...]
```

or do it manaully:
```
bash-$ dfu-programmer atmega16u2 erase
Checking memory from 0x0 to 0x2FFF...  Not blank at 0x1.
Erasing flash...  Success
bash-$ dfu-programmer atmega16u2 flash kbd.hex 
Checking memory from 0x0 to 0xFFF...  Empty.
0%                            100%  Programming 0x1000 bytes...
[>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]  Success
0%                            100%  Reading 0x3000 bytes...
[>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]  Success
Validating...  Success
0x1000 bytes written into 0x3000 bytes memory (33.33%).
bash-$ dfu-programmer atmega16u2 reset
```

#### To restore the standard arduino USB firmware:
```
bash-$ ./etc/program_usb.sh
```

or do it manually:
```
bash-$ dfu-programmer atmega16u2 erase
Checking memory from 0x0 to 0x2FFF...  Not blank at 0x1.
Erasing flash...  Success
bash-$ dfu-programmer atmega16u2 flash usb.hex 
Checking memory from 0x0 to 0xFFF...  Empty.
0%                            100%  Programming 0x1000 bytes...
[>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]  Success
0%                            100%  Reading 0x3000 bytes...
[>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]  Success
Validating...  Success
0x1000 bytes written into 0x3000 bytes memory (33.33%).
bash-$ dfu-programmer atmega16u2 reset
```
