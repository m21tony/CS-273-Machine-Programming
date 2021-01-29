
#
# I2C interface is wired to Arduino PORTC bits
# 4 and 5, with 4 being data and 5 being clock,
# so these symbols give us the values needed
#
      .set PORTC,0x08
      .set DDIRC,0x07
      .set SDA,4
      .set SCL,5
      .equ BYTE,8

#
# I2C addresses of the components:
#  7-segment LED: 0x70
#  Digital Thermometer: 0x92
#  EEPROM: 0xA0

#
# Global data (none)
#
#   
    .data
    .comm symbol, 1
    .global symbol
    .comm symbol1, 1
    .global symbol1
    .comm symbol2, 1
    .global symbol2
    .comm symbol3, 1
    .global symbol3
    .comm symbol4, 1
    .global symbol4

alphabet:
    .byte '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
LEDcode:
    .byte 0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110, 0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111, 0b01110111, 0b01111100, 0b00111001, 0b01011110, 0b01111001, 0b01110001, 0b00111101, 0b01110110, 0b00110000, 0b00011110, 0b01111000, 0b00111000, 0b10110111, 0b00110111, 0b00001111, 0b01110011, 0b10111111, 0b11110111, 0b11101101, 0b00110001, 0b00111110, 0b10110110, 0b10111110, 0b11110110, 0b01110010, 0b01001001
table_length:
    .byte 36
    
# external symbol (delay function)
    .extern delay

#
# Program code
#
     .text
     .global display_symbol
     .global display_symbol_1
     .global display_symbol_2
     .global display_symbol_3
     .global display_symbol_4
     .global display_symbol_5
     
display_symbol: 
      ; set pins to output mode
      sbi   DDIRC,SDA
      sbi   DDIRC,SCL
      call  delay1          ; wait to make sure PORTC ready
      call  startBit        ; send start bit
      call  sendAddress     ; send 7SEG address
      call  sendInst        ; send instruction
      call  sendControl     ; send control params
      call  show_one_symbol ;
      call  show_one_symbol ; send 4 data bytes 
      call  show_one_symbol ;   for the 4 display digits
      call  show_one_symbol ;
      call  stopBit         ; send stop bit
      call  delay1          ; wait to allow settling
      ret                   ; all done, return to main program!

display_symbol_1: 
      ; set pins to output mode
      sbi   DDIRC,SDA
      sbi   DDIRC,SCL
      call  delay1          ; wait to make sure PORTC ready
      call  startBit        ; send start bit
      call  sendAddress     ; send 7SEG address
      call  sendInst        ; send instruction
      call  sendControl     ; send control params
      call  show_symbol_1   ;
      call  show_symbol_2   ; send 4 data bytes 
      call  show_symbol_3   ;   for the 4 display digits
      call  show_symbol_4   ;
      call  stopBit         ; send stop bit
      call  delay1          ; wait to allow settling
      ret                   ; all done, return to main program!

display_symbol_2: 
      ; set pins to output mode
      sbi   DDIRC,SDA
      sbi   DDIRC,SCL
      call  delay1          ; wait to make sure PORTC ready
      call  startBit        ; send start bit
      call  sendAddress     ; send 7SEG address
      call  sendInst        ; send instruction
      call  sendControl     ; send control params
      call  show_symbol_2   ; send 4 data bytes 
      call  show_symbol_3   ;   for the 4 display digits
      call  show_symbol_4   ;
      call  show_blank      ;
      call  stopBit         ; send stop bit
      call  delay1          ; wait to allow settling
      ret                   ; all done, return to main program!

display_symbol_3: 
      ; set pins to output mode
      sbi   DDIRC,SDA
      sbi   DDIRC,SCL
      call  delay1          ; wait to make sure PORTC ready
      call  startBit        ; send start bit
      call  sendAddress     ; send 7SEG address
      call  sendInst        ; send instruction
      call  sendControl     ; send control params
      call  show_symbol_3   ; send 4 data bytes 
      call  show_symbol_4   ;   for the 4 display digits
      call  show_blank      ;
      call  show_symbol_1   ;
      call  stopBit         ; send stop bit
      call  delay1          ; wait to allow settling
      ret                   ; all done, return to main program!

