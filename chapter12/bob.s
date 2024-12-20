;************************************************************************
; Blitter Objects (Bobs) management
;
; (c) 2024 Stefano Coppi
;************************************************************************

             incdir     "include"
             include    "hw.i"
             include    "playfield.i"
             include    "bob.i"


;****************************************************************
; PUBLIC SYMBOLS
;****************************************************************
             xdef       dbuffer1
             xdef       update_bob
             xdef       draw_bob
             xdef       restore_bob_bgnd
             xdef       save_bob_bgnd
             xdef       update_bob


;****************************************************************
; EXTERNAL REFERENCES
;****************************************************************
             xref       bplpointers


;************************************************************************
; Graphics data
;************************************************************************
; segment loaded in CHIP RAM
             SECTION    graphics_data,DATA_C

dbuffer1     incbin     "gfx/space_bgnd.raw"       ; display buffers used for double buffering
dbuffer2     incbin     "gfx/space_bgnd.raw"


;************************************************************************
; VARIABLES
;************************************************************************
             SECTION    code_section,CODE
             
view_buffer  dc.l       dbuffer1                   ; buffer displayed on screen
             
             xdef       draw_buffer
draw_buffer  dc.l       dbuffer2                   ; drawing buffer (not visible)


;************************************************************************
; SUBROUTINES
;************************************************************************          
             

;************************************************************************
; Wait for the blitter to finish
;************************************************************************
             xdef       wait_blitter
wait_blitter:
.loop:
             btst.b     #6,DMACONR(a5)             ; if bit 6 is 1, the blitter is busy
             bne        .loop                      ; and then wait until it's zero
             rts


;************************************************************************
; Swaps video buffers, causing draw_buffer to be displayed.
;************************************************************************
             xdef       swap_buffers
swap_buffers:
             movem.l    d0-a6,-(sp)                ; saves registers into the stack

             move.l     draw_buffer,d0             ; swaps the values ​​of draw_buffer and view_buffer
             move.l     view_buffer,draw_buffer
             move.l     d0,view_buffer
             lea        bplpointers,a1             ; sets the bitplane pointers to the view_buffer 
             moveq      #BPP-1,d1                                            
.loop:
             move.w     d0,6(a1)                   ; copies low word
             swap       d0                         ; swaps low and high word of d0
             move.w     d0,2(a1)                   ; copies high word
             swap       d0                         ; resets d0 to the initial condition
             add.l      #PF_PLANE_SZ,d0            ; points to the next bitplane
             add.l      #8,a1                      ; points to next bplpointer
             dbra       d1,.loop                   ; repeats the loop for all planes

             movem.l    (sp)+,d0-a6                ; restores registers from the stack
             rts


