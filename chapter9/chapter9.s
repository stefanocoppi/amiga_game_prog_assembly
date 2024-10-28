;************************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 9 - 
;
; (c) 2024 Stefano Coppi
;************************************************************************

             incdir     "include"
             include    "hw.i"
             include    "funcdef.i"
             include    "exec/exec_lib.i"
             include    "graphics/graphics_lib.i"

;************************************************************************
; CONSTANTS
;************************************************************************

; O.S. subroutines
ExecBase         equ $4
Disable          equ -$78
Forbid           equ -132
Enable           equ -$7e
Permit           equ -138
OpenLibrary      equ -$198
CloseLibrary     equ -$19e
CIAAPRA          equ $bfe001

; DMACON register settings
; enables blitter DMA (bit 6)
; enables copper DMA (bit 7)
; enables bitplanes DMA (bit 8)
                     ;5432109876543210
DMASET           equ %1000001111000000             

; display
N_PLANES         equ 3
DISPLAY_WIDTH    equ 320
DISPLAY_HEIGHT   equ 256
DISPLAY_PLANE_SZ equ DISPLAY_HEIGHT*(DISPLAY_WIDTH/8)
DISPLAY_ROW_SIZE equ (DISPLAY_WIDTH/8)
TILE_WIDTH       equ 64
TILE_HEIGHT      equ 64
TILE_PLANE_SZ    equ TILE_HEIGHT*(TILE_WIDTH/8)

             SECTION    code_section,CODE

;************************************************************************
; MAIN PROGRAM
;************************************************************************
main:
             nop
             nop
             bsr        take_system                                  ; takes the control of Amiga's hardware
             move.l     #screen,d0                                   ; address of screen in d0
             bsr        init_bplpointers                             ; initializes bitplane pointers to our image

             lea        img_tile,a0
             move.w     #(DISPLAY_WIDTH-TILE_WIDTH)/2,d0             ; x position
             move.w     #(DISPLAY_HEIGHT-TILE_HEIGHT)/2,d1           ; y position
             mulu       #DISPLAY_ROW_SIZE,d1                         ; y_offset = y * DISPLAY_ROW_SIZE
             asr.w      #3,d0                                        ; x_offset = x/8
             add.w      d1,d0                                        ; sum the offsets
             ext.l      d0
             lea        screen,a1
             add.l      d0,a1                                        ; sum the offset to a1
             bsr        draw_tile

mainloop: 
             btst       #6,CIAAPRA                                   ; left mouse button pressed?
             bne.s      mainloop                                     ; if not, repeats the loop

             bsr        release_system                               ; releases the hw control to the O.S.
             rts


;************************************************************************
; SUBROUTINES
;************************************************************************

;************************************************************************
; Takes full control of Amiga hardware,
; disabling the O.S. in a controlled way.
;************************************************************************
take_system:
             move.l     ExecBase,a6                                  ; base address of Exec
             jsr        _LVOForbid(a6)                               ; disables O.S. multitasking
             jsr        _LVODisable(a6)                              ; disables O.S. interrupts

             lea        gfx_name,a1                                  ; OpenLibrary takes 1 parameter: library name in a1
             jsr        _LVOOldOpenLibrary(a6)                       ; opens graphics.library
             move.l     d0,gfx_base                                  ; saves base address of graphics.library in a variable
            
             move.l     d0,a6                                        ; gfx base                   
             move.l     $26(a6),sys_coplist                          ; saves system copperlist address
             
             jsr        _LVOOwnBlitter(a6)                           ; takes the Blitter exclusive

             lea        CUSTOM,a5                                    ; a5 will always contain CUSTOM chips base address $dff000
          
             move.w     DMACONR(a5),old_dma                          ; saves state of DMA channels in a variable
             move.w     #$7fff,DMACON(a5)                            ; disables all DMA channels
             move.w     #DMASET,DMACON(a5)                           ; sets only dma channels that we will use

             move.l     #copperlist,COP1LC(a5)                       ; sets our copperlist address into Copper
             move.w     d0,COPJMP1(a5)                               ; reset Copper PC to the beginning of our copperlist       

             move.w     #0,FMODE(a5)                                 ; sets 16 bit FMODE
             move.w     #$c00,BPLCON3(a5)                            ; sets default value                       
             move.w     #$11,BPLCON4(a5)                             ; sets default value

             rts


;************************************************************************
; Releases the hardware control to the O.S.
;************************************************************************
release_system:
             move.l     sys_coplist,COP1LC(a5)                       ; restores the system copperlist
             move.w     d0,COPJMP1(a5)                               ; starts the system copperlist 

             or.w       #$8000,old_dma                               ; sets bit 15
             move.w     old_dma,DMACON(a5)                           ; restores saved DMA state

             move.l     gfx_base,a6
             jsr        _LVODisownBlitter(a6)                        ; release Blitter ownership
             move.l     ExecBase,a6                                  ; base address of Exec
             jsr        _LVOPermit(a6)                               ; enables O.S. multitasking
             jsr        _LVOEnable(a6)                               ; enables O.S. interrupts
             move.l     gfx_base,a1                                  ; base address of graphics.library in a1
             jsr        _LVOCloseLibrary(a6)                         ; closes graphics.library
             rts