display_symbol_4: 
      ; set pins to output mode
      sbi   DDIRC,SDA
      sbi   DDIRC,SCL
      call  delay1          ; wait to make sure PORTC ready
      call  startBit        ; send start bit
      call  sendAddress     ; send 7SEG address
      call  sendInst        ; send instruction
      call  sendControl     ; send control params
      call  show_symbol_4   ; send 4 data bytes 
      call  show_blank      ;
      call  show_symbol_1   ;   for the 4 display digits
      call  show_symbol_2   ;
      call  stopBit         ; send stop bit
      call  delay1          ; wait to allow settling
      ret                   ; all done, return to main program!

display_symbol_5: 
      ; set pins to output mode
      sbi   DDIRC,SDA
      sbi   DDIRC,SCL
      call  delay1          ; wait to make sure PORTC ready
      call  startBit        ; send start bit
      call  sendAddress     ; send 7SEG address
      call  sendInst        ; send instruction
      call  sendControl     ; send control params
      call  show_blank      ; send 4 data bytes 
      call  show_symbol_1   ;
      call  show_symbol_2   ;   for the 4 display digits
      call  show_symbol_3   ;
      call  stopBit         ; send stop bit
      call  delay1          ; wait to allow settling
      ret                   ; all done, return to main program!


#
# Delay for 1 millisecond (saves/restores r18-r20)
#
delay1:
      push r17
      push r18
      push r19
      push r20
      push r21
      push r22
      push r23
      push r24
      push r25
      push r26
      push r27
      push r28
      push r29
      push r30
      push r31
      ldi  r22, 0x1
      ldi  r23, 0
      ldi  r24, 0
      ldi  r25, 0
      call delay
      pop  r31
      pop  r30
      pop  r29
      pop  r28
      pop  r27
      pop  r26
      pop  r25
      pop  r24
      pop  r23
      pop  r22
      pop  r21
      pop  r20
      pop  r19
      pop  r18
      pop  r17
      ret

#
# I2C startbit: a high-to-low transition on SDA while clock is high
#
startBit:
      sbi   PORTC,SDA    ; set data bit high
      sbi   PORTC,SCL    ; set clock high
      call  delay1       ; leave clock high long enough
      cbi   PORTC,SDA    ; set data bit low (this causes the transition)
      call  delay1       ; keep clock high for a while
      cbi   PORTC,SCL    ; finally bring clock low
      cbi   PORTC,SDA    ; bring data line low
      call  delay1       ; leave clock low for long enough
      ret

#
# I2C stopit: a low-to-high transition on SDA while clock is high
#
stopBit:
      # WITH DATA LOW, SET CLOCK HIGH, THEN RAISE DATA TO HIGH
      cbi   PORTC,SDA    ; set data bit low
      sbi   PORTC,SCL    ; set clock high
      call  delay1       ; leave clock high long enough
      sbi   PORTC,SDA    ; set data bit high (this causes the transition)
      call  delay1       ; keep clock high for a while

      # THEN SET DATA AND CLOCK TO LOW BEFORE EXITING FUNCTION
      cbi   PORTC,SCL    ; finally bring clock low
      cbi   PORTC,SDA    ; bring data line low
      call  delay1       ; leave clock low for long enough
      ret

#
# I2C 1 bit transmission: SDA high while clock is high
# 
oneBit:
      # START LOW FOR DATA AND CLOCK 
      cbi   PORTC, SDA   ; set data bit low  
      cbi   PORTC,SCL    ; set clock low
      call  delay1       ; leave clock low long enough
      
      # WITH DATA HIGH, MOVE CLOCK TO HIGH
      sbi   PORTC,SDA    ; set data bit high (this causes the transition)
      sbi   PORTC, SCL   ; set clock high
      call  delay1       ; keep clock high for a while
      
      # MOVE CLOCK TO LOW
      cbi   PORTC, SCL   ; set clock low
      call  delay1       ; keep clock low for a while
      ret

