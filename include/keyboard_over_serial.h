#ifndef KEYBOARD_OVER_SERIAL_
  #define KEYBOARD_OVER_SERIAL_
  #include <SoftwareSerial.h>
  #include <Arduino.h>
  
  bool translateInput(unsigned char, uint8_t*);
  void blinkLED(uint32_t, uint8_t);
#endif  
