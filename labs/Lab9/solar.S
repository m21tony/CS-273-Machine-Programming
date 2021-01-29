    
  // MOTOR setup
      .set PORTD,0x0B
      .set DDIRD,0x0A
      .set MOTDATA,0
      .set MOTLATCH,4
      .set M1ENABLE,3
      .set BOARDLED, 5
           

  // PHOTOSENSORS
      .set DIDR0, 0x7E 
      .set ADMUX, 0X7C
      .set ADCSRA, 0X7A 
      .set ADCL, 0X78
      .set ADCH, 0X79

  // SWITCHES setup
      .set PORTB,0x05
      .set DDIRB,0x04
      .set PINB, 0x03
      .set SWITCH2, 2
      .set SWITCH1, 1
      .set MOTCLOCK,4
      .set M2ENABLE,3
      .set M4ENABLE,6
      .set M3ENABLE,5

  // Status Register
      .set SREG, 0x3F 

  //LIGHTS
      .set PORTLED, 0x04
      .set LED, 0x05  

//
// External symbols
//
      .extern delay

.MACRO PUSHALL
      PUSH R16
      PUSH R17
      PUSH R18
      PUSH R19
      PUSH R20
      PUSH R21
      PUSH R22
      PUSH R23
      PUSH R24
      PUSH R25    
.ENDM

.MACRO POPALL
      POP R25
      POP R24
      POP R23
      POP R22
      POP R21
      POP R20
      POP R19
      POP R18
      POP R17
      POP R16
.ENDM
  
//
// Global data
//
      .data      
      .comm westLight, 1
      .global westLight
      .comm eastLight, 1
      .global eastLight
      .comm values, 25
      .comm index, 1
      .comm sunsetWest, 1
      .comm sunsetEast, 1
      .comm threshold, 1
      .comm tolerance, 1
      .comm westSwitchPressed, 1
      .global westSwitchPressed
      .comm parked, 1
      .global parked
      
      .text
      .global operatePanel, initializePanel, returnPanel, resetPanel, parkPanel, queryPanel, sensorEast, sensorWest, fill
      

//initializePanel function:
//    initializes motor, light sensors, and switches
//    calls the resetPanel function
initializePanel:

      PUSHALL
      ldi   r18, 0
      sts   index, r18
      sts   sunsetEast, r18
      sts   sunsetWest, r18
      sts   westSwitchPressed, r18
      sts   parked, r18
      ldi   r18, 101
      sts   threshold, r18
      ldi   r18, 3
      sts   tolerance, r18       
      
      call enableMotor
      call initLightSensors
      call initSwitches     
      call resetPanel      
      
      LDI    R16,     3     
      flashLED: 
          ldi    r21, 0x20   
          sbi   PORTB, BOARDLED 
          call   delayLED      
          cbi   PORTB, BOARDLED 
          call   delayLED      
          DEC    R16
          brne   flashLED         
          POPALL
          ret


      
//operatePanel function:
//    determines if light is unbalanced
//    moves in appropriate direction accordingly
operatePanel:
    
      //check if it is dark
      PUSHALL
      call  sensorEast
      call  sensorWest
      ldi r16, 1
      lds r18, sunsetWest
      lds r19, westSwitchPressed
      lds r23, parked
      cp  r23, r16
      brsh  ENDOPERATION
      cp  r18, r16
      brlo notSunset
      cp  r19, r16
      brlo notSunset
    
      sunset: 
          call returnPanel
          jmp ENDOPERATION

      //in the event that it isn't dark
      notSunset:    
          lds   R20, westLight
          lds   R21, eastLight
          cp    R20, R21              // compare west light with east light values
          breq  ENDOPERATION          // if east is equal to west, end operation
          brlo  EASTMOVE              
      
          lds   r22, tolerance
          sub   r20, r21
          cp    r20, r22   
          brlo  ENDOPERATION
          ;call  switchWest
          call  moveWest              // else if west is greater than east, move west    
          ;call  switchWest
          call  stopMotor
          lds   r21, eastLight
          add   r21, r20
          sts   eastLight, r21
          jmp   ENDOPERATION
    
      EASTMOVE: 
          lds   r22, tolerance
          lds   r20, westLight
          sub   r21, r20
          cp    r21, r22
          brlo  ENDOPERATION       
          ;call  switchEast                 
          call  moveEast              // else move east
          ;call  switchEast
          call  stopMotor
          lds   r20, eastLight
          add   r20, r21
          sts   eastLight, r20
       
      ENDOPERATION:
          POPALL
          ret


//returnPanel function:
//    causes the solar panel to return to the east
returnPanel:  
      PUSHALL
      ldi   r16, 0
      sts   parked, r16   
      //rotate panel to full east
  LReturn:
      call  enableMotor
      sbi   PORTD, M2ENABLE       
      ldi   r24, 0b11011000   // all motors 1 direction
      call  sendMotorByte          
      sbi   PORTB, BOARDLED   ; turn on arduino board LED
      call  delayLED    
      sbic  PINB, SWITCH2     // skip next instruction if East switch is depressed
      rjmp  LReturn
      call  switchEast
      call  stopMotor       
      POPALL
      ret