#
# I2C 0 bit transmission: SDA low while clock is high
# 
zeroBit:
      # START CLOCK LOW
      cbi   PORTC,SCL    ; set clock low
      call  delay1       ; leave clock high long enough      
      
      # WITH DATA LOW, MOVE CLOCK TO HIGH
      cbi   PORTC,SDA    ; set data bit low
      sbi   PORTC, SCL   ; set clock high
      call  delay1       ; leave clock high long enough

      # MOVE CLOCK TO LOW
      cbi   PORTC, SCL   ; set clock low
      call  delay1       ; keep clock high for a while
      ret

#
# I2C LED address transmission: must transmit the byte value 0x70
#
sendAddress:
      call  zeroBit
      call  oneBit
      call  oneBit
      call  oneBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit     ; for ack clock period
      ret

#
# Instruction transmit: for us the instruction should be 0x00 
#  - all zeros means data is in order of: ctl d1 d2 d3 d4
#
sendInst:
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit     ; for ack clock period
      ret

#
# Subcommand (control byte): Must transmit the byte value 0x47
#  - in binary, 01000111
#
sendControl:
      call  zeroBit
      call  oneBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  oneBit
      call  oneBit
      call  oneBit
      call  zeroBit     ; for ack clock period
      ret

#
# Transmit a byte that will display a symbol
#  - you must figure it out!
#
show_one_symbol:
      # PUSH CONTENTS IN REGISTERS Z And Y TO STACK
      push R31
      push R30
      push R29
      push R28

      # POINT Z And Y TO beginning of TABLES alphabet And LEDcode 
      LDI R31, hi8(alphabet)  ; initialize high byte of Z
      LDI R30, lo8(alphabet)  ; initialize low byte of Z
      LDI R29, hi8(LEDcode)   ; initialize high byte of Y
      LDI R28, lo8(LEDcode)   ; initialize low byte of Y
      
      LDS R17, symbol         ; r17 = symbol
      LDS R18, table_length   ; r18 = Length of table
      LDI R19, 0              ; counter For Loop 2
      
      ;Loop to Find symbol
  L1:
      LD R20, Z+              ; r20 = Z and increment Z
      LD R21, Y+              ; r21 = Y and increment Y

      # CHECK ALPHABET
      CP R17, R20             ; compare symbol with alphabet table
      BREQ  L2                ; If symbol found, jump to Loop 2
      RJMP  L1                ; Else Continue Loop 1

  L2:
      # LOOP 8 TIMES
      ROL R21                 ; Rotate One Bit Left
      INC R19                 ; Increment counter
      BRCC ELSE               ; If Not a one, jump to ELSE
      call oneBit             ; Else call oneBit function
      CPI R19, 8            ; Compare counter with the Size of one Byte (8)
      BREQ ACK                ; If equal, Send acknowledgement Bit
      jmp L2                  ; If Not equal, Continue Loop 2
    
  ELSE:
      call zeroBit            ; Else call zeroBit function
      CPI R19, 8            ; Compare counter wth the Size of one Byte (8)
      BREQ ACK                ; If equal, Send acknowledgement Bit
      jmp L2                  ; If Not equal, Continue Loop

  ACK:
      call zeroBit            ; Send acknowledgement Bit
           
      # POP CONTENTS OFF OF THE STACK BACK INTO REGISTERS Y AND Z
      pop R28
      pop R29
      pop R30
      pop R31
      
      ret



