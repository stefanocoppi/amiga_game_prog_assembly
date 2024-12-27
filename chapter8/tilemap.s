;****************************************************************
; Tilemap and tileset
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
; GLOBAL SYMBOLS
;****************************************************************
          xdef       img_tile
          xdef       draw_tile


;****************************************************************
; EXTERNAL REFERENCES
;****************************************************************
          xref       wait_blitter


;****************************************************************
; Graphics data
;****************************************************************
; segment loaded in CHIP RAM
          SECTION    graphics_data,DATA_C
img_tile  incbin     "gfx/tile.raw"                              ; image 64 x 64 pixel , 3 bitplanes


;****************************************************************
; SUBROUTINES
;****************************************************************
          SECTION    code_section,CODE

;****************************************************************
; Draw a 64x64 pixel tile using blitter
;
; parameters:
; a0 - address of tile
; a1 - address where draw the tile
;****************************************************************
draw_tile:
          movem.l    d0-a6,-(sp)                                 ; saves registers into the stack

          moveq      #BPP-1,d1
          bsr        wait_blitter
          move.w     #$ffff,BLTAFWM(a5)                          ; don't use mask
          move.w     #$ffff,BLTALWM(a5)
          move.w     #$09f0,BLTCON0(a5)                          ; enable channels A,D
                                                                     ; logical function = $f0, D = A
          move.w     #0,BLTCON1(a5)
          move.w     #0,BLTAMOD(a5)
             
          move.w     #(WINDOW_WIDTH-TILE_WIDTH)/8,BLTDMOD(a5)    ; D channel modulus
.loop:
          bsr        wait_blitter
          move.l     a0,BLTAPT(a5)                               ; source address
          move.l     a1,BLTDPT(a5)                               ; destination address
          move.w     #64*64+4,BLTSIZE(a5)                        ; blit size: 64 rows for 4 words
          add.l      #TILE_PLANE_SZ,a0                           ; advances to the next plane
          add.l      #PF_PLANE_SZ,a1
          dbra       d1,.loop
          bsr        wait_blitter

          movem.l    (sp)+,d0-a6                                 ; restores registers values from the stack
          rts