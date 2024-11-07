;****************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 13 - Blitter Objects
;
; (c) 2024 Stefano Coppi
;****************************************************************

               incdir     "include"
               include    "hw.i"
               include    "funcdef.i"
               include    "exec/exec_lib.i"
               include    "graphics/graphics_lib.i"

;****************************************************************
; CONSTANTS
;****************************************************************

; DMACON register settings
; enables blitter DMA (bit 6)
; enables copper DMA (bit 7)
; enables bitplanes DMA (bit 8)
                     ;5432109876543210
DMASET           equ %1000001111000000 


; display
N_PLANES         equ 8
DISPLAY_WIDTH    equ 320
DISPLAY_HEIGHT   equ 256
DISPLAY_PLANE_SZ equ DISPLAY_HEIGHT*(DISPLAY_WIDTH/8)
DISPLAY_ROW_SIZE equ (DISPLAY_WIDTH/8)


BOB_WIDTH        equ 128
BOB_HEIGHT       equ 77
BOB_SPEED        equ 1


;****************************************************************
; DATA STRUCTURES
;****************************************************************

; bob
               rsreset
bob.valid      rs.w       1                                    ; 1 valid data, 0 invalid
bob.x          rs.w       1                                    ; x position
bob.y          rs.w       1                                    ; y position
bob.width      rs.w       1                                    ; width
bob.height     rs.w       1
bob.src_addr   rs.l       1                                    ; source address
bob.dest_addr  rs.l       1                                    ; destination address
bob.bltsize    rs.w       1                                    ; blit size
bob.length     rs.b       0



               SECTION    code_section,CODE


;****************************************************************
; MAIN PROGRAM
;****************************************************************
main:
               nop
               nop
               bsr        take_system                          ; takes the control of Amiga's hardware
               move.l     #dbuffer1,d0                         ; address of bgnd image in d0
               bsr        init_bplpointers                     ; initializes bitplane pointers to our image
             

mainloop: 
               bsr        wait_vblank                          ; waits for vertical blank
               bsr        swap_buffers

               lea        bob_ship,a1                          ; bob strucure
               bsr        update_bob

               lea        bob_ship,a1                          ; bob strucure
               move.w     #128,d2                              ; ship width in px
               move.w     #77,d3                               ; ship height in px
               bsr        restore_bob_bgnd

               lea        bob_ship,a1
               move.w     bob.x(a1),d0                         ; x-coordinate of ship in px
               move.w     #81,d1                               ; y-coordinate of ship in px
               move.w     #128,d2                              ; ship width in px
               move.w     #77,d3                               ; ship height in px
               bsr        save_bob_bgnd
               
               lea        bob_ship,a6
               lea        ship,a0                              ; ship's image address
               lea        ship_mask,a1                         ; ship's mask address
               move.l     draw_buffer,a2                       ; destination video buffer address
               move.w     bob.x(a6),d0                         ; x-coordinate of ship in px
               move.w     #81,d1                               ; y-coordinate of ship in px
               move.w     #128,d2                              ; ship width in px
               move.w     #77,d3                               ; ship height in px
               move.w     #0,d4                                ; spritesheet column of ship
               move.w     #0,d5                                ; spritesheet row of ship
               move.w     #128,a3                              ; spritesheet width
               move.w     #77,a4                               ; spritesheet height
               bsr        draw_bob                             ; draws player ship

               btst       #6,CIAAPRA                           ; left mouse button pressed?
               bne.s      mainloop                             ; if not, repeats the loop

               bsr        release_system                       ; releases the hw control to the O.S.
               rts


;****************************************************************
; SUBROUTINES
;****************************************************************


;****************************************************************
; Takes full control of Amiga hardware,
; disabling the O.S. in a controlled way.
;****************************************************************
take_system:
               move.l     ExecBase,a6                          ; base address of Exec
               jsr        _LVOForbid(a6)                       ; disables O.S. multitasking
               jsr        _LVODisable(a6)                      ; disables O.S. interrupts

               lea        gfx_name,a1                          ; OpenLibrary takes 1 parameter: library name in a1
               jsr        _LVOOldOpenLibrary(a6)               ; opens graphics.library
               move.l     d0,gfx_base                          ; saves base address of graphics.library in a variable
            
               move.l     d0,a6                                ; gfx base                   
               move.l     $26(a6),sys_coplist                  ; saves system copperlist address
             
               jsr        _LVOOwnBlitter(a6)                   ; takes the Blitter exclusive

               lea        CUSTOM,a5                            ; a5 will always contain CUSTOM chips base address $dff000
          
               move.w     DMACONR(a5),old_dma                  ; saves state of DMA channels in a variable
               move.w     #$7fff,DMACON(a5)                    ; disables all DMA channels
               move.w     #DMASET,DMACON(a5)                   ; sets only dma channels that we will use

               move.l     #copperlist,COP1LC(a5)               ; sets our copperlist address into Copper
               move.w     d0,COPJMP1(a5)                       ; reset Copper PC to the beginning of our copperlist       

               move.w     #0,FMODE(a5)                         ; sets 16 bit FMODE
               move.w     #$c00,BPLCON3(a5)                    ; disables 24 bit palette                        
               move.w     #$11,BPLCON4(a5)                     ; enables normal palette

               rts


