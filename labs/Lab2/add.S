#
# Antonio Maldonado
# CS 273 - 08/23/17
#

#
# Global data (x1, x2, and x3)
#
    .data
    .comm x1,1
    .global x1
    .comm x2,1
    .global x2
    .comm x3,1
    .global x3

#
# Program code (addition function)
#
    .text
    .global addition
addition:
    lds  r18, x1
    lds  r19, x2
    lds  r20, x3
    ldi  r21, -1
    ldi  r22, 1
    ldi  r23, -3
    add  r18, r22
    add  r18, r18
    add  r19, r21
    add  r18, r19
    add  r20, r23
    add  r18, r20
    sts  x3, r18

#
# Turns on LED
#
    ldi R18, 0b00100000
    out 0x04, R18

#
# Turns off LED
#
    ldi R18, 0b00000000
    out 0x05, R18
    
    
    ret
    
