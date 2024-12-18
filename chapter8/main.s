;****************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 8 - Blitter
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
          xref       draw_tile
          xref       img_tile



          SECTION    code_section,CODE

;****************************************************************
; MAIN PROGRAM
;****************************************************************
main:
          nop
          nop
          jsr        take_system                          ; takes the control of Amiga's hardware

          lea        bplpointers,a1                       ; address of bitplane pointers in copperlist
          move.l     #screen,d0                           ; address of screen in d0
          move.l     #PF_PLANE_SZ,d1                      ; plane size
          move.l     #BPP,d7                              ; number of bitplanes
          jsr        init_bplpointers                     ; initializes bitplane pointers to our image

          lea        img_tile,a0
          move.w     #(WINDOW_WIDTH-TILE_WIDTH)/2,d0      ; x position
          move.w     #(WINDOW_HEIGHT-TILE_HEIGHT)/2,d1    ; y position
          mulu       #PF_ROW_SIZE,d1                      ; y_offset = y * PF_ROW_SIZE
          asr.w      #3,d0                                ; x_offset = x/8
          add.w      d1,d0                                ; sum the offsets
          ext.l      d0
          lea        screen,a1
          add.l      d0,a1                                ; sum the offset to a1
          bsr        draw_tile
    
mainloop  btst       #6,CIAAPRA                           ; left mouse button pressed?
          bne.s      mainloop                             ; if not, repeats the loop

          jsr        release_system                       ; releases the hw control to the O.S.
          rts

          END