;************************************************************************
; Initializes bitplane pointers
;
; parameters:
; d0.l - address of bitplanes
;************************************************************************
init_bplpointers:
             movem.l    d0-a6,-(sp)
                   
             lea        bplpointers,a1                               ; bitplane pointers in a1
             move.l     #(N_PLANES-1),d1                             ; number of loop iterations in d1
.loop:
             move.w     d0,6(a1)                                     ; copy low word of image address into BPLxPTL (low word of BPLxPT)
             swap       d0                                           ; swap high and low word of image address
             move.w     d0,2(a1)                                     ; copy high word of image address into BPLxPTH (high word of BPLxPT)
             swap       d0                                           ; resets d0 to the initial condition
             add.l      #DISPLAY_PLANE_SZ,d0                         ; point to the next bitplane
             add.l      #8,a1                                        ; point to next bplpointer
             dbra       d1,.loop                                     ; repeats the loop for all planes
            
             movem.l    (sp)+,d0-a6
             rts 


;************************************************************************
; Wait for the blitter to finish
;************************************************************************
wait_blitter:
.loop:
             btst.b     #6,DMACONR(a5)                               ; if bit 6 is 1, the blitter is busy
             bne        .loop                                        ; and then wait until it's zero
             rts 


;************************************************************************
; Draw a 64x64 pixel tile using blitter
;
; parameters:
; a0 - address of tile
; a1 - address where draw the tile
;************************************************************************
draw_tile:
             movem.l    d0-a6,-(sp)                                  ; saves registers into the stack

             moveq      #N_PLANES-1,d1
             bsr        wait_blitter
             move.w     #$ffff,BLTAFWM(a5)                           ; don't use mask
             move.w     #$ffff,BLTALWM(a5)
             move.w     #$09f0,BLTCON0(a5)                           ; enable channels A,D
                                                                     ; logical function = $f0, D = A
             move.w     #0,BLTCON1(a5)
             move.w     #0,BLTAMOD(a5)
             
             move.w     #(DISPLAY_WIDTH-TILE_WIDTH)/8,BLTDMOD(a5)    ; D channel modulus
.loop:
             bsr        wait_blitter
             move.l     a0,BLTAPT(a5)                                ; source address
             move.l     a1,BLTDPT(a5)                                ; destination address
             move.w     #64*64+4,BLTSIZE(a5)                         ; blit size: 64 rows for 4 words
             add.l      #TILE_PLANE_SZ,a0                            ; advances to the next plane
             add.l      #DISPLAY_PLANE_SZ,a1
             dbra       d1,.loop
             bsr        wait_blitter

             movem.l    (sp)+,d0-a6                                  ; restores registers values from the stack
             rts


;************************************************************************
; VARIABLES
;************************************************************************
gfx_name     dc.b       "graphics.library",0,0                       ; string containing the name of graphics.library
gfx_base     dc.l       0                                            ; base address of graphics.library
old_dma      dc.w       0                                            ; saved state of DMACON
sys_coplist  dc.l       0                                            ; address of system copperlist                                     


;************************************************************************
; Graphics data
;************************************************************************

; segment loaded in CHIP RAM
             SECTION    graphics_data,DATA_C

copperlist:
             dc.w       DIWSTRT,$2c81                                ; display window start at ($81,$2c)
             dc.w       DIWSTOP,$2cc1                                ; display window stop at ($1c1,$12c)
             dc.w       DDFSTRT,$38                                  ; display data fetch start at $38
             dc.w       DDFSTOP,$d0                                  ; display data fetch stop at $d0
             dc.w       BPLCON1,0                                          
             dc.w       BPLCON2,0                                             
             dc.w       BPL1MOD,0                                             
             dc.w       BPL2MOD,0
            

  ; BPLCON0 ($100)
  ; bit 0: set to 1 to enable BLTCON3 register
  ; bit 4: most significant bit of bitplane number
  ; bit 9: set to 1 to enable composite video output
  ; bit 12-14: least significant bits of bitplane number
  ; bitplane number: 3 => %0011
  ;                              5432109876543210
             dc.w       BPLCON0,%0011001000000001
             dc.w       FMODE,0                                      ; 16 bit fetch mode

bplpointers:
             dc.w       $e0,0,$e2,0                                  ; plane 1
             dc.w       $e4,0,$e6,0                                  ; plane 2
             dc.w       $e8,0,$ea,0                                  ; plane 3

palette      incbin     "gfx/tile.pal"                               ; palette

             dc.w       $ffff,$fffe                                  ; end of copperlist

         
img_tile     incbin     "gfx/tile.raw"                               ; image 64 x 64 pixel , 3 bitplanes


;************************************************************************
; BSS DATA
;************************************************************************

             SECTION    bss_data,BSS_C

screen       ds.b       (DISPLAY_PLANE_SZ*N_PLANES)                  ; visible screen

             END