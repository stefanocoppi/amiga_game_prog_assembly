;****************************************************************
; Font rendering
;
; (c) 2024 Stefano Coppi
;****************************************************************

                  include    "playfield.i"

                  xref       draw_buffer

                  xdef       draw_string
                  xdef       num2string

;****************************************************************
; CONSTANTS
;****************************************************************
FONT_SS_ROW_SIZE equ 10


;****************************************************************
; GRAPHICS DATA in chip ram
;****************************************************************
                  SECTION    graphics_data,DATA_C
numeric_font_gfx  incbin     "gfx/numeric_font.raw"


;****************************************************************
; SUBROUTINES
;****************************************************************
                  SECTION    code_section,CODE


;****************************************************************
; Draws a character, using a given font.
;
; parameters:
; d0.b - character ascii code
; a1   - destination bitplane address
;
; The font must be 8x8 px, 1 bpp
;****************************************************************
draw_char:
                  movem.l    d0-a6,-(sp) 
    
                  lea        numeric_font_gfx,a0       ; font address

    ; since the font starts from '0', subtracts the ascii code of '0',
    ; in order to have an index starting from zero
                  sub.b      #48,d0
    ; clears the high byte of d0, unused
                  and.w      #$00FF,d0
    ; calculates the address of the character within the font spritesheet
                  add.w      d0,a0
    ; copies the character data to the destination bitplane
                  moveq      #8-1,d2
.loop:
                  move.b     (a0),(a1)                 ; copies a row of 8 px from font to bitplane
                  add.l      #PF2_ROW_SIZE,a1          ; go to the next row of the bitplane
                  add.l      #FONT_SS_ROW_SIZE,a0      ; go to next row in the font spritesheet
                  dbra       d2,.loop
    
                  movem.l    (sp)+,d0-a6
                  rts


;***************************************************************************
; Draws a string using a given font.
;
; parameters:
; a2 - address of the string, zero terminated.
; d3.w,d4.w - x, y coordinates where to draw the string
;***************************************************************************
draw_string:
                  movem.l    d0-a6,-(sp)
    
    ; calculates the destination address on the bitplane
                  move.l     draw_buffer,a1            ; playfield where to draw
                  mulu.w     #PF2_ROW_SIZE,d4          ; offset_y = y * PF2_ROW_SIZE
                  add.l      d4,a1                     ; adds offset_y to bitplane address
                  lsr.w      #3,d3                     ; offset_x = x/8
                  and.l      #$0000FFFF,d3             ; clears the high word of d2
                  add.l      d3,a1                     ; adds offset_x to bitplane address
    
    ; for each character of the string:
    ;     drawChar
.loop:
                  move.b     (a2)+,d0                  ; current string character
                  tst.b      d0                        ; if current character is zero
                  beq        .return                   ; returns because the string is finished
                  bsr        draw_char                 ; else draws the character
                  add.l      #1,a1                     ; moves 8 pixel to the right
                  bra        .loop                     ; repeats the loop

.return:
                  movem.l    (sp)+,d0-a6
                  rts


;***************************************************************************
; Converts a 16bit number into a string.
;
; parameters:
; d0.w - 16 bit number
; a0   - address of the output string
;***************************************************************************
num2string:
                  movem.l    d0-a6,-(sp)

                  moveq      #4,d2                     ; number of iterations
                  move.w     #10000,d1
.loop:
                  and.l      #$0000FFFF,d0             ; clears high word of d0 because DIVU destination operand is always long
                  divu       d1,d0                     ; d0 = d0 / d1
                  add.b      #'0',d0                   ; the quotient is the digit, but must be converted into ascii code
                  move.b     d0,(a0)+                  ; copies the digit to the destination string
                  divu       #10,d1                    ; d1 = d1 / 10
                  swap       d0                        ; moves the remainder into the lower word of d0
                  dbra       d2,.loop
                  move.b     #0,(a0)                   ; adds string terminator

                  movem.l    (sp)+,d0-a6
                  rts
                          