;****************************************************************
; Releases the hardware control to the O.S.
;****************************************************************
release_system:
               move.l     sys_coplist,COP1LC(a5)               ; restores the system copperlist
               move.w     d0,COPJMP1(a5)                       ; starts the system copperlist 

               or.w       #$8000,old_dma                       ; sets bit 15
               move.w     old_dma,DMACON(a5)                   ; restores saved DMA state

               move.l     gfx_base,a6
               jsr        _LVODisownBlitter(a6)                ; release Blitter ownership
               move.l     ExecBase,a6                          ; base address of Exec
               jsr        _LVOPermit(a6)                       ; enables O.S. multitasking
               jsr        _LVOEnable(a6)                       ; enables O.S. interrupts
               move.l     gfx_base,a1                          ; base address of graphics.library in a1
               jsr        _LVOCloseLibrary(a6)                 ; closes graphics.library
               rts


;****************************************************************
; Initializes bitplane pointers
;
; parameters:
; d0.l - address of bitplanes
;****************************************************************
init_bplpointers:
               movem.l    d0-a6,-(sp)
                   
               lea        bplpointers,a1                       ; bitplane pointers in a1
               move.l     #(N_PLANES-1),d1                     ; number of loop iterations in d1
.loop:
               move.w     d0,6(a1)                             ; copy low word of image address into BPLxPTL (low word of BPLxPT)
               swap       d0                                   ; swap high and low word of image address
               move.w     d0,2(a1)                             ; copy high word of image address into BPLxPTH (high word of BPLxPT)
               swap       d0                                   ; resets d0 to the initial condition
               add.l      #DISPLAY_PLANE_SZ,d0                 ; point to the next bitplane
               add.l      #8,a1                                ; point to next bplpointer
               dbra       d1,.loop                             ; repeats the loop for all planes
            
               movem.l    (sp)+,d0-a6
               rts 


;************************************************************************
; Waits for the electron beam to reach a given line.
;
; parameters:
; d2.l - line
;************************************************************************
wait_vline:
               movem.l    d0-a6,-(sp)                          ; saves registers into the stack

               lsl.l      #8,d2
               move.l     #$1ff00,d1
wait:
               move.l     VPOSR(a5),d0
               and.l      d1,d0
               cmp.l      d2,d0
               bne.s      wait

               movem.l    (sp)+,d0-a6                          ; restores registers from the stack
               rts


;************************************************************************
; Waits for the vertical blank
;************************************************************************
wait_vblank:
               movem.l    d0-a6,-(sp)                          ; saves registers into the stack
               move.l     #304,d2                              ; line to wait: 304 236
               bsr        wait_vline
               movem.l    (sp)+,d0-a6                          ; restores registers from the stack
               rts


;************************************************************************
; Swaps video buffers, causing draw_buffer to be displayed.
;************************************************************************
swap_buffers:
               movem.l    d0-a6,-(sp)                          ; saves registers into the stack

               move.l     draw_buffer,d0                       ; swaps the values ​​of draw_buffer and view_buffer
               move.l     view_buffer,draw_buffer
               move.l     d0,view_buffer
               lea        bplpointers,a1                       ; sets the bitplane pointers to the view_buffer 
               moveq      #N_PLANES-1,d1                                            
.loop:
               move.w     d0,6(a1)                             ; copies low word
               swap       d0                                   ; swaps low and high word of d0
               move.w     d0,2(a1)                             ; copies high word
               swap       d0                                   ; resets d0 to the initial condition
               add.l      #DISPLAY_PLANE_SZ,d0                 ; points to the next bitplane
               add.l      #8,a1                                ; points to next bplpointer
               dbra       d1,.loop                             ; repeats the loop for all planes

               movem.l    (sp)+,d0-a6                          ; restores registers from the stack
               rts


;************************************************************************
; Wait for the blitter to finish
;************************************************************************
wait_blitter:
.loop:
               btst.b     #6,DMACONR(a5)                       ; if bit 6 is 1, the blitter is busy
               bne        .loop                                ; and then wait until it's zero
               rts 


