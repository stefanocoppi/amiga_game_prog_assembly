;****************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 6 - The Copper and copperlist
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
; enables only copper DMA (bit 7)
                 ;5432109876543210
DMASET       equ %1000001010000000             


  SECTION    code_section,CODE

;****************************************************************
; MAIN PROGRAM
;****************************************************************
main:
  nop
  nop
  ; takes the control of Amiga's hardware
  bsr        take_system
    
mainloop: 
  ; left mouse button pressed?
  btst       #6,CIAAPRA
  ; if not, repeats the loop
  bne.s      mainloop

  ; releases the hw control to the O.S.
  bsr        release_system
  rts


;****************************************************************
; SUBROUTINES
;****************************************************************

;****************************************************************
; Takes full control of Amiga hardware,
; disabling the O.S. in a controlled way.
;****************************************************************
take_system:
  ; base address of Exec
  move.l     ExecBase,a6
  ; OpenLibrary takes 1 parameter: library name in a1                 
  lea        gfx_name,a1
  ; opens graphics.library    
  jsr        OpenLibrary(a6)
  ; saves base address of graphics.library in a variable
  move.l     d0,gfx_base

  ; gfx base
  move.l     d0,a0                     
  ; saves system copperlist address
  move.l     $26(a0),sys_coplist       
  
  ; disables O.S. multitasking
  jsr        Forbid(a6)
  ; disables O.S. interrupts               
  jsr        Disable(a6)
  ; a5 will always contain CUSTOM chips base address $dff000
  lea        CUSTOM,a5
          
  ; saves state of DMA channels in a variable
  move.w     DMACONR(a5),old_dma
  ; disables all DMA channels
  move.w     #$7fff,DMACON(a5)
  ; sets only dma channels that we will use
  move.w     #DMASET,DMACON(a5)

  ; sets our copperlist address into Copper
  move.l     #copperlist,COP1LC(a5)
  ; reset Copper PC to the beginning of our copperlist    
  move.w     d0,COPJMP1(a5)            

  ; disables AGA features. only needed on A1200,A4000
  ; sets 16 bit FMODE
  move.w     #0,$1fc(a5)
  ; disables 24 bit palette                  
  move.w     #$c00,$106(a5)
  ; enables normal palette                                            
  move.w     #$11,$10c(a5)
  rts


;****************************************************************
; Releases the hardware control to the O.S.
;****************************************************************
release_system:
  ; restores the system copperlist
  move.l     sys_coplist,COP1LC(a5)
  ; starts the system copperlist   
  move.w     d0,COPJMP1(a5)

  ; sets bit 15
  or.w       #$8000,old_dma
  ; restores saved DMA state
  move.w     old_dma,DMACON(a5)

  ; base address of Exec
  move.l     ExecBase,a6
  ; enables O.S. multitasking               
  jsr        Permit(a6)
  ; enables O.S. interrupts
  jsr        Enable(a6)
  ; base address of graphics.library in a1
  move.l     gfx_base,a1
  ; closes graphics.library
  jsr        CloseLibrary(a6)
  rts


;****************************************************************
; VARIABLES
;****************************************************************

; string containing the name of graphics.library
gfx_name:
  dc.b       "graphics.library",0,0
; base address of graphics.library   
gfx_base:
  dc.l       0
; saved state of DMACON
old_dma:
  dc.w       0
; address of system copperlist
sys_coplist:
  dc.l       0                                         


;****************************************************************
; Graphics data
;****************************************************************

; segment loaded in CHIP RAM
  SECTION    graphics_data,DATA_C

copperlist:
  ; BPLCON0 lowres video mode
  dc.w       $100,$0200
  ; puts blue value into COLOR0 register                
  dc.w       $0180,$000f
  ; WAIT line 192 ($c0)               
  dc.w       $c001,$fffe
  ; puts black value into COLOR0 register
  dc.w       $0180,$0000
  ; end of copperlist               
  dc.w       $ffff,$fffe               

  END