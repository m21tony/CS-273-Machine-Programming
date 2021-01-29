.data

.text

  .global GoAggies
  .extern delay

GoAggies:
   #letter g
   call dash
   call dash
   call dot

   #letter o
   call dash
   call dash
   call dash

   #letter a
   call dot
   call dash

   #g
   call dash 
   call dash
   call dot

   #g
   call dash
   call dash
   call dot

   #letter i
   call dot
   call dot

   #letter e
   call dot

   #letter s
   call dot
   call dot
   call dot

dash:
   call on
   call dashBlink
   call off
   call dashBlink
   ret

dot:
   call on
   call dotBlink
   call off
   call dotBlink
   ret

on:
   ldi r17, 0b00100000
   out 0x04, r17
   out 0x05, r17
   ret

off:
   ldi r17, 0b00100000
   out 0x04, r17
   ldi r16, 0b00000000
   out 0x05, r16
   ret

dashBlink:
   push r22
   push r23
   push r24
   push r25

   ldi r22, 0xff
   ldi r23, 0x05
   ldi r24, 0x00
   ldi r25, 0x00
   call delay

   pop r22
   pop r23
   pop r24
   pop r25
   ret
   
dotBlink:
   push r22
   push r23
   push r24
   push r25

   ldi r22, 0xa5
   ldi r23, 0x00
   ldi r24, 0x00
   ldi r25, 0x00
   call delay

   pop r22
   pop r23
   pop r24
   pop r25
   ret
     