//resetPanel function: 
//    causes the solar panel to return to the east 
//    then to immediately starts tracking the sun
resetPanel:
            
      call returnPanel        // return panel to the east        
      call CLEARALL           // clear contents in sensor array
      ret


//parkPanel function:  
//    causes the solar panel to stay at its current position 
//    until a return or reset command is given
parkPanel:

      call  stopMotor
      call  disableMotor        
      ldi   r16, 1
      sts   parked, r16
      ret



//queryPanel function:  
//    requests information on how much light has been hitting the panel recently
queryPanel:
      //take light sensor reading
      //store in array, increment array pointer
      //delay 3 seconds
      //repeat 25 times
      PUSH r18
      PUSH r19
      PUSH r20
      ldi r26, lo8(values)
      ldi r27, hi8(values)
      mov r28, r24
      mov r29, r25
      ldi r19, 0   
      ldi r18, 25
      
      queryLoop:            
          ld  r20, X+
          st  Y+,  r20
          inc r19
          cp  r19, r18
          brne queryLoop
          ldi r25, 0
          mov r24, r18
          POP r20
          POP r19
          POP r18
          call CLEARALL
          ret
     

//CLEARALL causes all stored values to be thrown away
CLEARALL:
      PUSHALL   
      ldi r26, lo8(values)
      ldi r27, hi8(values)
      ldi r19, 0
      ldi r18, 25
      clearLoop:      
          ldi  r20, 0
          st  x+,  r20
          inc r19
          cp  r19, r18
          brne clearLoop
          POPALL
          ret
          


//                  
// SENSOR FUNCTIONS  
//                   

initLightSensors:
      PUSH  R16
      ldi   R16, 0b00111111   // load 0b0001 1111 into register r16
      sts   DIDR0, R16        // turn off all digital input buffers
      ldi   R16, 0b10000111   // load 0b1000 0111 into register r16
      sts   ADCSRA, R16       // initialize ADEN and divide systyem clock by 128
      POP   R16
      ret

//sensorEast function
sensorEast:
      ldi R24, 4            // A/D PIN 5 which is photosensor east      
      ldi R18, 0b01100000   // value to be added to parameter R24 before loading into ADMUX
      add R24,R18           // add 0b0110 0000 to parameter r24
      sts ADMUX, R24        // select the +5v as reference, left adjust output bits and denote pin A5
      ldi R16, 0b11000111   // load 0b0100 0000 into register r16
      sts ADCSRA, R16       // start a conversion
      ldi R16, 0b10011111   // connect all inputs to ADC
      LE:
          lds R17, ADCSRA       // load register ADCSRA into register 17
          sbrc r17,6            // read ADSC until it reads 0 (one read is 13-14 cycles)
          jmp LE             
        
          lds r24, ADCH  ; fetch result from ADCH
          subi r24, 0x03
          ldi r16, 0x58
          add r24, r16
          sts eastLight, r24
          CLR R25       
          ldi r19, 0
          sts sunsetEast, r19
          ret

//sensorWest function
sensorWest:
      ldi R24, 2            // A/D PIN 0 which is photosensor west
      ldi R18, 0b01100000   // value to be added to parameter R24 before loading into ADMUX
      add R24,R18           // add 0b0110 0000 to parameter r24
      sts ADMUX, R24        // select the +5v as reference, left adjust output bits and denote pin A2
      ldi R16, 0b11000111   // load 0b0100 0000 into register r16
      sts ADCSRA, R16       // start a conversion
      ldi R16, 0b10011111   // connect all inputs to ADC
      LW:
          lds R17, ADCSRA       // load register ADCSRA into register 17
          sbrc r17,6            // read ADSC until it reads 0 (one read is 13-14 cycles)
          jmp LW             
        
          lds R24, ADCH         // fetch result from ADCH
          subi r24, 0x02
          ldi R16, 0x58
          add R24, R16
          sts westLight, R24
          CLR R25   
          ldi r19, 0
          sts sunsetWest, r19
          lds r19, threshold
          cp r24, r19
          brsh endSensorWest
          ldi r19, 1
          sts sunsetWest, r19
      
      endSensorWest:   
          ret

          

//                  
// SWITCH FUNCTIONS 
//                  

initSwitches:
      cbi DDIRB, SWITCH1        // make pin 1 an input pin
      sbi PORTB, SWITCH1        // turn on pullup register for pin 1
      cbi DDIRB, SWITCH2        // make pin 2 an input pin
      sbi PORTB, SWITCH2        // turn on pullup register for pin 2
      call delay1ms             // give pull-up time to settle
      ret

switchEast:
      ldi   r19, 0
      sts   westSwitchPressed, r19   
      ret

switchWest:
      ldi   r19, 1
      sts   westSwitchPressed, r19   
      ret
      
 
//
// MOTOR FUNCTIONS 
//                 

stopMotor:
      ldi   R24,  0
      call  sendMotorByte
      call  delay1ms
      ret
      
