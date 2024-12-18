;****************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 9 - Tiles and tilemaps
;
; (c) 2024 Stefano Coppi
;****************************************************************

          incdir     "include"
          include    "hw.i"
          include    "playfield.i"
          include    "tilemap.i"


          
          xref       take_system
          xref       release_system
          xref       init_bplpointers
          xref       bplpointers
          xref       screen
          xref       fill_screen_with_tiles
          

          SECTION    code_section,CODE
;****************************************************************
; MAIN PROGRAM
;****************************************************************
main:
          nop
          nop
          jsr        take_system               ; takes the control of Amiga's hardware

          lea        bplpointers,a1            ; address of bitplane pointers in copperlist
          move.l     #screen,d0                ; address of screen in d0
          move.l     #PF_PLANE_SZ,d1           ; plane size
          move.l     #BPP,d7                   ; number of bitplanes
          jsr        init_bplpointers          ; initializes bitplane pointers to our image

          lea        screen,a1                 ; address where draw the tile
          move.w     #11,d0                    ; map column to start drawing from
          jsr        fill_screen_with_tiles
    
mainloop  btst       #6,CIAAPRA                ; left mouse button pressed?
          bne.s      mainloop                  ; if not, repeats the loop

          jsr        release_system            ; releases the hw control to the O.S.
          rts

          END