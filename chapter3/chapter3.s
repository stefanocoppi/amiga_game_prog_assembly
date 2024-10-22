;*****************************************************************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 3 - Motorola 68K Assembly Short Course
;
; (c) 2024 Stefano Coppi
;*****************************************************************************************************************

             SECTION    code_section,CODE

;*****************************************************************************************************************
; CONSTANTS
;*****************************************************************************************************************

; declares a data structure 
             rsreset
ship.x       rs.w       1
ship.y       rs.w       1
ship.length  rs.b       0


;*****************************************************************************************************************
; MAIN PROGRAM
;*****************************************************************************************************************
main         nop
             nop
; move, immediate addressing
             move.b     #$ff,d0              ; copy byte $ff into least significant byte (lsb) of register d0
             clr.b      d0                   ; sets lsb of d0 to zero
             move.w     #$1234,d0            ; copies word $1234 into least significant word (lsw) of d0
             clr.w      d0                   ; clears lsw of d0
             move.l     #$12345678,d0        ; copies a long word into d0
             clr.l      d0                   ; clears all 32 bits of d0

; move, absolute addressing
             move.w     #$3456,value1        ; assigns value $3456 to the value1 variable

; indirect addressing
             lea        value1,a0            ; loads address of value1 into a0
             move.w     #$1234,(a0)          ; assigns value $1234 to the word at the address contained into a0 (value1)

; indirect addressing with displacement
             lea        ship,a0              ; base address of ship structure instance in a0
             move.w     #100,ship.x(a0)      ; assigns value 100 to ship.x field
             move.w     #192,ship.y(a0)      ; assigns value 192 to ship.y field

; indirect addressing with post increment
             lea        value1,a0            ; loads address of value1 into a0
             move.w     #$1234,(a0)+         ; assigns value $1234 to the word at the address contained into a0 and then increments a0 of one word (2 bytes)

; logical-arithmetic instructions

; adds two variables, putting the result in a third variable
             move.w     #10,value1           ; value1 = 10
             move.w     #13,value2           ; value1 = 13
             move.w     value2,d0            ; d0 = value2
             add.w      value1,d0            ; d0 = value1 + value2
             move.w     d0,result            ; result = d0

; subtracts a constant value from a variable
             move.w     #100,value1          ; value1 = 100
             move.w     value1,d0            ; d0 = value1
             sub.w      #50,d0               ; d0 = d0 - 50 = value1 - 50
             move.w     d0,result            ; result = d0

; multiplies a register by a constant value
             move.w     #30,d0               ; d0 = 30
             mulu       #3,d0                ; d0 = d0 * 3 = 30 * 3
             move.w     d0,result            ; result = d0

; integer division
             move.w     #100,d0
             ext.l      d0                   ; extends d0 value to a long word, because divu destination must be a long
             divu       #30,d0               ; d0 = d0 / 30  lower word = quotient, higher word = remainder
             move.w     d0,value1            ; value1 = quotient of 100/30 = 3
             swap       d0                   ; swaps the lower and upper words of d0
             move.w     d0,value2            ; value2 = remainder of 100/30 = 10

; left shift

; right shift

; logical and

; logical or

; logical xor

; test if zero

; bit test

; compare

; conditional branches

; cycle with a fixed number of iterations

; exmaple of while cycle

; call to subroutine

; return from subroutine

; save registers value into stack

; restore registers value from stack

            rts

;*****************************************************************************************************************
; SUBROUTINES
;*****************************************************************************************************************




;*****************************************************************************************************************
; VARIABLES
;*****************************************************************************************************************
value1       dc.w       0                    ; declares a variable, with a length of one word
value2       dc.w       0                    ; declares a variable, with a length of one word
result       dc.w       0                    ; declares a variable, with a length of one word

; instance of ship structure
ship         dc.w       0                    ; ship.x
             dc.w       0                    ; ship.y

             END