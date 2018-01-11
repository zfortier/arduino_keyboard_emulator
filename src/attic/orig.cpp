
#include <SoftwareSerial.h>
#include <Keyboard.h>
uint8_t kbdBfr[8] = { 0 };
SoftwareSerial Serial1(11, 12);
char retVal[] = "0x00";
bool enterFlag = 0;

void setup() 
{
  Serial.begin(9600);
  while(!Serial);
  Serial1.begin(9600);
  while(!Serial1);
  kbdBfr[0] = 0;
  //Keyboard.begin();
}

void loop() 
{
  /*
  while(Serial1.available() ) {
//    kbdBfr[0] = 0;
    kbdBfr[2] = Serial1.read();
    Serial1.write(Serial1.peek());
    //Serial.write(Serial1.read());
    Serial.write(kbdBfr, 8);
    Serial1.write(kbdBfr, 8);
//    kbdBfr[0] = 0;
//    kbdBfr[2] = 0x15;
//    Serial1.println(kbdBfr[2]);
//    Serial.write(kbdBfr, 8);
//    kbdBfr[0] = 0;
    kbdBfr[2] = 0;
    Serial.write(kbdBfr, 8);
  } 
  */
/*    kbdBfr[0] = 0;
    kbdBfr[2] = 0x1D;
    Serial.write(kbdBfr, 8);
    kbdBfr[2] = 0;
    Serial.write(kbdBfr, 8);
    
    kbdBfr[0] = 0;
    kbdBfr[2] = 0x04;
    Serial.write(kbdBfr, 8);
    kbdBfr[2] = 0;
    Serial.write(kbdBfr, 8);
    
    kbdBfr[0] = 0;
    kbdBfr[2] = 0x0E;
    Serial.write(kbdBfr, 8);
    kbdBfr[2] = 0;
    Serial.write(kbdBfr, 8);
*/
  while(Serial1.available() ) {
    kbdBfr[0] = 0;
    translateInput(Serial1.read()); //set buffer to inputed character
    Serial.write(kbdBfr, 8); //write input char
    kbdBfr[2] = 0; //relase key
    Serial.write(kbdBfr, 8); //write release key
    enterFlag = 1;
  }

  if(enterFlag) {
    kbdBfr[2] = 0x28; //enter
    Serial.write(kbdBfr, 8);//write enter
    kbdBfr[2] = 0; //release
    Serial.write(kbdBfr, 8); //write release
    enterFlag = 0;
  }
}

void translateInput(char inputVal) {
  
switch(inputVal) {
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

//  default:
//    Serial1.println(inputVal);
  }
}


