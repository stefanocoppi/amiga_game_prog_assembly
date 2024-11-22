;****************************************************************
; Tilemap and tileset
;
; (c) 2024 Stefano Coppi
;****************************************************************

              incdir     "include"
              include    "hw.i"
              include    "tilemaps.i"
              include    "scroll_bgnd.i"
              include    "playfield.i"

; segment loaded in CHIP RAM
              SECTION    graphics_data,DATA_C
         
tileset       incbin     "gfx/shooter_tiles_16.raw"                                                                        ; image 640 x 512 pixel , 8 bitplanes
tileset_mask  incbin     "gfx/shooter_tiles.mask"

              SECTION    code_section,CODE

              xref       wait_blitter,tileset,tileset_mask,ship_coll_plane,map
              xdef       draw_tile_column

;************************************************************************
; Draws a 64x64 pixel tile using Blitter.
;
; parameters:
; d0.w - tile index
; d2.w - x position of the screen where the tile will be drawn (multiple of 16)
; d3.w - y position of the screen where the tile will be drawn
; a1   - address where draw the tile
;************************************************************************
draw_tile:
              movem.l    d0-a6,-(sp)                                                                                       ; saves registers into the stack

; calculates the screen address where to draw the tile
              mulu       #BGND_ROW_SIZE,d3                                                                                 ; y_offset = y * BGND_ROW_SIZE
              lsr.w      #3,d2                                                                                             ; x_offset = x / 8
              ext.l      d2
              add.l      d3,a1                                                                                             ; sums offsets to a1
              add.l      d2,a1

; calculates row and column of tile in tileset starting from index
              ext.l      d0                                                                                                ; extends d0 to a long because the destination operand if divu must be long
              divu       #TILESET_COLS,d0                                                                                  ; tile_index / TILESET_COLS
              swap       d0
              move.w     d0,d1                                                                                             ; the remainder indicates the tile column
              swap       d0                                                                                                ; the quotient indicates the tile row
         
; calculates the x,y coordinates of the tile in the tileset
              lsl.w      #6,d0                                                                                             ; y = row * 64
              lsl.w      #6,d1                                                                                             ; x = column * 64
         
; calculates the offset to add to a0 to get the address of the source image
              mulu       #TILESET_ROW_SIZE,d0                                                                              ; offset_y = y * TILESET_ROW_SIZE
              lsr.w      #3,d1                                                                                             ; offset_x = x / 8
              ext.l      d1

              lea        tileset,a0                                                                                        ; source image address
              add.l      d0,a0                                                                                             ; add y_offset
              add.l      d1,a0                                                                                             ; add x_offset

              moveq      #BPP-1,d7
         
              jsr        wait_blitter
              move.w     #$ffff,BLTAFWM(a5)                                                                                ; don't use mask
              move.w     #$ffff,BLTALWM(a5)
              move.w     #$09f0,BLTCON0(a5)                                                                                ; enable channels A,D
                                                          ; logical function = $f0, D = A
              move.w     #0,BLTCON1(a5)
              move.w     #(TILESET_WIDTH-TILE_WIDTH)/8,BLTAMOD(a5)                                                         ; A channel modulus
              move.w     #(BGND_WIDTH-TILE_WIDTH)/8,BLTDMOD(a5)                                                            ; D channel modulus
.loop:
              jsr        wait_blitter
              move.l     a0,BLTAPT(a5)                                                                                     ; source address
              move.l     a1,BLTDPT(a5)                                                                                     ; destination address
              move.w     #64*64+4,BLTSIZE(a5)                                                                              ; blit size: 64 rows for 4 word
              add.l      #TILESET_PLANE_SZ,a0                                                                              ; advances to the next plane
              add.l      #BGND_PLANE_SIZE,a1
              dbra       d7,.loop
              jsr        wait_blitter

              movem.l    (sp)+,d0-a6                                                                                       ; restore registers from the stack
              rts


