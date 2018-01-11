/* This version assumes line mode, where a buffer is passed from the terminal
* program to arduino.
*
*
*  To Use as keyboard, flash with keyboard firmware:
*
*  a45e60e88017:Ardu z050789$ dfu-programmer atmega16u2 erase
*  Checking memory from 0x0 to 0x2FFF...  Not blank at 0x1.
*  Erasing flash...  Success
*  a45e60e88017:Ardu z050789$ dfu-programmer atmega16u2 flash kbd.hex 
*  Checking memory from 0x0 to 0xFFF...  Empty.
*  0%                            100%  Programming 0x1000 bytes...
*  [>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]  Success
*  0%                            100%  Reading 0x3000 bytes...
*  [>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]  Success
*  Validating...  Success
*  0x1000 bytes written into 0x3000 bytes memory (33.33%).
*  a45e60e88017:Ardu z050789$ dfu-programmer atmega16u2 reset
*
*
*
*  To download new programs, flash with arduino USB firmware
*  :
*  a45e60e88017:Ardu z050789$ dfu-programmer atmega16u2 erase
*  Checking memory from 0x0 to 0x2FFF...  Not blank at 0x1.
*  Erasing flash...  Success
*  a45e60e88017:Ardu z050789$ dfu-programmer atmega16u2 flash usb.hex 
*  Checking memory from 0x0 to 0xFFF...  Empty.
*  0%                            100%  Programming 0x1000 bytes...
*  [>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]  Success
*  0%                            100%  Reading 0x3000 bytes...
*  [>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]  Success
*  Validating...  Success
*  0x1000 bytes written into 0x3000 bytes memory (33.33%).
*  a45e60e88017:Ardu z050789$ dfu-programmer atmega16u2 reset
*/

//Libraries
#include <NewSoftSerial.h>
//#include <Arduino.h>

//Function forward declarations
bool translateInput(unsigned char, uint8_t*);
void blinkLED(uint32_t, uint8_t);
void helpMe(uint8_t*);
//void buildCustomKeyBuffer(uint8_t*);

