;************************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 13 - Player's ship
;
;
; (c) 2024 Stefano Coppi
;************************************************************************

  incdir     "include"
  include    "hw.i"
  include    "playfield.i"
  include    "tilemaps.i"

  

  xref       take_system,release_system
  xref       wait_vblank
  xref       copperlist
  xref       bplpointers1
  xref       bplpointers2
  xref       playfield1
  xref       playfield2a
  xref       init_bplpointers
  xref       init_background
  xref       map_ptr
  xref       camera_x
  xref       bgnd_x
  xref       plship_init
  xref       scroll_background
  xref       plship_update
  xref       plship_draw
  xref       swap_buffers
  xref       erase_bgnds
           
;************************************************************************
; MAIN PROGRAM
;************************************************************************
  SECTION    code_section,CODE

main:
  jsr        take_system                   ; takes the control of Amiga's hardware

  move.l     #copperlist,COP1LC(a5)        ; sets our copperlist address into Copper
  move.w     d0,COPJMP1(a5)                ; reset Copper PC to the beginning of our copperlist
  
; sets bitplane pointers for dual playfield mode            
  move.l     #BPP,d7  
  lea        bplpointers1,a1               ; bitplane pointers in a1
  move.l     #playfield1+8-2,d0            ; address of background playfield
  move.l     #PF1_PLANE_SZ,d1 
  jsr        init_bplpointers              ; initializes bitplane pointers for background playfield

  lea        bplpointers2,a1               ; bitplane pointers in a1
  move.l     #playfield2a,d0               ; address of foreground playfield
  move.l     #PF2_PLANE_SZ,d1 
  jsr        init_bplpointers              ; initializes bitplane pointers for foreground playfield

; initializes scrolling background state
  move.w     #0,map_ptr
  move.w     #0*64,camera_x
  move.w     map_ptr,d0
  jsr        init_background
  move.w     #TILE_WIDTH,bgnd_x            ; x position of the part of background to draw

; initializes player's ship state
  jsr        plship_init

mainloop: 
  jsr        wait_vblank                   ; waits for vertical blank
  jsr        swap_buffers                  ; swaps draw and view buffers for implementing double buffering

  jsr        scroll_background             ; scrolls tilemap toward left

  jsr        plship_update                 ; updates player's ship state

  jsr        erase_bgnds                   ; erases bobs backgrounds

  jsr        plship_draw                   ; draws player's ship
  
  btst       #6,CIAAPRA                    ; left mouse button pressed?
  bne        mainloop                      ; if not, repeats the loop

  jsr        release_system                ; releases the hw control to the O.S.
  rts

  END