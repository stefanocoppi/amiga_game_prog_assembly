;****************************************************************
; Playfield management.
;
; (c) 2024 Stefano Coppi
;****************************************************************


;****************************************************************
; INCLUDES
;**************************************************************** 
  incdir     "include"
  include    "hw.i"
  include    "playfield.i"


;****************************************************************
; SUBROUTINES
;****************************************************************
  SECTION    code_section,CODE


;****************************************************************
; Initializes bitplane pointers
;
; parameters;
; a1   - address of bpl pointers in the copperlist
; d0.l - address of playfield
; d1.l - playfield plane size (in bytes)
; d7.l - bitplanes number
;****************************************************************
  xdef       init_bplpointers
init_bplpointers:
  movem.l    d0-a6,-(sp)
                         
  sub.l      #1,d7                ; number of iterations
.loop:
  move.w     d0,6(a1)             ; copy low word of image address into BPLxPTL (low word of BPLxPT)
  swap       d0                   ; swap high and low word of image address
  move.w     d0,2(a1)             ; copy high word of image address into BPLxPTH (high word of BPLxPT)
  swap       d0                   ; resets d0 to the initial condition
  add.l      d1,d0                ; points to the next bitplane
  add.l      #8,a1                ; poinst to next bplpointer
  dbra       d7,.loop             ; repeats the loop for all planes
            
  movem.l    (sp)+,d0-a6
  rts