//File-level variables
const uint8_t clrBfr[8] = { 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
NewSoftSerial Serial1(7,8);

void initVariant() __attribute__((weak));
void initVariant() { }
void setupUSB() __attribute__((weak));
void setupUSB() { }

int main(void) {
  uint8_t kbdBfr[8] = { 0x00 };
  unsigned char inputChar;
//  uint32_t ct = 0;

  init();
  initVariant();
//#if defined(USBCON)
//  USBDevice.attach();
//#endif

  //Serial Ports
  Serial.begin(9600);
  while(!Serial);
  Serial1.begin(4800);
  Serial1.setTimeout(3000);
  pinMode(7, INPUT);
  pinMode(8, OUTPUT);

  //IO Pins
  pinMode(13, OUTPUT);
  digitalWrite(13, LOW);
  pinMode(2, OUTPUT);
  digitalWrite(2, LOW);
  blinkLED(100000, 13);
  blinkLED(100000, 13);
  blinkLED(100000, 2);
  blinkLED(100000, 2);
  while(1) {
    Serial1.listen();
    if(Serial1.available() > 0) {
      inputChar = Serial1.read();
      blinkLED(5000, 13);
//      Serial1.write(inputChar);

      if(inputChar == '`') {
//        buildCustomKeyBuffer(kbdBfr);
        blinkLED(150000, 2);
        helpMe(kbdBfr);
      }
//      else {
      for (uint8_t n = 0; n < 8; n++) {
        kbdBfr[n] = 0x00;
      }
      if(translateInput(inputChar, kbdBfr)) { //set buffer to inputed character
//      }
        blinkLED(5000, 2);
        Serial.write(kbdBfr, 8); //write input char
        Serial.write(clrBfr, 8); //write release key
      }
//    else {
//      if(ct > 100000) {
//        blinkLED(5000, 2);
//        ct = 0;
//        Serial1.print("!");
//      } else {
//        ct++;
//      }
    }
  }
}

void helpMe(uint8_t *kbdBfr) {
  char msg[10]={ 'H', 'E', 'L', 'P', ' ', 'M', 'E', '!', '!', '!' };
  for (uint16_t n = 0; n < 10; n++) {
    for (uint8_t j = 0; j < 8; j++)
      kbdBfr[j] = 0x00;
    translateInput(msg[n], kbdBfr);
    blinkLED(5000, 2);
    Serial.write(kbdBfr, 8); 
    Serial.write(clrBfr, 8);
  }
}
void blinkLED(uint32_t cycles, uint8_t pinNo) {
  for (uint32_t n = 0; n < (cycles >> 1); n++)
    digitalWrite(pinNo, HIGH);
  for (uint32_t n = 0; n < (cycles >> 1); n++)
    digitalWrite(pinNo, LOW);
}


/*void buildCustomKeyBuffer(uint8_t *kbdBfr) {
  blinkLED(100000, 2);
  blinkLED(100000, 2);  
  Serial1.println("\nConstruct custom packet...\n");
  for(uint8_t n = 0; n < 8; n++) {
    Serial1.print("\nEnter buffer[");
    Serial1.print(n);
    Serial1.print("] value: ");
    kbdBfr[n] = Serial1.parseInt();
  }
  Serial1.println("\nSending: ");
  for(uint8_t n = 0; n < 8; n++) {
    Serial1.print(kbdBfr[n]);
    Serial1.print(" ");
  }
}*/

bool translateInput(unsigned char inputVal, uint8_t *kbdBfr) {
    
  switch(inputVal) {
    case 0x0D:
      kbdBfr[0] = 0;
      kbdBfr[2] = 0x28; //enter
      break;
    case 0x08:
      kbdBfr[0] = 0;
      kbdBfr[2] = 0x2A; //delete
      break;
    case 0x1B:
      kbdBfr[0] = 0;
      kbdBfr[2] = 0x29; //escape
      break;
    case 0x01:
      kbdBfr[0] = 0xE0;
      kbdBfr[2] = 0x04; //ctrl-a
      break;
    case 0x1A:
      kbdBfr[0] = 0xE0;
      kbdBfr[2] = 0x1D; //ctrl-z
      break;
    case 0x03:
      kbdBfr[0] = 0xE0;
      kbdBfr[2] = 0x06; //ctrl-c
      break;
    case 0x16:
      kbdBfr[0] = 0xE0;
      kbdBfr[2] = 0x19; //ctrl-v
      break;
    case 0x1F:
      kbdBfr[0] = 0;
      kbdBfr[2] = 0x51;//down arrow
      break;
    case 0x1D:
      kbdBfr[0] = 0;
      kbdBfr[2] = 0x4F;//right arrow
      break;
    case 0x1E:
      kbdBfr[0] = 0;
      kbdBfr[2] = 0x52; //up arrow
      break;
    case 0x1C:
      kbdBfr[0] = 0;
      kbdBfr[2] = 0x50; //left arrow
      break;
    case 'a':
      kbdBfr[2] = 0x04;
      break; 
    case 'b':
      kbdBfr[2] = 0x05;
      break; 
    case 'c':
      kbdBfr[2] = 0x06;
      break; 
    case 'd':
      kbdBfr[2] = 0x07;
      break; 
    case 'e':
      kbdBfr[2] = 0x08;
      break; 
    case 'f':
      kbdBfr[2] = 0x09;
      break; 
    case 'g':
      kbdBfr[2] = 0x0A;
      break; 
    case 'h':
      kbdBfr[2] = 0x0B;
      break; 
    case 'i':
      kbdBfr[2] = 0x0C;
      break; 
    case 'j':
      kbdBfr[2] = 0x0D;
      break; 
    case 'k':
      kbdBfr[2] = 0x0E;
      break; 
    case 'l':
      kbdBfr[2] = 0x0F;
      break; 
    case 'm':
      kbdBfr[2] = 0x10;
      break; 
    case 'n':
      kbdBfr[2] = 0x11;
      break; 
    case 'o':
      kbdBfr[2] = 0x12;
      break; 
    case 'p':
      kbdBfr[2] = 0x13;
      break; 
    case 'q':
      kbdBfr[2] = 0x14;
      break; 
    case 'r':
      kbdBfr[2] = 0x15;
      break; 
    case 's':
      kbdBfr[2] = 0x16;
      break; 
    case 't':
      kbdBfr[2] = 0x17;
      break; 
    case 'u':
      kbdBfr[2] = 0x18;
      break; 
    case 'v':
      kbdBfr[2] = 0x19;
      break; 
    case 'w':
      kbdBfr[2] = 0x1A;
      break; 
    case 'x':
      kbdBfr[2] = 0x1B;
      break; 
    case 'y':
      kbdBfr[2] = 0x1C;
      break; 
    case 'z':
      kbdBfr[2] = 0x1D;
      break; 
    case 'A':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x04;
      break; 
    case 'B':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x05;
      break; 
    case 'C':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x06;
      break; 
    case 'D':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x07;
      break; 
    case 'E':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x08;
      break; 
    case 'F':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x09;
      break; 
    case 'G':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x0A;
      break; 
    case 'H':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x0B;
      break; 
    case 'I':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x0C;
      break; 
    case 'J':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x0D;
      break; 
    case 'K':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x0E;
      break; 
    case 'L':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x0F;
      break; 
    case 'M':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x10;
      break; 
    case 'N':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x11;
      break; 
    case 'O':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x12;
      break; 
    case 'P':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x13;
      break; 
    case 'Q':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x14;
      break; 
    case 'R':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x15;
      break; 
    case 'S':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x16;
      break; 
    case 'T':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x17;
      break; 
    case 'U':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x18;
      break; 
    case 'V':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x19;
      break; 
    case 'W':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x1A;
      break; 
    case 'X':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x1B;
      break; 
    case 'Y':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x1C;
      break; 
    case 'Z':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x1D;
      break; 
    case '1': 
      kbdBfr[2] = 0x1E;
      break;
    case '!':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x1E;
      break;
    case '2':
      kbdBfr[2] = 0x1F;
      break;
    case '@':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x1F;
      break;
    case '3': 
      kbdBfr[2] = 0x20;
      break;
    case '#':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x20;
      break;
    case '4':
      kbdBfr[2] = 0x21;
      break;
    case '$':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x21;
      break;
    case '5':
      kbdBfr[2] = 0x22;
      break;
    case '%':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x22;
      break;
    case '6':
      kbdBfr[2] = 0x23;
      break;
    case '^':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x23;
      break;
    case '7':
      kbdBfr[2] = 0x24;
      break;
    case '&':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x24;
      break;
    case '8':
      kbdBfr[2] = 0x25;
      break;
    case '*':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x25;
      break;
    case '9':
      kbdBfr[2] = 0x26;
      break;
    case '(':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x26;
      break;
    case '0':
      kbdBfr[2] = 0x27;
      break;
    case ')':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x27;
      break;
    case '\t':
      kbdBfr[2] = 0x2B;
      break; 
    case ' ':
      kbdBfr[2] = 0x2C;
      break; 
    case '-':
      kbdBfr[2] = 0x2D;
      break;
    case '_':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x2D;
      break; 
    case '=': 
      kbdBfr[2] = 0x2E;
      break;
     case '+':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x2E;
      break;
    case '[': 
      kbdBfr[2] = 0x2F;
      break;
    case '{':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x2F;
      break; 
    case ']': 
      kbdBfr[2] = 0x30;
      break;
    case '}':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x30;
      break; 
    case '\\': 
      kbdBfr[2] = 0x31;
      break;
    case '|':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x31;
      break; 
    case ';': 
      kbdBfr[2] = 0x33;
      break;
    case ':':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x33;
      break; 
    case '\'': 
      kbdBfr[2] = 0x34;
      break;
    case '\"':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x34;
      break; 
    case '`': 
      kbdBfr[2] = 0x35;
      break;
    case '~':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x35;
      break; 
    case ',': 
      kbdBfr[2] = 0x36;
      break;
    case '<':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x36;
      break; 
    case '.': 
      kbdBfr[2] = 0x37;
      break;
    case '>':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x37;
      break; 
    case '/': 
      kbdBfr[2] = 0x38;
      break;
    case '?':
      kbdBfr[0] = 0x02;
      kbdBfr[2] = 0x38;
      break; 
    default:
//      kbdBfr[0] = 0x00;
//      kbdBfr[2] = 0x00;
      return false;
 /*
TBD:
Caps Lock 0x39 
F1 0x3A 
F2 0x3B 
F3 0x3C 
F4 0x3D 
F5 0x3E 
F6 0x3F 
F7 0x40 
F8 0x41 
F9 0x42 
F10 0x43 
F11 0x44 
F12 0x45 
Locking Caps Lock 0x82 
LeftControl 0xE0 
LeftShift 0xE1 
LeftAlt 0xE2 
Left GUI (apple) 0xE3 
*/
  }
  return true;
}


