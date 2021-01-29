extern byte tempV1;
extern byte tempV2;

extern "C" {
  void setupTherm();
  void readTherm();
}
void setup() {
  Serial.begin(9600); // initialize serial window
  setupTherm();       // initialize thermometer (this calls your assembly code)

}

void loop() {
  delay(2000); // delay for two seconds
  readTherm(); // read the thermometer (this calls your assembly code)
  int tempF = ((tempV1 * 10) + ((tempV2 * 10) /256)) * 9 / 5 + 320;
  Serial.print("Integer degree part: ");
  Serial.println(tempV1, DEC);  // print out first byte in decimal
  Serial.print("Fractional degree part: ");
  Serial.println(tempV2, DEC);  // print out second byte in hex
  Serial.print("Fahrenheit: ");
  Serial.println(tempF, DEC);  // print out first byte in decimal

}
