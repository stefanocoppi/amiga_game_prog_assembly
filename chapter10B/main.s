;****************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 10B - Scrolling Background
;
; optimized version using hardware scrolling.
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
  include    "scroll_bgnd.i"


;****************************************************************
; EXTERNAL REFERENCES
;****************************************************************
  xref       take_system
  xref       release_system
  xref       init_bplpointers
  xref       bplpointers
  xref       screen
  xref       fill_screen_with_tiles
  xref       wait_vblank
  xref       bgnd_surface
  xref       init_background
  xref       map_ptr
  xref       bgnd_x
  xref       scroll_background
          

  
;****************************************************************
; MAIN PROGRAM
;****************************************************************
  SECTION    code_section,CODE
main:
  nop
  nop
  jsr        take_system               ; takes the control of Amiga's hardware

  lea        bplpointers,a1            ; address of bitplane pointers in copperlist
  move.l     #bgnd_surface+8-2,d0      ; address of visible screen buffer
  move.l     #BGND_PLANE_SIZE,d1       ; plane size
  move.l     #BPP,d7                   ; number of bitplanes
  jsr        init_bplpointers          ; initializes bitplane pointers to our image
  
  move.w     map_ptr,d0
  bsr        init_background
  move.w     #TILE_WIDTH,bgnd_x        ; x position of the part of background to draw
    
mainloop:  
  jsr        wait_vblank               ; waits for vertical blank
  
  jsr        scroll_background

  btst       #6,CIAAPRA                ; left mouse button pressed?
  bne.s      mainloop                  ; if not, repeats the loop

  jsr        release_system            ; releases the hw control to the O.S.
  rts

  END