 #
 # Antonio Maldonado
 # CS273 Lab 3 
 # August 30, 2017
 #
 
 .data
    .comm gender,1
    .global gender
    .comm age,1
    .global age
    .comm fat,1
    .global fat
 
 .text

       .global lightup
       
lightup:
       
      ldi  r25, 0b00110001

      out  0x04, r25

      lds  r18, gender
      lds  r19, age
      lds  r20, fat

      CPI  r18, 01
      BREQ female

      CPI  r18, 02
      jmp  male

female:
      CPI  r19, 20
      BRLO jexit1
      CPI  r19, 40
      BRLO young_female
      CPI  r19, 60
      BRLO mid_female
      CPI  r19, 80
      BRLO old_female
      jmp exit1

young_female:
      CPI r20, 21
      BRLO jyellow
      CPI r20, 33
      BRLO jgreen
      CPI r20, 39
      BRLO jred
      jmp all_leds

mid_female:
      CPI r20, 23
      BRLO yellow_led
      CPI r20, 34
      BRLO jgreen
      CPI r20, 40
      BRLO jred
      jmp all_leds

old_female:
      CPI r20, 24
      BRLO yellow_led
      CPI r20, 36
      BRLO jgreen
      CPI r20, 42
      BRLO jred
      jmp all_leds

jexit1:
      jmp exit1
jyellow:
      jmp jyellow_turnon
jgreen:
      jmp green_led
jred:
      jmp red_led

male:
      CPI  r19, 20
      BRLO j2exit1
      CPI  r19, 40
      BRLO young_male
      CPI  r19, 60
      BRLO mid_male
      CPI  r19, 80
      BRLO old_male
      jmp exit1

young_male:
      CPI r20, 8
      BRLO yellow_led
      CPI r20, 20
      BRLO green_led
      CPI r20, 25
      BRLO jred
      jmp all_leds

mid_male:
      CPI r20, 11
      BRLO yellow_led
      CPI r20, 22
      BRLO green_led
      CPI r20, 28
      BRLO jred
      jmp all_leds

old_male:
      CPI r20, 13
      BRLO yellow_led
      CPI r20, 25
      BRLO green_led
      CPI r20, 30
      BRLO jred
      jmp jall_turnon

j2exit1:
      jmp exit1
jyellow_turnon:
      jmp yellow_led
jall_turnon:
      jmp jall_turnon1
      
yellow_led:
      ldi    r16, 50
all:  ldi    r21, 0b00100000
      out    0x05, r21
      ldi    r18, 0xff
dl1:  ldi    r19, 0xff
dl2:  nop
      nop
      nop
      nop
      dec    r19
      brne   dl2
      dec    r18
      brne   dl1
      ldi    r17, 0x00
      out    0x05, r17
      ldi    r18, 0xff
dl3:  ldi    r19, 0xff
dl4:  nop
      nop
      nop
      nop
      dec    r19
      brne   dl4
      dec    r18
      brne   dl3
      dec    r16
      brne   all
      ret  


jgreen_turnon:
      jmp green_led

green_led:
      ldi    r16, 50
all1: ldi    r22, 0b00010000
      out    0x05, r22
      ldi    r18, 0xff
dl5:  ldi    r19, 0xff
dl6:  nop
      nop
      nop
      nop
      dec    r19
      brne   dl6
      dec    r18
      brne   dl5
      ldi    r17, 0x00
      out    0x05, r17
      ldi    r18, 0xff
dl7:  ldi    r19, 0xff
dl8:  nop
      nop
      nop
      nop
      dec    r19
      brne   dl8
      dec    r18
      brne   dl7
      dec    r16
      brne   all1
      ret


jall_turnon1:
      jmp all_leds

jred_turnon:
      jmp red_led

red_led:
      ldi    r16, 50
all2: ldi    r23, 0b00000001
      out    0x05, r23
      ldi    r18, 0xff
dl9:  ldi    r19, 0xff
dl10: nop
      nop
      nop
      nop
      dec    r19
      brne   dl10
      dec    r18
      brne   dl9
      ldi    r17, 0x00
      out    0x05, r17
      ldi    r18, 0xff
dl11: ldi    r19, 0xff
dl12: nop
      nop
      nop
      nop
      dec    r19
      brne   dl12
      dec    r18
      brne   dl11
      dec    r16
      brne   all2
      ret
      
all_leds:
       ldi r25, 0b00110001
       out 0x05, r25
       ret

exit1:
      ret
