;****************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 4 - Take control of Amiga hardware
;
; (c) 2024 Stefano Coppi
;****************************************************************

          incdir     "include"
          include    "hw.i"

;****************************************************************
; CONSTANTS
;****************************************************************

; O.S. subroutines
ExecBase     equ $4
Disable      equ -$78
Forbid       equ -132
Enable       equ -$7e
Permit       equ -138
OpenLibrary  equ -$198
CloseLibrary equ -$19e
CIAAPRA      equ $bfe001

; DMACON register settings
                 ;5432109876543210
DMASET       equ %1000001000000000             


          SECTION    code_section,CODE

;****************************************************************
; MAIN PROGRAM
;****************************************************************
main:
          nop
          nop
          bsr        take_system               ; takes the control of Amiga's hardware
    
mainloop  btst       #6,CIAAPRA                ; left mouse button pressed?
          bne.s      mainloop                  ; if not, repeats the loop

          bsr        release_system            ; releases the hw control to the O.S.
          rts


;****************************************************************
; SUBROUTINES
;****************************************************************

;****************************************************************
; Takes full control of Amiga hardware,
; disabling the O.S. in a controlled way.
;****************************************************************
take_system:
          move.l     ExecBase,a6               ; base address of Exec
          lea        gfx_name,a1               ; OpenLibrary takes 1 parameter: library name in a1          
          jsr        OpenLibrary(a6)           ; opens graphics.library
          move.l     d0,gfx_base               ; saves base address of graphics.library in a variable

          jsr        Forbid(a6)                ; disables O.S. multitasking
          jsr        Disable(a6)               ; disables O.S. interrupts
          lea        CUSTOM,a5                 ; a5 will always contain CUSTOM chips base address $dff000
          
          move.w     DMACONR(a5),old_dma       ; saves state of DMA channels in a variable
          move.w     #$7fff,DMACON(a5)         ; disables all DMA channels
          move.w     #DMASET,DMACON(a5)        ; sets only dma channels that we will use

    ; disables AGA features. only needed on A1200,A4000
          move.w     #0,$1fc(a5)               ; sets 16 bit FMODE    
          move.w     #$c00,$106(a5)            ; disables 24 bit palette                                 
          move.w     #$11,$10c(a5)             ; enables normal palette
          rts


;****************************************************************
; Releases the hardware control to the O.S.
;****************************************************************
release_system:
          or.w       #$8000,old_dma            ; sets bit 15
          move.w     old_dma,DMACON(a5)        ; restores saved DMA state
    
          move.l     ExecBase,a6               ; base address of Exec
          jsr        Permit(a6)                ; enables O.S. multitasking
          jsr        Enable(a6)                ; enables O.S. interrupts
          move.l     gfx_base,a1               ; base address of graphics.library
          jsr        CloseLibrary(a6)          ; closes graphics.library
          rts


;****************************************************************
; VARIABLES
;****************************************************************

 ; string containing the name of graphics.library
gfx_name  dc.b       "graphics.library",0,0
; base address of graphics.library   
gfx_base  dc.l       0
; saved state of DMACON
old_dma   dc.w       0                        


          END