;****************************************************************
; Tilemap and tileset
;
; (c) 2024 Stefano Coppi
;****************************************************************
         incdir     "include"
         include    "hw.i"
         include    "playfield.i"
         include    "tilemap.i"
         include    "scroll_bgnd.i"

         xref       wait_blitter
         xref       map


;************************************************************************
; Graphics data
;************************************************************************
; segment loaded in CHIP RAM
         SECTION    graphics_data,DATA_C

tileset  incbin     "gfx/vshooter_tiles.raw"                     ; image 640 x 512 pixel , 4 bitplanes


;************************************************************************
; SUBROUTINES
;************************************************************************
         SECTION    code_section,CODE


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
         movem.l    d0-a6,-(sp)                                  ; saves registers into the stack

; calculates the screen address where to draw the tile
         mulu       #BGND_ROW_SIZE,d3                            ; y_offset = y * BGND_ROW_SIZE
         lsr.w      #3,d2                                        ; x_offset = x / 8
         ext.l      d2
         add.l      d3,a1                                        ; sums offsets to a1
         add.l      d2,a1

; calculates row and column of tile in tileset starting from index
         ext.l      d0                                           ; extends d0 to a long because the destination operand if divu must be long
         divu       #TILESET_COLS,d0                             ; tile_index / TILESET_COLS
         swap       d0
         move.w     d0,d1                                        ; the remainder indicates the tile column
         swap       d0                                           ; the quotient indicates the tile row
         
; calculates the x,y coordinates of the tile in the tileset
         lsl.w      #6,d0                                        ; y = row * 64
         lsl.w      #6,d1                                        ; x = column * 64
         
; calculates the offset to add to a0 to get the address of the source image
         mulu       #TILESET_ROW_SIZE,d0                         ; offset_y = y * TILESET_ROW_SIZE
         lsr.w      #3,d1                                        ; offset_x = x / 8
         ext.l      d1

         lea        tileset,a0                                   ; source image address
         add.l      d0,a0                                        ; add y_offset
         add.l      d1,a0                                        ; add x_offset

         moveq      #BPP-1,d7
         
         bsr        wait_blitter
         move.w     #$ffff,BLTAFWM(a5)                           ; don't use mask
         move.w     #$ffff,BLTALWM(a5)
         move.w     #$09f0,BLTCON0(a5)                           ; enable channels A,D
                                                                 ; logical function = $f0, D = A
         move.w     #0,BLTCON1(a5)
         move.w     #(TILESET_WIDTH-TILE_WIDTH)/8,BLTAMOD(a5)    ; A channel modulus
         move.w     #(BGND_WIDTH-TILE_WIDTH)/8,BLTDMOD(a5)       ; D channel modulus
.loop:
         bsr        wait_blitter
         move.l     a0,BLTAPT(a5)                                ; source address
         move.l     a1,BLTDPT(a5)                                ; destination address
         move.w     #64*64+4,BLTSIZE(a5)                         ; blit size: 64 rows for 4 word
         add.l      #TILESET_PLANE_SZ,a0                         ; advances to the next plane
         add.l      #BGND_PLANE_SIZE,a1
         dbra       d7,.loop
         bsr        wait_blitter

         movem.l    (sp)+,d0-a6                                  ; restore registers from the stack
         rts


;************************************************************************
; Draws a row of 5 tiles.
;
; parameters:
; d0.w - map row
; d3.w - y position
; a1   - address where draw the tile
;************************************************************************
         xdef       draw_tile_row
draw_tile_row: 
         movem.l    d0-a6,-(sp)
        
; calculates the tilemap address from which to read the tile index
         lea        map,a0
         mulu       #TILEMAP_ROW_SIZE,d0                         ; offset_y = map_row * TILEMAP_ROW_SIZE
         ext.l      d0
         add.l      d0,a0
         
         moveq      #TILEMAP_WIDTH-1,d7                          ; number or tilemap column - 1
         move.w     #0,d2                                        ; x position
.loop:
         move.w     (a0),d0                                      ; tile index
         bsr        draw_tile
         add.w      #TILE_WIDTH,d2                               ; increment x position
         add.l      #2,a0                                        ; move to the next column of the tilemap
         dbra       d7,.loop

         movem.l    (sp)+,d0-a6
         rts


;************************************************************************
; Initializes the background, copying the initial part of the level map.
;
; parameters:
; d0.w - map row from which to start drawing tiles
;************************************************************************
         xdef       init_background
init_background:
         movem.l    d0-a6,-(sp)

; initializes the part that will be visible in the viewport
         moveq      #4-1,d7                                      ; number of tile rows - 1 to draw
         lea        bgnd_surface,a1                              ; address where draw the tile
         move.w     #(256+64),d3                                 ; position y
.loop    bsr        draw_tile_row
         add.w      #1,d0                                        ; increment map row
         add.w      #1,map_ptr
         add.w      #TILE_HEIGHT,d3                              ; increase position y
         dbra       d7,.loop

         move.w     #TILEMAP_HEIGHT-4,map_ptr

         movem.l    (sp)+,d0-a6
         rts