;************************************************************************
; Draws a Bob using the blitter.
;
; parameters:
; a3 - bob's data
; a2 - destination video buffer address
;************************************************************************
draw_bob:
             movem.l    d0-a6,-(sp)

    ; calculates destination address (D channel)
             move.w     bob.y(a3),d1
             mulu.w     #PF_ROW_SIZE,d1            ; offset_y = y * PF_ROW_SIZE
             add.l      d1,a2                      ; adds offset_y to destination address
             move.w     bob.x(a3),d0
             lsr.w      #3,d0                      ; offset_x = x/8
             and.w      #$fffe,d0                  ; makes offset_x even
             add.w      d0,a2                      ; adds offset_x to destination address
    
    ; calculates source address (channels A,B)
             move.l     bob.imgdata(a3),a0
             move.l     bob.mask(a3),a1
             move.w     bob.width(a3),d1             
             lsr.w      #3,d1                      ; bob width in bytes (bob_width/8)
             move.w     bob.ssheet_c(a3),d4
             mulu       d1,d4                      ; offset_x = column * (bob_width/8)
             add.w      d4,a0                      ; adds offset_x to the base address of bob's image
             add.w      d4,a1                      ; and bob's mask
             move.w     bob.height(a3),d3
             move.w     bob.ssheet_r(a3),d5
             mulu       d3,d5                      ; bob_height * row
             move.w     bob.ssheet_w(a3),d1
             asr.w      #3,d1                      ; spritesheet_row_size = spritesheet_width / 8
             mulu       d1,d5                      ; offset_y = row * bob_height * spritesheet_row_size
             add.w      d5,a0                      ; adds offset_y to the base address of bob's image
             add.w      d5,a1                      ; and bob's mask

    ; calculates the modulus of channels A,B
             move.w     bob.ssheet_w(a3),d1        ; copies spritesheet_width in d1
             move.w     bob.width(a3),d2
             sub.w      d2,d1                      ; spritesheet_width - bob_width
             sub.w      #16,d1                     ; spritesheet_width - bob_width -16
             asr.w      #3,d1                      ; (spritesheet_width - bob_width -16)/8

    ; calculates the modulus of channels C,D
             move.w     bob.width(a3),d2
             lsr        #3,d2                      ; bob_width/8
             add.w      #2,d2                      ; adds 2 to the sprite width in bytes, due to the shift
             move.w     #PF_ROW_SIZE,d4            ; screen width in bytes
             sub.w      d2,d4                      ; modulus (d4) = screen_width - bob_width
    
    ; calculates the shift value for channels A,B (d6) and value of BLTCON0 (d5)
             move.w     bob.x(a3),d6
             and.w      #$000f,d6                  ; selects the first 4 bits of x
             lsl.w      #8,d6                      ; moves the shift value to the upper nibble
             lsl.w      #4,d6                      ; so as to have the value to insert in BLTCON1
             move.w     d6,d5                      ; copy to calculate the value to insert in BLTCON0
             or.w       #$0fca,d5                  ; value to insert in BLTCON0
                                                       ; logic function LF = $ca

    ; calculates the blit size (d3)
             move.w     bob.height(a3),d3
             lsl.w      #6,d3                      ; bob_height<<6
             lsr.w      #1,d2                      ; bob_width/2 (in word)
             or         d2,d3                      ; combines the dimensions into the value to be inserted into BLTSIZE

    ; calculates the size of a BOB spritesheet bitplane
             move.w     bob.ssheet_w(a3),d2        ; copies spritesheet_width in d2
             lsr.w      #3,d2                      ; spritesheet_width/8
             and.w      #$fffe,d2                  ; makes even
             move.w     bob.ssheet_h(a3),d0        ; spritesheet_height
             mulu       d0,d2                      ; multiplies by the height

    ; initializes the registers that remain constant
             bsr        wait_blitter
             move.w     #$ffff,BLTAFWM(a5)         ; first word of channel A: no mask
             move.w     #$0000,BLTALWM(a5)         ; last word of channel A: reset all bits
             move.w     d6,BLTCON1(a5)             ; shift value for channel A
             move.w     d5,BLTCON0(a5)             ; activates all 4 channels,logic_function=$CA,shift
             move.w     d1,BLTAMOD(a5)             ; modules for channels A,B
             move.w     d1,BLTBMOD(a5)
             move.w     d4,BLTCMOD(a5)             ; modules for channels C,D
             move.w     d4,BLTDMOD(a5)
             moveq      #BPP-1,d7                  ; number of cycle repetitions

    ; copy cycle for each bitplane
.plane_loop:
             bsr        wait_blitter
             move.l     a1,BLTAPT(a5)              ; channel A: Bob's mask
             move.l     a0,BLTBPT(a5)              ; channel B: Bob's image
             move.l     a2,BLTCPT(a5)              ; channel C: draw buffer
             move.l     a2,BLTDPT(a5)              ; channel D: draw buffer
             move.w     d3,BLTSIZE(a5)             ; blit size and starts blit operation

             add.l      d2,a0                      ; points to the next bitplane
             add.l      #PF_PLANE_SZ,a2                                         
             dbra       d7,.plane_loop             ; repeats the cycle for each bitplane

             movem.l    (sp)+,d0-a6
             rts


;************************************************************************
; Updates bob's state.
;
; parameters:
; a1   - address of bob structure instance
;************************************************************************
update_bob:
             movem.l    d0-a6,-(sp)

             move.w     bob.speed(a1),d0           ; adds speed to actual position
             add.w      d0,bob.x(a1)

             move.w     bob.x(a1),d0               ; limits x position to avoid exiting the screen
             cmp.w      #192,d0
             bge        .clampx
             bra        .return
.clampx:
             move.w     #192,bob.x(a1)

.return:
             movem.l    (sp)+,d0-a6
             rts


;************************************************************************
; Saves Bob's background.
;
; parameters:
; a1 - bob's data
;************************************************************************
save_bob_bgnd:
             movem.l    d0-a6,-(sp)

             move.l     draw_buffer,a0
             move.w     bob.y(a1),d1               
             mulu.w     #PF_ROW_SIZE,d1            ; offset_y = y * PF_ROW_SIZE
             add.l      d1,a0                        
             move.w     bob.x(a1),d0                        
             lsr.w      #3,d0                      ; offset_x = x/8
             and.w      #$fffe,d0                  ; makes offset_x even
             ext.l      d0
             add.l      d0,a0                      ; calculates address of the background to save
                     
             move.l     draw_buffer,a3
             move.l     a1,a2
             cmp.l      #dbuffer1,a3               ; draw_buffer = dbuffer1 ?
             beq        .set_buffer1
             add.l      #bob.buffer2,a2            ; uses bob.buffer2 to save the background
             move.l     a0,bob.dst_addr2(a1)       ; saves the address where restore the background
             move.w     #1,bob.valid2(a1)          ; makes data of buffer 2 valid
             bra        .calc_modulus
