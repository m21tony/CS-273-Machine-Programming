//
// Declare the things that exist in our assembly code
//
extern "C" { 
  void control();
  void runMotors();
  void controlMotor();
}

//
// Arduino-required setup function (called once)
//
void setup()
{
  //
  // Initialize serial communications (for loop() function)
  //
  Serial.begin(9600);
  runMotors();
  controlMotor();
}

//
// Arduino-required loop function (called infinitely)
//
void loop()
{
  delay(2000); // 2,000 millisecs == 2 seconds
  Serial.println("*"); // debug output just to show we got here
}

