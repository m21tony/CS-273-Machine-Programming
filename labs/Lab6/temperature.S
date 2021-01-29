# CS 273
# Antonio Maldonado
# Program Name: Lab6/Temperature.s
# Date: October 06, 2017

# I2C interface is wired to Arduino PORTC bits
# 4 and 5, with 4 being data and 5 being clock,
# so these symbols give us the values needed
#
      .set PORTC,0x08
      .set DDIRC,0x07
      .set SDA,4
      .set PINC, 0x06
      .set SCL,5
      .equ BYTE, 8


# 
# Read a byte from the I2C bus (assumes all initialization has been done, 
# and that the start bit and address have been sent; this only reads one 
# byte (and does the ACK), caller must complete the communication, reading   
# more bytes, sending a stop bit, etc.) 
# - leaves data byte in register r24; does not corrupt any other registers 
#       
  
  .data
  
  .comm tempV1, 1
  .global tempV1
  .comm tempV2, 1
  .global tempV2
  .extern delayMicroseconds

  .text
  .global readI2CByte
  .global setupTherm
  .global readTherm
setupTherm:
  sbi   DDIRC,SDA
  sbi   DDIRC,SCL
  call  clockDelay          ; wait to make sure PORTC ready
  call  startBit            ; send start bit
  call  writeTemp           ; send Digither address
  call  sendControl1        ; send control params
  call  sendRes             ; configure for full 12 bits of resolution
  call  stopBit             ; send stop bit
  call clockDelay
  call  startBit            ; send start bit
  call  writeTemp           ; send Digither address
  call  sendControl0        ; send control params
  call  stopBit             ; send stop bit
  ret


#
# I2C startbit: a high-to-low transition on SDA while clock is high
#
startBit:
      sbi   PORTC,SDA        ; set data bit high
      sbi   PORTC,SCL        ; set clock high
      call  clockDelay       ; leave clock high long enough
      cbi   PORTC,SDA        ; set data bit low (this causes the transition)
      call  clockDelay       ; keep clock high for a while
      cbi   PORTC,SCL        ; finally bring clock low
      cbi   PORTC,SDA        ; bring data line low
      call  clockDelay       ; leave clock low for long enough
      ret

#
# I2C stopit: a low-to-high transition on SDA while clock is high
#
stopBit:
      # WITH DATA LOW, SET CLOCK HIGH, THEN RAISE DATA TO HIGH
      cbi   PORTC,SDA        ; set data bit low
      sbi   PORTC,SCL        ; set clock high
      call  clockDelay       ; leave clock high long enough
      sbi   PORTC,SDA        ; set data bit high (this causes the transition)
      call  clockDelay       ; keep clock high for a while

      # THEN SET DATA AND CLOCK TO LOW BEFORE EXITING FUNCTION
      cbi   PORTC,SCL        ; finally bring clock low
      cbi   PORTC,SDA        ; bring data line low
      call  clockDelay       ; leave clock low for long enough     
      ret



#
# I2C DigiTher address transmission: must transmit the byte value 0x92
#
writeTemp:
      call  oneBit
      call  zeroBit
      call  zeroBit
      call  oneBit
      call  zeroBit
      call  zeroBit
      call  oneBit
      call  zeroBit
      call  zeroBit         ; for ack clock period
      ret

#
# I2C DigiTher address transmission: must transmit the byte value 0x93
#
readTemp:
      call  oneBit
      call  zeroBit
      call  zeroBit
      call  oneBit
      call  zeroBit
      call  zeroBit
      call  oneBit
      call  oneBit
      call  zeroBit        ; for ack clock period
      ret   

#
# Subcommand (control byte): Must transmit the byte value 0x01
#  - in binary, 00000001
#
sendControl1:
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  oneBit
      call  zeroBit        ; for ack clock period
      ret


#
# Subcommand (control byte): Must transmit the byte value 0x01
#  - in binary, 00000000
#
sendControl0:
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit        ; for ack clock period
      ret

      

#
# Subcommand (resolution byte): Must transmit the byte value 0x01
#  - in binary, 00000001
#
sendRes:
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  oneBit
      call  zeroBit        ; for ack clock period
      ret

#
# I2C 1 bit transmission: SDA high while clock is high
# 
oneBit:      
      # START LOW FOR DATA AND CLOCK 
      cbi   PORTC, SDA       ; set data bit low  
      cbi   PORTC,SCL        ; set clock low
      call  clockDelay       ; leave clock low long enough
      
      # WITH DATA HIGH, MOVE CLOCK TO HIGH
      sbi   PORTC,SDA        ; set data bit high (this causes the transition)
      sbi   PORTC, SCL       ; set clock high
      call  clockDelay       ; keep clock high for a while
      
      # MOVE CLOCK TO LOW
      cbi   PORTC, SCL       ; set clock low
      call  clockDelay       ; keep clock low for a while
      ret

#
# I2C 0 bit transmission: SDA low while clock is high
# 
zeroBit:
      # START CLOCK LOW
      cbi   PORTC,SCL        ; set clock low
      call  clockDelay       ; leave clock high long enough      
      
      # WITH DATA LOW, MOVE CLOCK TO HIGH
      cbi   PORTC,SDA        ; set data bit low
      sbi   PORTC, SCL       ; set clock high
      call  clockDelay       ; leave clock high long enough

      # MOVE CLOCK TO LOW
      cbi   PORTC, SCL       ; set clock low
      call  clockDelay       ; keep clock high for a while
      ret

readTherm:
  call  startBit            ; send start bit
  call  readTemp            ; send Digither address
  call  readI2CByte         ; getting the first reading
  sts   tempV1, r24         ; reading the integer
  call readI2CByte          ; getting the second reading
  sts   tempV2, r24         ; reading the decimal
  call  stopBit             ; send stop bit
  ret
  

readI2CByte:       
  push  r20               ; save r20 in case program is using it       
  cbi   PORTC, SDA        ; ensure output is low to switch to input       
  cbi   DDIRC, SDA        ; change SDA pin to input rather than output         
  ldi   r20, 8            ; we're going to read 8 bits       
  clr   r24               ; r24 will hold data byte, so start it at 0 

readLoop:       

  lsl   r24               ; shift the bits we have so far one place to left         
  sbi   PORTC, SCL        ; set clock high       
  call  clockDelay        ; keep high for a bit, gives time for therm to send bit       
  sbic  PINC, SDA         ; skip next instruction if input bit is 0       
  ori   r24, 0x01         ; input bit is a 1, so put a 1 into data byte          
  cbi   PORTC, SCL        ; set clock low       
  call  clockDelay        ; keep low for a bit       
  dec   r20               ; decrement our loop counter       
  brne  readLoop          ; if it is still not 0, go back to top of loop 
  
readDone:       

  sbi   DDIRC, SDA        ; change SDA pin back to output       
  cbi   PORTC, SDA        ; set data line low for ACK       
  sbi   PORTC, SCL        ; start ACK clock period       
  call  clockDelay        ; hold high       
  cbi   PORTC, SCL        ; set clock low       
  call  clockDelay        ; hold low       
  pop   r20               ; restore original r20       
  ret                     ; data byte is left in r24 

# 
# Delay for creating our clock period (50usec delay) 
# 

clockDelay:       
  push  r18       
  push  r19       
  push  r20       
  push  r22
  push r24    
  ldi   r24, 50       
  ldi   r25, 0       
  call  delayMicroseconds       
  pop r24
  pop   r22       
  pop   r20       
  pop   r19       
  pop   r18       
  ret
