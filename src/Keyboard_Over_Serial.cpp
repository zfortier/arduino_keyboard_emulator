#include "usbKeyboardMapping.h"
#include "keyboard_over_serial.h"

int main(void) {
  uint8_t keyboard_buffer[8] = { 0x00 };
  SoftwareSerial uart(7,8);
  init();
  Serial.begin(9600);
  uart.begin(9600);
  uart.setTimeout(3000);
  pinMode(13, OUTPUT);
  pinMode(2, OUTPUT);
  digitalWrite(13, LOW);
  digitalWrite(2, LOW);
  blinkLED(100000, 13);
  blinkLED(100000, 2);
  while(1) {
    // Could save power by sleeping the arduino here, but ehh..
    memset(keyboard_buffer, 0, 8);
    if(uart.available()) {
      blinkLED(1000, 13);
      if(translateInput(uart.read(), keyboard_buffer)) {
        blinkLED(1000, 2);
        Serial.write(keyboard_buffer, 8); 
        Serial.write(clear_command, 8);
      }
    }
  }
}


void blinkLED(uint32_t cycles, uint8_t pinNo) {
  for (uint32_t n = 0; n < (cycles >> 1); n++)
    digitalWrite(pinNo, HIGH);
  for (uint32_t n = 0; n < (cycles >> 1); n++)
    digitalWrite(pinNo, LOW);
}


bool translateInput(unsigned char inputVal, uint8_t *keyboard_buffer) {
  for(uint16_t mapIdx = 0; mapIdx < keyCount; mapIdx++) {
    if(inputVal == keyboard_map[mapIdx][0]) {
      keyboard_buffer[0] = keyboard_map[mapIdx][1];
      keyboard_buffer[2] = keyboard_map[mapIdx][2];
      return true;
    }
  }
  return false;
}