enableMotor: 
      // set ports B and D to be output
      PUSH R20
      ldi r20 ,0xff
      out DDIRB, r20
      out DDIRD, r20
      POP R20
      ret
      
disableMotor:
      PUSH R20
      ldi R20, 0x00
      out DDIRB, r20
      out DDIRD, r20
      POP R20
      ret

moveEast:
      PUSH  r24
      call  enableMotor
      sbi   PORTD, M2ENABLE
      sbis  PINB, SWITCH2 
      jmp   eastPressed      
      ldi   r24, 0b11011000       // all motors 1 direction
      call  sendMotorByte
      call  delayPulse
      call  stopMotor
      jmp   endMoveEast
      eastPressed:
          call  switchEast 
      endMoveEast:      
          POP   r24
          ret
      
moveWest:
      PUSHALL
      call  enableMotor
      sbi   PORTD, M2ENABLE
      sbis  PINB, SWITCH1
      jmp   westPressed            
      ldi   r24, 0b00100111       ; then all motors opposite dir
      call  sendMotorByte
      cbi   PORTB, BOARDLED       ; turn off arduino board LED
      call  delayPulse
      call  stopMotor
      jmp   endMoveWest
      westPressed:
          call  switchWest
      endMoveWest:
          POPALL
          ret 



//                 
// DELAYS FUNCTIONS 
//                  

delay1ms:
      PUSHALL
      ldi   r22, 0x01     // 0.001 seconds
      ldi   r23, 0x00
      ldi   r24, 0
      ldi   r25, 0
      call  delay 
      POPALL
      ret
      
delayPulse:
      PUSHALL
      ldi   r22, 0x02     // 0.002      seconds
      ldi   r23, 0x00
      ldi   r24, 0
      ldi   r25, 0
      call  delay
      POPALL
      ret

delayLED:
      PUSHALL
      ldi   r22, 0xE8     // 1 second
      ldi   r23, 0x03
      ldi   r24, 0
      ldi   r25, 0
      call  delay
      POPALL
      ret

delayLong:  
      PUSHALL
      ldi   r22, 0xB8     // 3 seconds
      ldi   r23, 0x0B
      ldi   r24, 0
      ldi   r25, 0
      call  delay
      POPALL
      ret



//                         
// MOTOR SUPPORT FUNCTIONS 
//                         

controlLoop:       
      sbi   PORTD, M2ENABLE     
      sbic  PINB, SWITCH2
      jmp   notPressed2
      ldi   r24,  0
      call  sendMotorByte
      call  delay1ms
      jmp controlLoop
notPressed2:
      ldi   r24, 0b00010000       // all motors 1 direction      
      call  sendMotorByte
      call  delay1ms
      jmp controlLoop
      ret


//
// Send one byte to motor
//
sendMotorByte:
      PUSH  r15
      PUSH  r16
      mov   r15, r24
      call  latchReset
      ldi   r16, 8
      smbloop:
          lsl   r15
          brcs  smbone
          call  sendZeroBit   
          rjmp  smbdone
      smbone:
          call  sendOneBit
      smbdone:
          dec   r16
          brne  smbloop
          call  latchData
          call  latchReset
          POP   r16
          POP   r15
          ret

// latch should be zero in order to send the control 
// pattern to shift register    
latchReset: 
      cbi   PORTB,MOTLATCH
      call  delay1ms
      ret


// latch now should be enabled (one) in order to release 
// the control pattern to the motor driver chips 
latchData:
      sbi   PORTB,MOTLATCH
      call  delay1ms
      // make sure PWM outputs are on
      sbi   PORTB, M1ENABLE
      sbi   PORTD, M2ENABLE
      sbi   PORTD, M3ENABLE
      sbi   PORTD, M4ENABLE
      ret

// 0 bit transmission
sendZeroBit:         
      call latchReset         // reset the latch (MOTLATCH)              
      cbi   PORTB, MOTDATA    // based on the bits in the motor byte (MOTDATA), send a "1".
               
      sbi   PORTD, MOTCLOCK         
      call delay1ms              
      cbi   PORTD, MOTCLOCK                     
      cbi   PORTB, MOTDATA                       
      call delay1ms             
      ret

// 1 bit transmission
sendOneBit:
      call latchReset
      sbi   PORTB, MOTDATA
      
      sbi   PORTD, MOTCLOCK
      call delay1ms
      cbi   PORTD, MOTCLOCK
      cbi   PORTB, MOTDATA
      call delay1ms     
      ret




//                         
//    fill function        
//                         
fill: 
      PUSHALL
      IN  r20, SREG
      PUSH r20
      
      ldi r26,  lo8(values)  // activate array values into X
      ldi r27,  hi8(values)
      lds r20, index   
      call sensorEast      // take a reading from sensor East
      call sensorWest      // take a reading from sensor West
      add r26, r20         // set X to point to the 'index' element of array
      lds r22, westLight
      st  X, r22
      inc r20           
      sts index, r20
      ldi r19,  25
      cp  r20,  r19
      brlo endFill         
      ldi r19, 0            
      mov r20, r19          
      sts index, r20        

      endFill: 
          POP r20
          out SREG, r20
          POPALL
          ret


