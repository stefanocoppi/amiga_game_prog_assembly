;************************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 7 - How to display images on screen
;
; (c) 2024 Stefano Coppi
;************************************************************************

             incdir     "include"
             include    "hw.i"

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
; enables copper DMA (bit 7)
; enables bitplanes DMA (bit 8)
                     ;5432109876543210
DMASET           equ %1000001110000000             

; display
NUM_COLORS       equ 256
N_PLANES         equ 8
DISPLAY_WIDTH    equ 320
DISPLAY_HEIGHT   equ 256
DISPLAY_PLANE_SZ equ DISPLAY_HEIGHT*(DISPLAY_WIDTH/8)


             SECTION    code_section,CODE

;************************************************************************
; MAIN PROGRAM
;************************************************************************
main:
             nop
             nop
             bsr        take_system                    ; takes the control of Amiga's hardware
             move.l     #img_space6,d0                 ; address of image in d0
             bsr        init_bplpointers               ; initializes bitplane pointers to our image

mainloop: 
             btst       #6,CIAAPRA                     ; left mouse button pressed?
             bne.s      mainloop                       ; if not, repeats the loop

             bsr        release_system                 ; releases the hw control to the O.S.
             rts


;************************************************************************
; SUBROUTINES
;************************************************************************

;************************************************************************
; Takes full control of Amiga hardware,
; disabling the O.S. in a controlled way.
;************************************************************************
take_system:
             move.l     ExecBase,a6                    ; base address of Exec
             lea        gfx_name,a1                    ; OpenLibrary takes 1 parameter: library name in a1
             jsr        OpenLibrary(a6)                ; opens graphics.library
             move.l     d0,gfx_base                    ; saves base address of graphics.library in a variable
            
             move.l     d0,a0                          ; gfx base                   
             move.l     $26(a0),sys_coplist            ; saves system copperlist address
  
             jsr        Forbid(a6)                     ; disables O.S. multitasking
             jsr        Disable(a6)                    ; disables O.S. interrupts 
             lea        CUSTOM,a5                      ; a5 will always contain CUSTOM chips base address $dff000
          
             move.w     DMACONR(a5),old_dma            ; saves state of DMA channels in a variable
             move.w     #$7fff,DMACON(a5)              ; disables all DMA channels
             move.w     #DMASET,DMACON(a5)             ; sets only dma channels that we will use

             move.l     #copperlist,COP1LC(a5)         ; sets our copperlist address into Copper
             move.w     d0,COPJMP1(a5)                 ; reset Copper PC to the beginning of our copperlist       

  
             move.w     #0,FMODE(a5)                   ; sets 16 bit FMODE
             move.w     #$c00,BPLCON3(a5)              ; sets default value                       
             move.w     #$11,BPLCON4(a5)               ; sets default value      
             rts


;************************************************************************
; Releases the hardware control to the O.S.
;************************************************************************
release_system:
             move.l     sys_coplist,COP1LC(a5)         ; restores the system copperlist
             move.w     d0,COPJMP1(a5)                 ; starts the system copperlist 

             or.w       #$8000,old_dma                 ; sets bit 15
             move.w     old_dma,DMACON(a5)             ; restores saved DMA state

             move.l     ExecBase,a6                    ; base address of Exec
             jsr        Permit(a6)                     ; enables O.S. multitasking
             jsr        Enable(a6)                     ; enables O.S. interrupts
             move.l     gfx_base,a1                    ; base address of graphics.library in a1
             jsr        CloseLibrary(a6)               ; closes graphics.library
             rts


;************************************************************************
; Initializes bitplane pointers
;
; parameters:
; d0.l - address of bitplanes
;************************************************************************
init_bplpointers:
             movem      d0-a6,-(sp)
                   
             lea        bplpointers,a1                 ; bitplane pointers in a1
             move.l     #(N_PLANES-1),d1               ; number of loop iterations in d1
.loop:
             move.w     d0,6(a1)                       ; copy low word of image address into BPLxPTL (low word of BPLxPT)
             swap       d0                             ; swap high and low word of image address
             move.w     d0,2(a1)                       ; copy high word of image address into BPLxPTH (high word of BPLxPT)
             swap       d0                             ; resets d0 to the initial condition
             add.l      #DISPLAY_PLANE_SZ,d0           ; point to the next bitplane
             add.l      #8,a1                          ; point to next bplpointer
             dbra       d1,.loop                       ; repeats the loop for all planes
            
             movem      (sp)+,d0-a6
             rts 


;************************************************************************
; VARIABLES
;************************************************************************
gfx_name     dc.b       "graphics.library",0,0         ; string containing the name of graphics.library
gfx_base     dc.l       0                              ; base address of graphics.library
old_dma      dc.w       0                              ; saved state of DMACON
sys_coplist  dc.l       0                              ; address of system copperlist                                     


;************************************************************************
; Graphics data
;************************************************************************

; segment loaded in CHIP RAM
             SECTION    graphics_data,DATA_C

copperlist:
             dc.w       DIWSTRT,$2c81                  ; display window start at ($81,$2c)
             dc.w       DIWSTOP,$2cc1                  ; display window stop at ($1c1,$12c)
             dc.w       DDFSTRT,$38                    ; display data fetch start at $38
             dc.w       DDFSTOP,$d0                    ; display data fetch stop at $d0
             dc.w       BPLCON1,0                                          
             dc.w       BPLCON2,0                                             
             dc.w       BPL1MOD,0                                             
             dc.w       BPL2MOD,0
            

  ; BPLCON0 ($100)
  ; bit 0: set to 1 to enable BLTCON3 register
  ; bit 4: most significant bit of bitplane number
  ; bit 9: set to 1 to enable composite video output
  ; bit 12-14: least significant bits of bitplane number
  ;                              5432109876543210
             dc.w       BPLCON0,%0000001000010001

bplpointers:
             dc.w       $e0,0,$e2,0                    ; plane 1
             dc.w       $e4,0,$e6,0                    ; plane 2
             dc.w       $e8,0,$ea,0                    ; plane 3
             dc.w       $ec,0,$ee,0                    ; plane 4
             dc.w       $f0,0,$f2,0                    ; plane 5
             dc.w       $f4,0,$f6,0                    ; plane 6
             dc.w       $f8,0,$fa,0                    ; plane 7
             dc.w       $fc,0,$fe,0                    ; plane 8

palette      incbin     "gfx/space.pal"                ; palette

             dc.w       $ffff,$fffe                    ; end of copperlist

         
img_space6   incbin     "gfx/space.raw"                ; image 320 x 256 pixel , 8 bitplanes


             END