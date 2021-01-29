
//
// Declare the things that exist in our assembly code
//
extern "C" { 
  void display_symbol();
  void display_symbol_1();
  void display_symbol_2();
  void display_symbol_3();
  void display_symbol_4();
  void display_symbol_5();
}

extern byte symbol, symbol1, symbol2, symbol3, symbol4;

//
// Arduino-required setup function (called once)
//
void setup()
{
  //
  // Initialize serial communications (for loop() function)
  //
  Serial.begin(9600);

//  while (!Serial.available()) delay(100);
//  String string = Serial.readString();
//
//  symbol = string[0]; // only take the first symbol to display
//   
scroll();
//   display_symbol();
 
}

void scroll(){
  //get four-character input from user
  Serial.println("Enter four characters (0-9, A-Z): ");
  while (!Serial.available()) delay(100);
  String string = Serial.readString();
  Serial.println("String read.");
 Serial.println(string);
  symbol1 = string[3];
  symbol2 = string[2];
  symbol3 = string[1];
  symbol4 = string[0];
  Serial.println("String read.");
  int i = 0;
  for (i = 0; i < 8; i++){
    display_symbol_1();
    delay(400);
    display_symbol_2();
    delay(400);
    display_symbol_3();
    delay(400);
    display_symbol_4();
    delay(400);
    display_symbol_5();
    delay(400);
    
  }
  }
//
// Arduino-required loop function (called infinitely)
//
void loop()
{
  delay(2000); // 2,000 millisecs == 2 seconds
  Serial.println("*"); // debug output just to show we got here
}