;************************************************************************
; Draws a Bob using the blitter.
;
; parameters:
; a0   - Bob's image address
; a1   - Bob's mask address
; a2   - destination video buffer address
; d0.w - x-coordinate of Bob in px
; d1.w - y-coordinate of Bob in px
; d2.w - bob width in px
; d3.w - bob height in px
; d4.w - spritesheet column of the bob
; d5.w - spritesheet row of the bob
; a3.w - spritesheet width
; a4.w - spritesheet height
;************************************************************************
draw_bob:
               movem.l    d0-a6,-(sp)

    ; calculates destination address (D channel)
               mulu.w     #DISPLAY_ROW_SIZE,d1                 ; offset_y = y * DISPLAY_ROW_SIZE
               add.l      d1,a2                                ; adds offset_y to destination address
               move.w     d0,d6                                ; copies x
               lsr.w      #3,d0                                ; offset_x = x/8
               and.w      #$fffe,d0                            ; makes offset_x even
               add.w      d0,a2                                ; adds offset_x to destination address
    
    ; calculates source address (channels A,B)
               move.w     d2,d1                                ; makes a copy of bob width in d1
               lsr.w      #3,d1                                ; bob width in bytes (bob_width/8)
               mulu       d1,d4                                ; offset_x = column * (bob_width/8)
               add.w      d4,a0                                ; adds offset_x to the base address of bob's image
               add.w      d4,a1                                ; and bob's mask
               mulu       d3,d5                                ; bob_height * row
               move.w     a3,d1                                ; copies spritesheet width in d1
               asr.w      #3,d1                                ; spritesheet_row_size = spritesheet_width / 8
               mulu       d1,d5                                ; offset_y = row * bob_height * spritesheet_row_size
               add.w      d5,a0                                ; adds offset_y to the base address of bob's image
               add.w      d5,a1                                ; and bob's mask

    ; calculates the modulus of channels A,B
               move.w     a3,d1                                ; copies spritesheet_width in d1
               sub.w      d2,d1                                ; spritesheet_width - bob_width
               sub.w      #16,d1                               ; spritesheet_width - bob_width -16
               asr.w      #3,d1                                ; (spritesheet_width - bob_width -16)/8

    ; calculates the modulus of channels C,D
               lsr        #3,d2                                ; bob_width/8
               add.w      #2,d2                                ; adds 2 to the sprite width in bytes, due to the shift
               move.w     #DISPLAY_ROW_SIZE,d4                 ; screen width in bytes
               sub.w      d2,d4                                ; modulus (d4) = screen_width - bob_width
    
    ; calculates the shift value for channels A,B (d6) and value of BLTCON0 (d5)
               and.w      #$000f,d6                            ; selects the first 4 bits of x
               lsl.w      #8,d6                                ; moves the shift value to the upper nibble
               lsl.w      #4,d6                                ; so as to have the value to insert in BLTCON1
               move.w     d6,d5                                ; copy to calculate the value to insert in BLTCON0
               or.w       #$0fca,d5                            ; value to insert in BLTCON0
                                                                                  ; logic function LF = $ca

    ; calculates the blit size (d3)
               lsl.w      #6,d3                                ; bob_height<<6
               lsr.w      #1,d2                                ; bob_width/2 (in word)
               or         d2,d3                                ; combines the dimensions into the value to be inserted into BLTSIZE

    ; calculates the size of a BOB spritesheet bitplane
               move.w     a3,d2                                ; copies spritesheet_width in d2
               lsr.w      #3,d2                                ; spritesheet_width/8
               and.w      #$fffe,d2                            ; makes even
               move.w     a4,d0                                ; spritesheet_height
               mulu       d0,d2                                ; multiplies by the height

    ; initializes the registers that remain constant
               bsr        wait_blitter
               move.w     #$ffff,BLTAFWM(a5)                   ; first word of channel A: no mask
               move.w     #$0000,BLTALWM(a5)                   ; last word of channel A: reset all bits
               move.w     d6,BLTCON1(a5)                       ; shift value for channel A
               move.w     d5,BLTCON0(a5)                       ; activates all 4 channels,logic_function=$CA,shift
               move.w     d1,BLTAMOD(a5)                       ; modules for channels A,B
               move.w     d1,BLTBMOD(a5)
               move.w     d4,BLTCMOD(a5)                       ; modules for channels C,D
               move.w     d4,BLTDMOD(a5)
               moveq      #N_PLANES-1,d7                       ; number of cycle repetitions

    ; copy cycle for each bitplane