#
# Transmit a byte that will display a symbol
#  - you must figure it out!
#
show_symbol_1:
      # PUSH CONTENTS IN REGISTERS Z And Y TO STACK
      push R31
      push R30
      push R29
      push R28

      # POINT Z And Y TO beginning of TABLES alphabet And LEDcode 
      LDI R31, hi8(alphabet)  ; initialize high byte of Z
      LDI R30, lo8(alphabet)  ; initialize low byte of Z
      LDI R29, hi8(LEDcode)   ; initialize high byte of Y
      LDI R28, lo8(LEDcode)   ; initialize low byte of Y
      
      LDS R17, symbol1        ; r17 = symbol
      LDS R18, table_length   ; r18 = Length of table
      LDI R19, 0              ; counter For Loop 21
      
      ;Loop to Find symbol
  L11:
      LD R20, Z+              ; r20 = Z and increment Z
      LD R21, Y+              ; r21 = Y and increment Y

      # CHECK ALPHABET
      CP R17, R20             ; compare symbol with alphabet table
      BREQ  L21               ; If symbol found, jump to Loop 21
      RJMP  L11               ; Else Continue Loop 11

  L21:
      # LOOP 8 TIMES
      INC R19                 ; Increment counter
      ROL R21                 ; Rotate One Bit Left
      BRCC ELSE1              ; If Not a one, jump to ELSE1
      call oneBit             ; Else call oneBit function
      CPI R19, BYTE           ; Compare counter with the Size of one Byte (8)
      BREQ ACK1               ; If equal, Send acknowledgement Bit
      jmp L21                 ; If Not equal, Continue Loop 21
    
  ELSE1:
      call zeroBit            ; Else call zeroBit function
      CPI R19, BYTE           ; Compare counter wth the Size of one Byte (8)
      BREQ ACK1               ; If equal, Send acknowledgement Bit
      jmp L21                 ; If Not equal, Continue Loop

  ACK1:
      call zeroBit            ; Send acknowledgement Bit
      
      # POP CONTENTS OFF OF THE STACK BACK INTO REGISTERS Y AND Z
      pop R28
      pop R29
      pop R30
      pop R31
      
      ret

show_symbol_2:
      # PUSH CONTENTS IN REGISTERS Z And Y TO STACK
      push R31
      push R30
      push R29
      push R28

      # POINT Z And Y TO beginning of TABLES alphabet And LEDcode 
      LDI R31, hi8(alphabet)  ; initialize high byte of Z
      LDI R30, lo8(alphabet)  ; initialize low byte of Z
      LDI R29, hi8(LEDcode)   ; initialize high byte of Y
      LDI R28, lo8(LEDcode)   ; initialize low byte of Y
      
      LDS R17, symbol2        ; r17 = symbol
      LDS R18, table_length   ; r18 = Length of table
      LDI R19, 0              ; counter For Loop 22
      
      ;Loop to Find symbol
  L12:
      LD R20, Z+              ; r20 = Z and increment Z
      LD R21, Y+              ; r21 = Y and increment Y

      # CHECK ALPHABET
      CP R17, R20             ; compare symbol with alphabet table
      BREQ  L22               ; If symbol found, jump to Loop 22
      RJMP  L12               ; Else Continue Loop 12

  L22:
      # LOOP 8 TIMES
      ROL R21                 ; Rotate One Bit Left
      INC R19                 ; Increment counter
      BRCC ELSE2              ; If Not a one, jump to ELSE2
      call oneBit             ; Else call oneBit function
      CPI R19, BYTE           ; Compare counter with the Size of one Byte (8)
      BREQ ACK2               ; If equal, Send acknowledgement Bit
      jmp L22                 ; If Not equal, Continue Loop
    
  ELSE2:
      call zeroBit            ; Else call zeroBit function
      CPI R19, BYTE           ; Compare counter wth the Size of one Byte (8)
      BREQ ACK2               ; If equal, Send acknowledgement Bit
      jmp L22                 ; If Not equal, Continue Loop

  ACK2:
      call zeroBit            ; Send acknowledgement Bit
      
      # POP CONTENTS OFF OF THE STACK BACK INTO REGISTERS Y AND Z
      pop R28
      pop R29
      pop R30
      pop R31
      
      ret

