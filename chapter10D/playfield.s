;****************************************************************
; Playfield management.
;
; (c) 2024 Stefano Coppi
;****************************************************************
  
  incdir     "include"
  include    "hw.i"


;************************************************************************
; Initializes bitplane pointers
;
; parameters;
; a1   - address of bpl pointers in the copperlist
; d0.l - address of playfield
; d1.l - playfield plane size (in bytes)
; d7.l - bitplanes number
;************************************************************************
  xdef       init_bplpointers
init_bplpointers:
  movem.l    d0-a6,-(sp)
                         
  sub.l      #1,d7               ; number of iterations
.loop:
  move.w     d0,6(a1)            ; copy low word of image address into BPLxPTL (low word of BPLxPT)
  swap       d0                  ; swap high and low word of image address
  move.w     d0,2(a1)            ; copy high word of image address into BPLxPTH (high word of BPLxPT)
  swap       d0                  ; resets d0 to the initial condition
  add.l      d1,d0               ; points to the next bitplane
  add.l      #8,a1               ; poinst to next bplpointer
  dbra       d7,.loop            ; repeats the loop for all planes
            
  movem.l    (sp)+,d0-a6
  rts


;************************************************************************
; Waits for the electron beam to reach a given line.
;
; parameters:
; d2.l - line
;************************************************************************
wait_vline:
  movem.l    d0-a6,-(sp)         ; saves registers into the stack

  lsl.l      #8,d2
  move.l     #$1ff00,d1
wait:
  move.l     VPOSR(a5),d0
  and.l      d1,d0
  cmp.l      d2,d0
  bne.s      wait

  movem.l    (sp)+,d0-a6         ; restores registers from the stack
  rts


;************************************************************************
; Waits for the vertical blank
;************************************************************************
  xdef       wait_vblank
wait_vblank:
  movem.l    d0-a6,-(sp)         ; saves registers into the stack
  move.l     #304,d2             ; line to wait: 304 236
  bsr        wait_vline
  movem.l    (sp)+,d0-a6         ; restores registers from the stack
  rts