.plane_loop:
               bsr        wait_blitter
               move.l     a1,BLTAPT(a5)                        ; channel A: Bob's mask
               move.l     a0,BLTBPT(a5)                        ; channel B: Bob's image
               move.l     a2,BLTCPT(a5)                        ; channel C: draw buffer
               move.l     a2,BLTDPT(a5)                        ; channel D: draw buffer
               move.w     d3,BLTSIZE(a5)                       ; blit size and starts blit operation

               add.l      d2,a0                                ; points to the next bitplane
               add.l      #DISPLAY_PLANE_SZ,a2                                         
               dbra       d7,.plane_loop                       ; repeats the cycle for each bitplane

               movem.l    (sp)+,d0-a6
               rts


;************************************************************************
; Saves Bob's background.
;
; parameters:
; d0.w - x-coordinate of Bob in px
; d1.w - y-coordinate of Bob in px
; d2.w - bob width in px
; d3.w - bob height in px
; a1   - address of bob structure instance
;************************************************************************
save_bob_bgnd:
               movem.l    d0-a6,-(sp)

               move.l     draw_buffer,a0                       ; source address
               mulu.w     #DISPLAY_ROW_SIZE,d1                 ; offset_y = y * DISPLAY_ROW_SIZE
               add.l      d1,a0                                ; adds offset_y to source address
               move.w     d0,d6                                ; copies x
               lsr.w      #3,d0                                ; offset_x = x/8
               and.w      #$fffe,d0                            ; makes offset_x even
               ext.l      d0
               add.l      d0,a0                                ; adds offset_x to source address
               move.l     a0,bob.src_addr(a1)

; calculates the modulus of channels C,D
               lsr        #3,d2                                ; bob_width/8
               add.w      #2,d2                                ; adds 2 to the sprite width in bytes, due to the shift
               move.w     #DISPLAY_ROW_SIZE,d4                 ; screen width in bytes
               sub.w      d2,d4                                ; modulus (d4) = screen_width - bob_width

; calculates the size of a BOB buffer bitplane
               move.w     d3,d5
               mulu.w     d2,d5

; calculates the blit size (d3)
               lsl.w      #6,d3                                ; bob_height<<6
               lsr.w      #1,d2                                ; bob_width/2 (in word)
               or         d2,d3                                ; combines the dimensions into the value to be inserted into BLTSIZE
               move.w     d3,bob.bltsize(a1)

               bsr        wait_blitter
               move.w     #$ffff,BLTAFWM(a5)                   ; first word of channel A: no mask
               move.w     #$ffff,BLTALWM(a5)                   ; last word of channel A: no mask
               move.w     #0,BLTCON1(a5)
               move.w     $09f0,BLTCON0(a5)                    ; copies A to D
               move.w     d4,BLTAMOD(a5)                       ; modulus for channel A
               move.w     #0,BLTDMOD(a5)                       ; modulus for channel D
               moveq      #N_PLANES-1,d7                       ; number of cycle repetitions
               move.l     bob.dest_addr(a1),a2

; copy cycle for each bitplane
.plane_loop:
               bsr        wait_blitter
               move.l     a0,BLTAPT(a5)                        ; channel A: draw buffer
               move.l     a2,BLTDPT(a5)                        ; channel D: destination buffer
               move.w     d3,BLTSIZE(a5)                       ; blit size and starts blit operation

               add.l      d5,a2                                ; points to the next bitplane
               add.l      #DISPLAY_PLANE_SZ,a0                                         
               dbra       d7,.plane_loop                       ; repeats the cycle for each bitplane    

               move.w     #1,bob.valid(a1)

               movem.l    (sp)+,d0-a6
               rts


;************************************************************************
; Resores Bob's background.
;
; parameters:
; d2.w - bob width in px
; d3.w - bob height in px
; a1   - address of bob structure instance
;************************************************************************
restore_bob_bgnd:
               movem.l    d0-a6,-(sp)

               tst.w      bob.valid(a1)                        ; bob.valid = 0?
               beq        .return                              ; if yes, returns immediately because there isn't a stored background

; calculates the modulus of channel D
               lsr        #3,d2                                ; bob_width/8
               add.w      #2,d2                                ; adds 2 to the sprite width in bytes, due to the shift
               move.w     #DISPLAY_ROW_SIZE,d4                 ; screen width in bytes
               sub.w      d2,d4                                ; modulus (d4) = screen_width - bob_width

               mulu.w     d2,d3                                ; size of a BOB buffer bitplane

               bsr        wait_blitter
               move.w     #$ffff,BLTAFWM(a5)                   ; first word of channel A: no mask
               move.w     #$ffff,BLTALWM(a5)                   ; last word of channel A: no mask
               move.w     #0,BLTCON1(a5)
               move.w     $09f0,BLTCON0(a5)                    ; copies A to D
               move.w     #0,BLTAMOD(a5)                       ; modulus for channel A
               move.w     d4,BLTDMOD(a5)                       ; modulus for channel D
               moveq      #N_PLANES-1,d7                       ; number of cycle repetitions
               move.l     bob.src_addr(a1),a2
               move.l     bob.dest_addr(a1),a0

