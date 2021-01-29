     
#
# Constants
#
      ; portB setup
      .set PORTB,0x05
      .set DDIRB,0x04
      .set MOTDATA,0
      .set MOTLATCH,4
      .set M1ENABLE,3
      .set BOARDLED, 5
      
      ; portD setup
      .set PORTD,0x0B
      .set DDIRD,0x0A
      .set MOTCLOCK,4
      .set M2ENABLE,3
      .set M4ENABLE,6
      .set M3ENABLE,5

      .set PINB, 0x03
      .set SWITCH2, 2
      
#
# External symbols
#
    .extern delay

#
# Global data (none)
#
#      .data

#
# Program code
#            
      .text
      .global control
     
control: 
      ; set ports B and D to be output
      ldi r20 ,0xff
      out DDIRB, r20
      out DDIRD, r20

      ;
      ; TODO: change this "mainLoop" to be the code for lab 8
      ;

      ; argument to sendMotorByte (r24) holds the 8-bits 
      ; to control 4 bidirectional motors: 
      ; (bits 2+3  for motor1, bits 0+6  for motor4, 
      ;  bits 1+4  for motor2, bits 5+7  for motor3)
mainLoop:        
      ldi   r24, 0b11011000   ; all motors 1 direction
      call  sendMotorByte      ; turn on arduino board LED
      call  delayLong
      ldi   r24, 0b00100111   ; then all motors opposite dir
      call  sendMotorByte      ; turn off arduino board LED
      call  delayLong
      rjmp  mainLoop
      ret

#
# Delays for 1 and 255 milliseconds
#

delay1:
      ldi   r22, 0x01
      ldi   r23, 0x00
      ldi   r24, 0
      ldi   r25, 0
      call  delay
      ret
      
delaySec:
      ldi   r22, 0xE8
      ldi   r23, 0x03
      ldi   r24, 0
      ldi   r25, 0
      call  delay
      ret
      
delayLong:     
      ldi   r22, 0xe8
      ldi   r23, 0x13
      ldi   r24, 0
      ldi   r25, 0
      call  delay     
      ret

#  1 bit transmission
sendOneBit:
      sbi   PORTB, MOTDATA
      call  delay1
      sbi   PORTD, MOTCLOCK
      call  delay1
      cbi   PORTD, MOTCLOCK
      call  delay1
      ret

# 0 bit transmission
sendZeroBit:
      cbi   PORTB, MOTDATA
      call  delay1
      sbi   PORTD, MOTCLOCK
      call  delay1
      cbi   PORTD, MOTCLOCK
      call  delay1
      ret

#
# latch now should be enabled (one) in order to release 
# the control pattern to the motor driver chips 
#
latchData:
      sbi   PORTB,MOTLATCH
      call  delay1
      ; make sure PWM outputs are on
      sbi   PORTB, M1ENABLE
      sbi   PORTD, M2ENABLE
      sbi   PORTD, M3ENABLE
      sbi   PORTD, M4ENABLE
      ret

# latch should be zero in order to send the control 
# pattern to shift register    
latchReset: 
      cbi   PORTB,MOTLATCH
      call  delay1
      ret

sendMotorByte:
      push  r15
      push  r16
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
      pop   r16
      pop   r15
      ret

      .global runMotors
runMotors:
      ldi r20 ,0xff
      out DDIRB, r20
      out DDIRD, r20
       
      ldi   r24, 0b11011000   ; all motors 1 direction
      call  sendMotorByte      ; turn on arduino board LED
      call  delaySec
      call  delaySec
      call  delaySec
      ldi   r24, 0b00000000
      call  sendMotorByte
      call  delaySec
      call  delaySec
      ldi   r24, 0b00100111   ; then all motors opposite dir
      call  sendMotorByte      ; turn off arduino board LED
      call  delaySec
      call  delaySec
      call  delaySec
      ldi   r24, 0b00000000
      call  sendMotorByte
      ret

      .global controlMotor
controlMotor:
      cbi   DDIRB, SWITCH2
      sbi   PORTB, SWITCH2
      call  delay1

Loop:
      sbic  PINB, SWITCH2
      rjmp  notpressed
      ldi   r24, 0b11011000
      call  sendMotorByte
      rjmp  Loop
notpressed:
      ldi   r24, 0b00000000
      call  sendMotorByte
      rjmp  Loop