show_symbol_3:
      # PUSH CONTENTS IN REGISTERS Z And Y TO STACK
      push R31
      push R30
      push R29
      push R28

      # POINT Z And Y TO beginning of TABLES alphabet And LEDcode 
      LDI R31, hi8(alphabet)  ; initialize high byte of Z
      LDI R30, lo8(alphabet)  ; initialize low byte of Z
      LDI R29, hi8(LEDcode)   ; initialize high byte of Y
      LDI R28, lo8(LEDcode)   ; initialize low byte of Y
      
      LDS R17, symbol3        ; r17 = symbol
      LDS R18, table_length   ; r18 = Length of table
      LDI R19, 0              ; counter For Loop 23
      
      ;Loop to Find symbol
  L13:
      LD R20, Z+              ; r20 = Z and increment Z
      LD R21, Y+              ; r21 = Y and increment Y

      # CHECK ALPHABET
      CP R17, R20             ; compare symbol with alphabet table
      BREQ  L23               ; If symbol found, jump to Loop 23
      RJMP  L13               ; Else Continue Loop 13

  L23:
      # LOOP 8 TIMES
      ROL R21                 ; Rotate One Bit Left
      INC R19                 ; Increment counter
      BRCC ELSE3              ; If Not a one, jump to ELSE3
      call oneBit             ; Else call oneBit function
      CPI R19, BYTE           ; Compare counter with the Size of one Byte (8)
      BREQ ACK3               ; If equal, Send acknowledgement Bit
      jmp L23                 ; If Not equal, Continue Loop
    
  ELSE3:
      call zeroBit            ; Else call zeroBit function
      CPI R19, BYTE           ; Compare counter wth the Size of one Byte (8)
      BREQ ACK3               ; If equal, Send acknowledgement Bit
      jmp L23                 ; If Not equal, Continue Loop

  ACK3:
      call zeroBit            ; Send acknowledgement Bit
      
      # POP CONTENTS OFF OF THE STACK BACK INTO REGISTERS Y AND Z
      pop R28
      pop R29
      pop R30
      pop R31
      
      ret

show_symbol_4:
      # PUSH CONTENTS IN REGISTERS Z And Y TO STACK
      push R31
      push R30
      push R29
      push R28

      # POINT Z And Y TO beginning of TABLES alphabet And LEDcode 
      LDI R31, hi8(alphabet)  ; initialize high byte of Z
      LDI R30, lo8(alphabet)  ; initialize low byte of Z
      LDI R29, hi8(LEDcode)   ; initialize high byte of Y
      LDI R28, lo8(LEDcode)   ; initialize low byte of Y
      
      LDS R17, symbol4        ; r17 = symbol
      LDS R18, table_length   ; r18 = Length of table
      LDI R19, 0              ; counter For Loop 24
      
      ;Loop to Find symbol
  L14:
      LD R20, Z+              ; r20 = Z and increment Z
      LD R21, Y+              ; r21 = Y and increment Y

      # CHECK ALPHABET
      CP R17, R20             ; compare symbol with alphabet table
      BREQ  L24               ; If symbol found, jump to Loop 24
      RJMP  L14               ; Else Continue Loop 14

  L24:
      # LOOP 8 TIMES
      ROL R21                 ; Rotate One Bit Left
      INC R19                 ; Increment counter
      BRCC ELSE4              ; If Not a one, jump to ELSE4
      call oneBit             ; Else call oneBit function
      CPI R19, BYTE           ; Compare counter with the Size of one Byte (8)
      BREQ ACK4               ; If equal, Send acknowledgement Bit
      jmp L24                 ; If Not equal, Continue Loop
    
  ELSE4:
      call zeroBit            ; Else call zeroBit function
      CPI R19, BYTE           ; Compare counter wth the Size of one Byte (8)
      BREQ ACK4               ; If equal, Send acknowledgement Bit
      jmp L24                 ; If Not equal, Continue Loop

  ACK4:
      call zeroBit            ; Send acknowledgement Bit
      
      # POP CONTENTS OFF OF THE STACK BACK INTO REGISTERS Y AND Z
      pop R28
      pop R29
      pop R30
      pop R31
      
      ret
      
show_blank:
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit
      call  zeroBit     ; for ack clock period
      ret

