#include "avr/io.h"
#include "avr/interrupt.h"

//
// Assembly functions
//
extern byte eastLight;
extern byte westLight;
extern byte westSwitchPressed;
extern byte parked;
int readings;                                     // number of photosensaor readings to display
byte lightVals[25];      

extern "C" {
   void initializePanel();
   void operatePanel();
   void returnPanel();
   void parkPanel();
   void resetPanel();
   int  queryPanel(byte lightVals[]);
   byte sensorEast();
   byte sensorWest();
   void fill();
}

//
// If there is any serial input, read it into the
// given array; the array MUST be at least 32 chars long
// - returns true if a string is read in, false otherwise
// (note: 9600baud (bits per second) is slow so we need
//  to have delays so that we don't go too fast)
//
boolean readUserCommand(char cmdString[])
{
   if (!Serial.available())
      return false;
   delayMicroseconds(5000); // allow serial to catch up
   int i=0;
   while (i < 31) {
      cmdString[i++] = Serial.read();
      delayMicroseconds(1000);
      if (!Serial.available())
         break; // quit when no more input
   }
   cmdString[i] = '\0'; // null-terminate the string
   while (Serial.available()) {
      Serial.read(); // flush any remain input (more than 31 chars)
      delayMicroseconds(1000);
   }
   return true;
}

ISR (TIMER1_COMPA_vect)
{
  fill();
  TCCR1B = 0; 
  TCCR1B = 0b00001101;                                 // Timer counter control register B using CTC mode and a prescaler of clk/1024
  OCR1A =  0xBFFF;
}

//
// Code that uses the functions
//
void setup()
{
   Serial.begin(9600);
 
   Serial.println("Initialize Panel..");
   
   initializePanel();
   
   
   // START THE TIMER
                                         
   TCCR1A = 0b00000000;                                 // Timer counter control register A using CTC mode    
   TCCR1B = 0; 
   TCCR1B = 0b00001101;                                 // Timer counter control register B using CTC mode and a prescaler of clk/1024
   // TIMER INTERRUPT INITIALIZATION
   TIMSK1 = (1 << OCIE1A);
   OCR1A =  0xBFFF;
   sei();   
   
   Serial.println("Ready.");
}

//
// In order to process user command AND operate the
// solar panel, the loop function needs to poll for
// user input and then invoke "operatePanel" to allow
// the panel operation code to do what it needs to 
// for ONE STEP. You should not do a continuous loop
// in your assembly code, but just cycle through
// checking everything you need to one time, and then
// returning back and allowing the loop function here
// continue.
//
void loop()
{
   char cmd[32];                                        
                               // array of photosensor values

    delayMicroseconds(100); // no need to go too fast                                          
   
    cmd[0] = '\0'; // reset string to empty
   if (readUserCommand(cmd)) {
      // this if statement just shows that command strings
      // are being read; it serves no other useful purpose
      // and can be deleted or commented out
      Serial.print("User command is (");
      Serial.print(cmd);
      Serial.println(")");
   }
   // The conditions below recognize each individual
   // command string; all they do now is print, but you
   // will need to add code to do the proper actions
   if (!strcmp(cmd,"reset")) 
   {
      Serial.println("Reseting panel...");
      resetPanel();                                     //call the resetPanel function
      Serial.println("Reset complete.");
      
   } 
   else if (!strcmp(cmd,"park")) 
      {
        Serial.println("Parking panel...");      
        parkPanel();  // call parkPanel() function

        Serial.println("Parking complete.");        
      }     
      else if (!strcmp(cmd,"query")) 
        {      
          Serial.println("Querying panel...");      
          int i;
          int count = 0;
          readings = queryPanel(lightVals);          // call queryPanel function      
          Serial.print("Sensor Readings: ");
          for (i = 0; i < readings; i++)             // print array values
          {
            if(lightVals[i] != 0)
            {
              Serial.print(lightVals[i]);
              Serial.print(", ");
              count++;
            }
          }
          if(count < readings)
          {
            while(count < readings)
            {
              Serial.print('0');
              Serial.print(", ");
              count++;
            }
          }
          Serial.println("\nQuery complete.");

        } 
        else if (!strcmp(cmd,"return")) 
          {        
            Serial.println("Returning panel..."); 
            returnPanel();                              // call returnPanel function
            Serial.println("Return complete.");
  
          }
        
     
   // This invokes your assembly code to do ONE STEP of
   // operating the solar panel
   
   operatePanel();     
   
}