; copy cycle for each bitplane
.plane_loop:
               bsr        wait_blitter
               move.l     a0,BLTAPT(a5)                        ; channel A: bob dest_addr
               move.l     a2,BLTDPT(a5)                        ; channel D: destination buffer
               move.w     bob.bltsize(a1),BLTSIZE(a5)          ; blit size and starts blit operation

               add.l      d3,a2                                ; points to the next bitplane
               add.l      #DISPLAY_PLANE_SZ,a0                                         
               dbra       d7,.plane_loop                       ; repeats the cycle for each bitplane    

.return:
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

               add.w      #BOB_SPEED,bob.x(a1)

               move.w     bob.x(a1),d0
               cmp.w      #192,d0
               bge        .clampx
               bra        .return
.clampx:
               move.w     #192,bob.x(a1)

.return:
               movem.l    (sp)+,d0-a6
               rts


;************************************************************************
; VARIABLES
;************************************************************************
gfx_name       dc.b       "graphics.library",0,0               ; string containing the name of graphics.library
gfx_base       dc.l       0                                    ; base address of graphics.library
old_dma        dc.w       0                                    ; saved state of DMACON
sys_coplist    dc.l       0                                    ; address of system copperlist  

view_buffer    dc.l       dbuffer1                             ; buffer displayed on screen
draw_buffer    dc.l       dbuffer2                             ; drawing buffer (not visible)


bob_ship       dc.w       0                                    ; bob.valid
               dc.w       0                                    ; x position
               dc.w       81                                   ; y position
               dc.w       128                                  ; width
               dc.w       77                                   ; height  
               dc.l       0                                    ; source address
               dc.l       bob_buffer                           ; destination address
               dc.w       0                                    ; blit size


;************************************************************************
; Graphics data
;************************************************************************

; segment loaded in CHIP RAM
               SECTION    graphics_data,DATA_C

copperlist:
               dc.w       DIWSTRT,$2c81                        ; display window start at ($81,$2c)
               dc.w       DIWSTOP,$2cc1                        ; display window stop at ($1c1,$12c)
               dc.w       DDFSTRT,$38                          ; display data fetch start at $38
               dc.w       DDFSTOP,$d0                          ; display data fetch stop at $d0
               dc.w       BPLCON1,0                                          
               dc.w       BPLCON2,0                               
               dc.w       BPL1MOD,0                      
               dc.w       BPL2MOD,0


; BPLCON0 ($100)
; bit 0: set to 1 to enable BLTCON3 register
; bit 4: most significant bit of bitplane number
; bit 9: set to 1 to enable composite video output
; bit 12-14: least significant bits of bitplane number
;                                5432109876543210
               dc.w       BPLCON0,%0000001000010001

; FMODE
; bit 0-1: 16 bit fetch mode
; bit 2-3: 16 pixel sprite width
               dc.w       FMODE,0


bplpointers:
               dc.w       $e0,0,$e2,0                          ; plane 1
               dc.w       $e4,0,$e6,0                          ; plane 2
               dc.w       $e8,0,$ea,0                          ; plane 3
               dc.w       $ec,0,$ee,0                          ; plane 4
               dc.w       $f0,0,$f2,0                          ; plane 5
               dc.w       $f4,0,$f6,0                          ; plane 6
               dc.w       $f8,0,$fa,0                          ; plane 7
               dc.w       $fc,0,$fe,0                          ; plane 8


palette        incbin     "gfx/palette.pal"

               dc.w       $ffff,$fffe                          ; end of copperlist


ship           incbin     "gfx/ship6.raw"
ship_mask      incbin     "gfx/ship6.mask"


dbuffer1       incbin     "gfx/space_bgnd.raw"                 ; display buffers used for double buffering
dbuffer2       incbin     "gfx/space_bgnd.raw"


;**************************************************************************************************************************************************************************
; BSS DATA
; Section containing zero-valued data.
;**************************************************************************************************************************************************************************

               SECTION    bss_data,BSS_C

bob_buffer     ds.b       BOB_HEIGHT*(BOB_WIDTH/8)*N_PLANES


               END