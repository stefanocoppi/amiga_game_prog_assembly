;****************************************************************
; Blitter Objects (Bobs) management
;
; (c) 2024 Stefano Coppi
;****************************************************************

                    incdir     "include"
                    include    "hw.i"
                    include    "playfield.i"
                    include    "bob.i"

                    xdef       wait_blitter,draw_bob,bgnd_list_ptr,bgnd_list_ptr2,bgnd_list_counter,bgnd_list_counter2

;************************************************************************
; BSS DATA
;************************************************************************
                    SECTION    bss_data,BSS_C
                                                  
bgnd_list1          ds.b       (bob_bgnd.length*BGND_LIST_MAX_ITEMS)       ; list containing the backgrounds of the bobs to be deleted
bgnd_list2          ds.b       (bob_bgnd.length*BGND_LIST_MAX_ITEMS)  


                    SECTION    code_section,CODE

;************************************************************************
; VARIABLES
;************************************************************************
bgnd_list_ptr       dc.l       bgnd_list1                                  ; points to the list of bob backgrounds to delete
bgnd_list_ptr2      dc.l       bgnd_list2                                  ; two pointers to swap in swap_buffers due to double buffering

bgnd_list_counter   dc.w       0                                           ; number of items in the backgrounds list
bgnd_list_counter2  dc.w       0                                           ; doubled for double buffering


;************************************************************************
; Wait for the blitter to finish
;************************************************************************
wait_blitter:
.loop:
                    btst.b     #6,DMACONR(a5)                              ; if bit 6 is 1, the blitter is busy
                    bne        .loop                                       ; and then wait until it's zero
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
                    mulu.w     #PF2_ROW_SIZE,d1                            ; offset_y = y * PF2_ROW_SIZE
                    add.l      d1,a2                                       ; adds offset_y to destination address
                    move.w     bob.x(a3),d0
                    lsr.w      #3,d0                                       ; offset_x = x/8
                    and.w      #$fffe,d0                                   ; makes offset_x even
                    add.w      d0,a2                                       ; adds offset_x to destination address
    
    ; saves background information to be cleared in a list
                    cmp.w      #BGND_LIST_MAX_ITEMS-1,bgnd_list_counter    ; if the list is full
                    beq        .skip_save_bgnd                             ; skips saving background
                    move.l     bgnd_list_ptr,a0                            ; locates the first free element in the background list
                    move.w     bgnd_list_counter,d0
                    mulu.w     #bob_bgnd.length,d0
                    add.l      d0,a0
                    move.l     a2,bob_bgnd.addr(a0)                        ; saves background address in list
                    move.w     bob.width(a3),bob_bgnd.width(a0)            ; saves width
                    move.w     bob.height(a3),bob_bgnd.height(a0)          ; saves height
                    add.w      #1,bgnd_list_counter
.skip_save_bgnd:         
    ; calculates source address (channels A,B)
                    move.l     bob.imgdata(a3),a0
                    move.l     bob.mask(a3),a1
                    move.w     bob.width(a3),d1             
                    lsr.w      #3,d1                                       ; bob width in bytes (bob_width/8)
                    move.w     bob.ssheet_c(a3),d4
                    mulu       d1,d4                                       ; offset_x = column * (bob_width/8)
                    add.w      d4,a0                                       ; adds offset_x to the base address of bob's image
                    add.w      d4,a1                                       ; and bob's mask
                    move.w     bob.height(a3),d3
                    move.w     bob.ssheet_r(a3),d5
                    mulu       d3,d5                                       ; bob_height * row
                    move.w     bob.ssheet_w(a3),d1
                    asr.w      #3,d1                                       ; spritesheet_row_size = spritesheet_width / 8
                    mulu       d1,d5                                       ; offset_y = row * bob_height * spritesheet_row_size
                    add.w      d5,a0                                       ; adds offset_y to the base address of bob's image
                    add.w      d5,a1                                       ; and bob's mask

    ; calculates the modulus of channels A,B
                    move.w     bob.ssheet_w(a3),d1                         ; copies spritesheet_width in d1
                    move.w     bob.width(a3),d2
                    sub.w      d2,d1                                       ; spritesheet_width - bob_width
                    sub.w      #16,d1                                      ; spritesheet_width - bob_width -16
                    asr.w      #3,d1                                       ; (spritesheet_width - bob_width -16)/8

    ; calculates the modulus of channels C,D
                    move.w     bob.width(a3),d2
                    lsr        #3,d2                                       ; bob_width/8
                    add.w      #2,d2                                       ; adds 2 to the sprite width in bytes, due to the shift
                    move.w     #PF2_ROW_SIZE,d4                            ; screen width in bytes
                    sub.w      d2,d4                                       ; modulus (d4) = screen_width - bob_width
    
    ; calculates the shift value for channels A,B (d6) and value of BLTCON0 (d5)
                    move.w     bob.x(a3),d6
                    and.w      #$000f,d6                                   ; selects the first 4 bits of x
                    lsl.w      #8,d6                                       ; moves the shift value to the upper nibble
                    lsl.w      #4,d6                                       ; so as to have the value to insert in BLTCON1
                    move.w     d6,d5                                       ; copy to calculate the value to insert in BLTCON0
                    or.w       #$0fca,d5                                   ; value to insert in BLTCON0
                                                       ; logic function LF = $ca

    ; calculates the blit size (d3)
                    move.w     bob.height(a3),d3
                    lsl.w      #6,d3                                       ; bob_height<<6
                    lsr.w      #1,d2                                       ; bob_width/2 (in word)
                    or         d2,d3                                       ; combines the dimensions into the value to be inserted into BLTSIZE

    ; calculates the size of a BOB spritesheet bitplane
                    move.w     bob.ssheet_w(a3),d2                         ; copies spritesheet_width in d2
                    lsr.w      #3,d2                                       ; spritesheet_width/8
                    and.w      #$fffe,d2                                   ; makes even
                    move.w     bob.ssheet_h(a3),d0                         ; spritesheet_height
                    mulu       d0,d2                                       ; multiplies by the height

    ; initializes the registers that remain constant
                    jsr        wait_blitter
                    move.w     #$ffff,BLTAFWM(a5)                          ; first word of channel A: no mask
                    move.w     #$0000,BLTALWM(a5)                          ; last word of channel A: reset all bits
                    move.w     d6,BLTCON1(a5)                              ; shift value for channel A
                    move.w     d5,BLTCON0(a5)                              ; activates all 4 channels,logic_function=$CA,shift
                    move.w     d1,BLTAMOD(a5)                              ; modules for channels A,B
                    move.w     d1,BLTBMOD(a5)
                    move.w     d4,BLTCMOD(a5)                              ; modules for channels C,D
                    move.w     d4,BLTDMOD(a5)
                    moveq      #BPP-1,d7                                   ; number of cycle repetitions

    ; copy cycle for each bitplane
.plane_loop:
                    jsr        wait_blitter
                    move.l     a1,BLTAPT(a5)                               ; channel A: Bob's mask
                    move.l     a0,BLTBPT(a5)                               ; channel B: Bob's image
                    move.l     a2,BLTCPT(a5)                               ; channel C: draw buffer
                    move.l     a2,BLTDPT(a5)                               ; channel D: draw buffer
                    move.w     d3,BLTSIZE(a5)                              ; blit size and starts blit operation

                    add.l      d2,a0                                       ; points to the next bitplane
                    add.l      #PF2_PLANE_SZ,a2                                         
                    dbra       d7,.plane_loop                              ; repeats the cycle for each bitplane

                    movem.l    (sp)+,d0-a6
                    rts