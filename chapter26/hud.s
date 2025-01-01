;****************************************************************
; HUD (Head Up Display)
;
; (c) 2024 Stefano Coppi
;****************************************************************

                  incdir     "include"
                  include    "hw.i"
                  include    "hud.i"
                  include    "playfield.i"
                  include    "bob.i
                  include    "plship.i"


;****************************************************************
; GRAPHICS DATA in chip ram
;****************************************************************
                  SECTION    graphics_data,DATA_C

                  xdef       hud_bgnd
hud_bgnd          incbin     "gfx/hud_bgnd.raw"
;hud_bgnd          dcb.b      12800,0
;hud_bar_gfx       incbin     "gfx/bar.raw"
                  xdef       hud_bar_gfx
hud_bar_gfx       dcb.b      4400,0
;hud_bar_gfx_mask  incbin     "gfx/bar.mask"
                  xdef       hud_bar_gfx_mask
hud_bar_gfx_mask  dcb.b      880,0


;****************************************************************
; VARIABLES
;****************************************************************
                  SECTION    code_section,CODE

score             dc.w       0                        ; player score
score_str         dc.b       '00000',0                ; string used to display score

hud_bar           dc.w       143                      ; bob.x 
                  dc.w       42                       ; bob.y
                  dc.w       0                        ; bob.speed
                  dc.w       128                      ; bob.width
                  dc.w       5                        ; bob.height
                  dc.w       0                        ; bob.ssheet_c
                  dc.w       0                        ; bob.ssheet_r
                  dc.w       128                      ; bob.ssheet_w
                  dc.w       55                       ; bob.ssheet_h
                  dc.l       hud_bar_gfx              ; bob.imgdata
                  dc.l       hud_bar_gfx_mask         ; bob.mask
                  dc.l       hud_bgnd                 ; address of playfield where bob is drawn
                  dc.w       HUD_BPP                  ; number of bitplanes
                  dc.w       HUD_ROW_SIZE             ; playfield row size
                  dc.l       HUD_PLANE_SZ             ; playfield plane size


;****************************************************************
; SUBROUTINES
;****************************************************************
          

;****************************************************************
; Initializes the hud.
;****************************************************************
                  xdef       init_hud
init_hud:
                  movem.l    d0-a6,-(sp)

; sets bitplane pointers to hud background image
                  lea        bplpointers_hud,a1          
                  move.l     #hud_bgnd,d0
                  move.l     #HUD_PLANE_SZ,d1
                  move.l     #HUD_BPP,d7
                  jsr        init_bplpointers

; resets score
                  clr.w      score
; draws score
                  jsr        draw_score
; draws hud bar
                  move.w     #PLSHIP_MAX_ENERGY,d0
                  jsr        draw_hud_bar

                  movem.l    (sp)+,d0-a6
                  rts


;****************************************************************
; Draws the score on the HUD.
;****************************************************************
draw_score:
                  movem.l    d0-a6,-(sp)
    
; converts the score into a string
                  move.w     score,d0
                  lea        score_str,a0
                  jsr        num2string
    
; draws the score string on the panel
                  lea        score_str,a2
                  move.w     #88,d3                   ; x
                  move.w     #19,d4                   ; y
                  jsr        draw_string
    
                  movem.l    (sp)+,d0-a6
                  rts


;****************************************************************
; Adds a given amount of points to score.
;
; parameters:
; d0.w - amount of points to add
;****************************************************************
                  xdef       add_to_score
add_to_score:
                  movem.l    d0-a6,-(sp)
    
                  add.w      d0,score
                  bsr        draw_score
    
                  movem.l    (sp)+,d0-a6
                  rts


;****************************************************************
; Draws the hud bar.
;
; parameters;
; d0.w - energy (0-20)
;****************************************************************
                  xdef       draw_hud_bar
draw_hud_bar:
                  movem.l    d0-a6,-(sp)

                  lea        hud_bar,a3

                  mulu       #5,d0                    ; converts energy to range 0-100
                  and.l      #$0000ffff,d0            ; resets high word of d0, because divu takes a long
                  divu       #10,d0                   ; bar_length / 10
                  move.w     #10,d1
                  sub.w      d0,d1                    ; bar frame = 10 - bar_length/10
                  move.w     d1,bob.ssheet_r(a3)      ; changes animation frame

                  jsr        draw_bob_hud

                  movem.l    (sp)+,d0-a6
                  rts


