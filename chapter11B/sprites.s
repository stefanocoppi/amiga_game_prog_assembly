;************************************************************************
; Sprites management.
;
; (c) 2024 Stefano Coppi
;************************************************************************

             incdir     "include/"
             include    "hw.i"
             include    "sprites.i"

;****************************************************************
; PUBLIC SYMBOLS
;****************************************************************
             xdef       init_sprite_pointers
             xdef       set_sprite_position
             xdef       ship_sprite
             xdef       sprite_x
             xdef       sprite_y
             xdef       move_sprite_with_joystick
             xdef       check_collisions


;****************************************************************
; EXTERNAL REFERENCES
;****************************************************************
             xref       sprite_pointers
             xref       bgnd_palette


;************************************************************************
; Graphics data
;************************************************************************
; segment loaded in CHIP RAM
             SECTION    graphics_data,DATA_C

             CNOP       0,8                               ; 64-bit alignment
ship_sprite  incbin     "gfx/ship.raw"



;************************************************************************
; VARIABLES
;************************************************************************
             SECTION    code_section,CODE
sprite_x     dc.w       16
sprite_y     dc.w       16


;************************************************************************
; SUBROUTINES
;************************************************************************
              

;****************************************************************
; Initializes sprite pointers
;****************************************************************
init_sprite_pointers:
             movem.l    d0-a6,-(sp)

             lea        sprite_pointers,a1
             move.l     #ship_sprite,d0
             move.w     d0,6(a1)                          ; low word
             swap       d0
             move.w     d0,2(a1)                          ; high word

             add.l      #8,a1                             ; next sprite pointer
             move.l     #ship_sprite+SPRITE_SIZE,d0       ; next sprite
             move.w     d0,6(a1)                          ; low word
             swap       d0
             move.w     d0,2(a1)                          ; high word

             bset       #7,ship_sprite+SPRITE_SIZE+9      ; sets sprite1 attached bit

             add.l      #8,a1                             ; next sprite pointer
             move.l     #ship_sprite+SPRITE_SIZE*2,d0     ; next sprite
             move.w     d0,6(a1)                          ; low word
             swap       d0
             move.w     d0,2(a1)                          ; high word

             add.l      #8,a1                             ; next sprite pointer
             move.l     #ship_sprite+SPRITE_SIZE*3,d0     ; next sprite
             move.w     d0,6(a1)                          ; low word
             swap       d0
             move.w     d0,2(a1)                          ; high word

             bset       #7,ship_sprite+SPRITE_SIZE*3+9    ; sets sprite3 attached bit

             movem.l    (sp)+,d0-a6
             rts


;****************************************************************
; Sets the position of a sprite
;
; parameters:
; a1 - sprite address
; d0.w - y position (0-255)
; d1.w - x position (0-319)
; d2.w - sprite height
;****************************************************************
set_sprite_position:
             movem.l    d0-a6,-(sp)

             add.w      #$2c,d0                           ; adds offset of screen beginning
             move.b     d0,(a1)                           ; copies y into sprite VSTART byte
             btst.l     #8,d0                             ; bit 8 of y position is set?
             beq        .dontset_bit8
             bset.b     #2,9(a1)                          ; sets bit 8 of VSTART
             bra        .vstop
.dontset_bit8:
             bclr.b     #2,9(a1)                          ; clears bit 8 of VSTART
.vstop:
             add.w      d2,d0                             ; adds height to y position to get VSTOP
             move.b     d0,8(a1)                          ; copies the value into sprite VSTOP byte
             btst.l     #8,d0                             ; bit 8 of VSTOP is set?
             beq        .dontset_VSTOP_bit8
             bset.b     #1,9(a1)                          ; sets bit 8 of VSTOP
             bra        .set_hpos
.dontset_VSTOP_bit8:
             bclr.b     #1,9(a1)                          ; clears bit 8 of VSTOP
.set_hpos:
             add.w      #128,d1                           ; adds horizontal offset to x
             btst.l     #0,d1 
             beq        .HSTART_lsb_zero
             bset.b     #0,9(a1)                          ; sets bit 0 of HSTART
             bra        .set_HSTART
.HSTART_lsb_zero:
             bclr.b     #0,9(a1)                          ; clears bit 0 of HSTART
.set_HSTART:
             lsr.w      #1,d1                             ; shifts 1 position to right to get the 8 most significant bits of x position
             move.b     d1,1(a1)                          ; sets HSTART value
             movem.l    (sp)+,d0-a6
             rts


;****************************************************************
; Moves the sprite with the joystick
;****************************************************************
move_sprite_with_joystick:
             movem.l    d0-a6,-(sp)

             move.w     JOY1DAT(a5),d0
             btst.l     #1,d0                             ; joy right?
             bne        .set_right
             btst.l     #9,d0                             ; joy left?
             bne        .set_left
             bra        .check_up
.set_right:
             add.w      #SPRITE_SPEED,sprite_x
             bra        .check_up
.set_left:
             sub.w      #SPRITE_SPEED,sprite_x
.check_up:
             move.w     d0,d1
             lsr.w      #1,d1
             eor.w      d1,d0
             btst.l     #8,d0                             ; joy up?
             bne        .set_up
             btst.l     #0,d0                             ; joy down?
             bne        .set_down
             bra        .move_sprite
.set_up:
             sub.w      #SPRITE_SPEED,sprite_y
             bra        .move_sprite
.set_down:
             add.w      #SPRITE_SPEED,sprite_y
.move_sprite:
             lea        ship_sprite,a1
             move.w     sprite_y,d0                       ; y position
             move.w     sprite_x,d1                       ; x position
             move.w     #SPRITE_HEIGHT,d2                 ; sprite height
             bsr        set_sprite_position

             lea        ship_sprite+SPRITE_SIZE,a1
             bsr        set_sprite_position

             lea        ship_sprite+SPRITE_SIZE*2,a1
             add.w      #SPRITE_WIDTH,d1
             bsr        set_sprite_position

             lea        ship_sprite+SPRITE_SIZE*3,a1
             bsr        set_sprite_position

             movem.l    (sp)+,d0-a6
             rts


;****************************************************************
; Checks the collisions between sprite and playfield.
; If a collision is detected, change the border color to red.
;****************************************************************
check_collisions:
             movem.l    d0-a6,-(sp)

             move.w     CLXDAT(a5),d0
             btst.l     #1,d0                             ; bit 1 checks collisions between playfield and sprites 0-1
             bne        .collision
             btst.l     #2,d0                             ; bit 2 checks collisions between playfield and sprites 2-3
             bne        .collision
             move.w     #$0444,bgnd_palette+6
             bra        .return
.collision:
             move.w     #$0f00,bgnd_palette+6
.return:
             movem.l    (sp)+,d0-a6
             rts