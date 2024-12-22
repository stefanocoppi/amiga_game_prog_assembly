;*****************************************************************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 27 - Fixed point math
;
; (c) 2024 Stefano Coppi
;*****************************************************************************************************************

        SECTION    code_section,CODE


;*****************************************************************************************************************
; MAIN PROGRAM
;*****************************************************************************************************************
main:
        nop
        nop

    ; sum of two fixed point numbers
        move.w     #794,d0              ; 12.4*64
        move.w     #38,d1               ; 0.6*64
        add.w      d1,d0                ; result in fixed notation = 13

    ; subtraction of two fixed point numbers
        move.w     #640,d0              ; 10*64
        move.w     #13,d1               ; 0.2*64
        sub.w      d1,d0                ; result in fixed notation = 9.8
    
    ; multiplication of two fixed point numbers
        move.w     #224,d0              ; 3.5
        move.w     #134,d1              ; 2.1
        mulu       d1,d0
        divu       #64,d0               ; result = 7.33

    ; multiplication of a fixed point number by an integer
        move.w     #160,d0              ; 2.5
        move.w     #2,d1
        mulu       d1,d0                ; result = 5
    
    ; division of two fixed point numbers
        move.l     #326,d0              ; 5.1
        mulu       #64,d0               ; multiplies the dividend by 64
        move.w     #141,d1              ; 2.2
        divu       d1,d0                ; result = 2.3       

        rts


        END