;************************************************************************
; Draws a Bob using the blitter, on the HUD.
;
; parameters:
; a3 - bob's data
;************************************************************************
draw_bob_hud:
                  movem.l    d0-a6,-(sp)

                  lea        hud_bgnd,a2              ; destination playfield: HUD
    ; calculates destination address (D channel)
                  move.w     bob.y(a3),d1
                  mulu.w     #HUD_ROW_SIZE,d1         ; offset_y = y * HUD_ROW_SIZE
                  add.l      d1,a2                    ; adds offset_y to destination address
                  move.w     bob.x(a3),d0
                  lsr.w      #3,d0                    ; offset_x = x/8
                  and.w      #$fffe,d0                ; makes offset_x even
                  add.w      d0,a2                    ; adds offset_x to destination address
    
    ; calculates source address (channel A)
                  move.l     bob.imgdata(a3),a0
                  move.w     bob.width(a3),d1             
                  lsr.w      #3,d1                    ; bob width in bytes (bob_width/8)
                  move.w     bob.ssheet_c(a3),d4
                  mulu       d1,d4                    ; offset_x = column * (bob_width/8)
                  add.w      d4,a0                    ; adds offset_x to the base address of bob's image
                  move.w     bob.height(a3),d3
                  move.w     bob.ssheet_r(a3),d5
                  mulu       d3,d5                    ; bob_height * row
                  move.w     bob.ssheet_w(a3),d1
                  asr.w      #3,d1                    ; spritesheet_row_size = spritesheet_width / 8
                  mulu       d1,d5                    ; offset_y = row * bob_height * spritesheet_row_size
                  add.w      d5,a0                    ; adds offset_y to the base address of bob's image

    ; calculates the modulus of channel A
                  move.w     bob.ssheet_w(a3),d1      ; copies spritesheet_width in d1
                  move.w     bob.width(a3),d2
                  sub.w      d2,d1                    ; spritesheet_width - bob_width
                  sub.w      #16,d1                   ; spritesheet_width - bob_width -16
                  asr.w      #3,d1                    ; (spritesheet_width - bob_width -16)/8

    ; calculates the modulus of channel D
                  move.w     bob.width(a3),d2
                  lsr        #3,d2                    ; bob_width/8
                  add.w      #2,d2                    ; adds 2 to the sprite width in bytes, due to the shift
                  move.w     #HUD_ROW_SIZE,d4         ; screen width in bytes
                  sub.w      d2,d4                    ; modulus (d4) = screen_width - bob_width
    
    ; calculates the shift value for channels A and value of BLTCON0 (d5)
                  move.w     bob.x(a3),d6
                  and.w      #$000f,d6                ; selects the first 4 bits of x
                  lsl.w      #8,d6                    ; moves the shift value to the upper nibble
                  lsl.w      #4,d6                    ; so as to have the value to insert in BLTCON1
                  move.w     d6,d5                    ; copy to calculate the value to insert in BLTCON0
                  or.w       #$09f0,d5                ; value to insert in BLTCON0
                                                      ; logic function LF = $f0, D = A

    ; calculates the blit size (d3)
                  move.w     bob.height(a3),d3
                  lsl.w      #6,d3                    ; bob_height<<6
                  lsr.w      #1,d2                    ; bob_width/2 (in word)
                  or         d2,d3                    ; combines the dimensions into the value to be inserted into BLTSIZE

    ; calculates the size of a BOB spritesheet bitplane
                  move.w     bob.ssheet_w(a3),d2      ; copies spritesheet_width in d2
                  lsr.w      #3,d2                    ; spritesheet_width/8
                  and.w      #$fffe,d2                ; makes even
                  move.w     bob.ssheet_h(a3),d0      ; spritesheet_height
                  mulu       d0,d2                    ; multiplies by the height

    ; initializes the registers that remain constant
                  jsr        wait_blitter
                  move.w     #$ffff,BLTAFWM(a5)       ; first word of channel A: no mask
                  move.w     #$0000,BLTALWM(a5)       ; last word of channel A: reset all bits
                  move.w     #0,BLTCON1(a5)           ; no shift for channel B
                  move.w     d5,BLTCON0(a5)           
                  move.w     d1,BLTAMOD(a5)           ; modules for channels A,D
                  move.w     d4,BLTDMOD(a5)
                  moveq      #HUD_BPP-1,d7            ; number of cycle repetitions

    ; copy cycle for each bitplane
.plane_loop:
                  jsr        wait_blitter
                  move.l     a0,BLTAPT(a5)            ; channel A: Bob's image
                  move.l     a2,BLTDPT(a5)            ; channel D: draw buffer
                  move.w     d3,BLTSIZE(a5)           ; blit size and starts blit operation

                  add.l      d2,a0                    ; points to the next bitplane
                  add.l      #HUD_PLANE_SZ,a2                                         
                  dbra       d7,.plane_loop           ; repeats the cycle for each bitplane

                  movem.l    (sp)+,d0-a6
                  rts