.set_buffer1:
             add.l      #bob.buffer1,a2            ; uses bob.buffer1 to save the background
             move.l     a0,bob.dst_addr1(a1)       ; saves the address where restore the background
             move.w     #1,bob.valid1(a1)          ; makes data of buffer 1 valid

.calc_modulus:
; calculates the modulus of channel D
             move.w     bob.width(a1),d2
             lsr        #3,d2                      ; bob_width/8
             add.w      #2,d2                      ; adds 2 to the sprite width in bytes, due to the shift
             move.w     #PF_ROW_SIZE,d4            ; screen width in bytes
             sub.w      d2,d4                      ; modulus (d4) = screen_width - bob_width

; calculates the size of a BOB buffer bitplane
             move.w     bob.height(a1),d5
             mulu.w     d2,d5

; calculates the blit size (d3)
             move.w     bob.height(a1),d3
             lsl.w      #6,d3                      ; bob_height<<6
             lsr.w      #1,d2                      ; bob_width/2 (in word)
             or         d2,d3                      ; combines the dimensions into the value to be inserted into BLTSIZE
             move.w     d3,bob.bltsize(a1)

             bsr        wait_blitter
             move.w     #$ffff,BLTAFWM(a5)         ; first word of channel A: no mask
             move.w     #$ffff,BLTALWM(a5)         ; last word of channel A: no mask
             move.w     #0,BLTCON1(a5)
             move.w     #$09f0,BLTCON0(a5)         ; copies A to D
             move.w     d4,BLTAMOD(a5)             ; modulus for channel A
             move.w     #0,BLTDMOD(a5)             ; modulus for channel D
             moveq      #BPP-1,d7                  ; number of cycle repetitions

; copy cycle for each bitplane
.plane_loop:
             bsr        wait_blitter
             move.l     a0,BLTAPT(a5)              ; channel A: draw buffer
             move.l     a2,BLTDPT(a5)              ; channel D: destination buffer
             move.w     d3,BLTSIZE(a5)             ; blit size and starts blit operation

             add.l      d5,a2                      ; points to the next bitplane
             add.l      #PF_PLANE_SZ,a0                                         
             dbra       d7,.plane_loop             ; repeats the cycle for each bitplane    

             movem.l    (sp)+,d0-a6
             rts


;************************************************************************
; Restores Bob's background.
;
; parameters:
; a1   - address of bob structure instance
;************************************************************************
restore_bob_bgnd:
             movem.l    d0-a6,-(sp)

             move.l     draw_buffer,a0
             cmp.l      #dbuffer1,a0               ; draw_buffer = dbuffer1?
             beq        .set_buffer1
             tst.w      bob.valid2(a1)             ; if data aren't valid, returns
             beq        .return
             move.l     a1,a0
             add.l      #bob.buffer2,a0            ; saved background in buffer2
             move.l     bob.dst_addr2(a1),a2       ; where the background will be restored
             clr.w      bob.valid2(a1)             ; makes data invalid
             bra        .restore
.set_buffer1:
             tst.w      bob.valid1(a1)             ; if data aren't valid, returns
             beq        .return
             move.l     a1,a0
             add.l      #bob.buffer1,a0            ; saved background in buffer1
             move.l     bob.dst_addr1(a1),a2       ; where the background will be restored
             clr.w      bob.valid1(a1)             ; makes data invalid
.restore:
             move.w     bob.bltsize(a1),d0
; calculates the modulus of channel D
             move.w     bob.width(a1),d2
             lsr        #3,d2                      ; bob_width/8
             add.w      #2,d2                      ; adds 2 to the sprite width in bytes, due to the shift
             move.w     #PF_ROW_SIZE,d4            ; screen width in bytes
             sub.w      d2,d4                      ; modulus (d4) = screen_width - bob_width

             move.w     bob.height(a1),d3
             mulu.w     d2,d3                      ; size of a BOB buffer bitplane

             bsr        wait_blitter
             move.w     #$ffff,BLTAFWM(a5)         ; first word of channel A: no mask
             move.w     #$ffff,BLTALWM(a5)         ; last word of channel A: no mask
             move.w     #0,BLTCON1(a5)
             move.w     #$09f0,BLTCON0(a5)         ; copies A to D
             move.w     #0,BLTAMOD(a5)             ; modulus for channel A
             move.w     d4,BLTDMOD(a5)             ; modulus for channel D
             moveq      #BPP-1,d7                  ; number of cycle repetitions
                     
; copy cycle for each bitplane
.plane_loop:
             bsr        wait_blitter
             move.l     a0,BLTAPT(a5)              ; channel A: bob dest_addr
             move.l     a2,BLTDPT(a5)              ; channel D: destination buffer
             move.w     d0,BLTSIZE(a5)             ; blit size and starts blit operation

             add.l      d3,a0                      ; points to the next bitplane
             add.l      #PF_PLANE_SZ,a2                                         
             dbra       d7,.plane_loop             ; repeats the cycle for each bitplane    

.return:
             movem.l    (sp)+,d0-a6
             rts