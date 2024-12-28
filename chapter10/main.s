;****************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 10 - Scrolling Background
;
; simple version using Blitter to scroll.
;
; (c) 2024 Stefano Coppi
;****************************************************************


;****************************************************************
; INCLUDES
;****************************************************************
  incdir     "include"
  include    "hw.i"
  include    "playfield.i"
  include    "tilemap.i"


;****************************************************************
; MAIN PROGRAM
;****************************************************************
  SECTION    code_section,CODE
main:
  nop
  nop
  jsr        take_system               ; takes the control of Amiga's hardware

  lea        bplpointers,a1            ; address of bitplane pointers in copperlist
  move.l     #dbuffer1,d0              ; address of screen in d0
  move.l     #PF_PLANE_SZ,d1           ; plane size
  move.l     #BPP,d7                   ; number of bitplanes
  jsr        init_bplpointers          ; initializes bitplane pointers to our image

  move.w     map_ptr,d0
  bsr        init_background
  move.w     #TILE_WIDTH,bgnd_x        ; x position of the part of background to draw
    
mainloop:  
  jsr        wait_vblank               ; waits for vertical blank
  jsr        swap_buffers

  jsr        scroll_background

  btst       #6,CIAAPRA                ; left mouse button pressed?
  bne.s      mainloop                  ; if not, repeats the loop

  jsr        release_system            ; releases the hw control to the O.S.
  rts

  END