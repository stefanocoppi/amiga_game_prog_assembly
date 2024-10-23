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

CONSTANT1 equ 100                            ; constant declaration

; declares a data structure 
             rsreset
ship.x       rs.w       1
ship.y       rs.w       1
ship.length  rs.b       0


;*****************************************************************************************************************
; MAIN PROGRAM
;*****************************************************************************************************************
main:
             nop
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
             move.w     #20,d0               ; d0 = 20
             asl.w      #2,d0                ; shifts d0 2 bits to the left => d0 = d0 * 2^2 = d0 * 4 = 80

; right shift
             move.w     #20,d0               ; d0 = 20
             asr.w      #1,d0                ; shifts d0 1 bit to the right => d0 = d0 / 2 = 10

; logical and
             move.w     #%10011100,d0        ; d0 = 156
             and.w      #%00001111,d0        ; d0 = 1100 = $c

; logical or
             move.w     #%11110000,d0        ; d0 = 240 = $f0
             or.w       #%00001111,d0        ; d0 = %11111111 = $ff

; logical xor
             move.w     #%00001010,d0        ; d0 = %00001010 = $a
             eor.w      #%00001111,d0        ; d0 = %00000101 = $5

; logical not
             move.w     #%00001111,d0        ; d0 = $000f
             not.w      d0                   ; d0 = %1111111111110000 = $fff0

; test if zero
             move.w     #0,d0
             tst.w      d0                   ; SR has Z=1
             move.w     #1,d0
             tst.w      d0                   ; SR has Z=0

; bit test
             move.w     #%00000000,d0
             btst.l     #2,d0                ; SR has Z = 1 because bit 2 is zero

; compare
             move.w     #123,d0
             cmp.w      #100,d0
             move.w     #90,d0
             cmp.w      #100,d0

; conditional branches
             move.w     #123,d0
             cmp.w      #100,d0              ; d0 >= 100?
             bge        .greater_or_equal    ; if d0 >= 100 jumps to .greater_or_equal
.else:
             move.w     d0,d3                ; else executes this instruction
             bra        .continue
.greater_or_equal:
             move.w     d0,d1
.continue:
             move.w     #1,d0

             move.w     #123,d0
             cmp.w      #100,d0              ; d0 <= 100?
             ble        .less_or_equal       ; if d0 <= 100 jumps to .less_or_equal
.else2:
             move.w     d0,d3                ; else executes this instruction
             bra        .continue2
.less_or_equal:
             move.w     d0,d1
.continue2:
             move.w     #1,d0

             move.w     #100,d0
             cmp.w      #100,d0              ; d0 = 100?
             beq        .equal               ; if d0 = 100 jumps to .equal
.else3:
             move.w     d0,d3                ; else executes this instruction
             bra        .continue3
.equal:
             move.w     d0,d1
.continue3:
             move.w     #1,d0

; cycle with a fixed number of iterations
             moveq      #10-1,d7             ; number of iterations - 1 in d7
.loop        move.b     (a0)+,(a1)+          ; copies a byte from the address contained into a0 to the address contained in a1
             dbra       d7,.loop             ; repeats the loop until d7 <> 0

; example of while cycle

.while_loop:
             cmp.w      #5,d0
             bgt        .exit                ; if d0 > 5 exits the loop
             add.w      #1,d0                ; d0 = d0 + 1
             bra        .while_loop          ; jumps to .while_loop, repeating the loop
.exit        nop

; call to subroutine
             bsr        subroutine1          ; uses a relative addressing of subroutine1
             jsr        subroutine1          ; uses absolute addressing of subroutine1


             rts

;*****************************************************************************************************************
; SUBROUTINES
;*****************************************************************************************************************

subroutine1:
             movem      d0-a6,-(sp)          ; saves registers from d0 to a6 value into stack

             nop                             ; instructions here

             movem      (sp)+,d0-a6          ; restores registers value from stack
             rts                             ; returns to the instruction after the call



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