;************************************************************************
; Draws the tile mask on the collision plane.
;
; parameters:
; d0.w - tile index
; d2.w - x position of the screen where the tile will be drawn (multiple of 16)
; d3.w - y position of the screen where the tile will be drawn
;************************************************************************
draw_tile_mask:
              movem.l    d0-a6,-(sp)                                                                                       ; saves registers into the stack

; calculates the address where to draw the tile
              lea        ship_coll_plane,a1                                                                                ; destination surface is the collision plane
              mulu       #PF1_ROW_SIZE,d3                                                                                  ; y_offset = y * BGND_ROW_SIZE
              lsr.w      #3,d2                                                                                             ; x_offset = x / 8
              ext.l      d2
              add.l      d3,a1                                                                                             ; sums offsets to a1
              add.l      d2,a1

; calculates row and column of tile in tileset starting from index
              ext.l      d0                                                                                                ; extends d0 to a long because the destination operand if divu must be long
              divu       #TILESET_COLS,d0                                                                                  ; tile_index / TILESET_COLS
              swap       d0
              move.w     d0,d1                                                                                             ; the remainder indicates the tile column
              swap       d0                                                                                                ; the quotient indicates the tile row
         
; calculates the x,y coordinates of the tile in the tileset
              lsl.w      #6,d0                                                                                             ; y = row * 64
              lsl.w      #6,d1                                                                                             ; x = column * 64
         
; calculates the offset to add to a0 to get the address of the source image
              mulu       #TILESET_ROW_SIZE,d0                                                                              ; offset_y = y * TILESET_ROW_SIZE
              lsr.w      #3,d1                                                                                             ; offset_x = x / 8
              ext.l      d1

              lea        tileset_mask,a0                                                                                   ; source is the tileset mask
              add.l      d0,a0                                                                                             ; add y_offset
              add.l      d1,a0                                                                                             ; add x_offset
         
              jsr        wait_blitter
              move.w     #$ffff,BLTAFWM(a5)                                                                                ; don't use mask
              move.w     #$ffff,BLTALWM(a5)
              move.w     #$09f0,BLTCON0(a5)                                                                                ; enable channels A,D
                                                                                          ; logical function = $f0, D = A
              move.w     #0,BLTCON1(a5)
              move.w     #(TILESET_WIDTH-TILE_WIDTH)/8,BLTAMOD(a5)                                                         ; A channel modulus
              move.w     #(BGND_WIDTH-TILE_WIDTH)/8,BLTDMOD(a5)                                                            ; D channel modulus

              jsr        wait_blitter
              move.l     a0,BLTAPT(a5)                                                                                     ; source address
              move.l     a1,BLTDPT(a5)                                                                                     ; destination address
              move.w     #64*64+4,BLTSIZE(a5)                                                                              ; blit size: 64 rows for 4 word
              jsr        wait_blitter

              movem.l    (sp)+,d0-a6                                                                                       ; restore registers from the stack
              rts


;************************************************************************
; Draws a column of 3 tiles.
;
; parameters:
; d0.w - map column
; d2.w - x position (multiple of 16)
; a1   - address where draw the tile
;************************************************************************
draw_tile_column: 
              movem.l    d0-a6,-(sp)
        
; calculates the tilemap address from which to read the tile index
              lea        map,a0
              lsl.w      #1,d0                                                                                             ; offset_x = map_column * 2
              ext.l      d0
              add.l      d0,a0
         
              moveq      #3-1,d7                                                                                           ; number or tilemap rows - 1
              move.w     #0,d3                                                                                             ; y position
.loop:
              move.w     (a0),d0                                                                                           ; tile index
              bsr        draw_tile
              bsr        draw_tile_mask
              add.w      #TILE_HEIGHT,d3                                                                                   ; increment y position
              add.l      #TILEMAP_ROW_SIZE,a0                                                                              ; move to the next row of the tilemap
              dbra       d7,.loop

              movem.l    (sp)+,d0-a6
              rts