;****************************************************************
; Scrolling background
;
; (c) 2024 Stefano Coppi
;****************************************************************


;****************************************************************
; INCLUDES
;****************************************************************
              incdir     "include/"
              include    "hw.i"
              include    "scroll_bgnd.i"
              include    "playfield.i"
              include    "tilemap.i"


;****************************************************************
; EXTERNAL REFERENCES
;****************************************************************
              xref       wait_blitter
              xref       draw_tile_column
              xref       scrollx


;****************************************************************
; BSS DATA
;****************************************************************
              SECTION    bss_data,BSS_C

              xdef       bgnd_surface
bgnd_surface  ds.b       (BGND_PLANE_SIZE*BPP)                ; invisible surface used for scrolling background


;****************************************************************
; VARIABLES
;****************************************************************
              SECTION    code_section,CODE

              xdef       map_ptr
map_ptr       dc.w       0                                    ; current map column
              xdef       bgnd_x
bgnd_x        dc.w       0                                    ; current x coordinate of camera into background surface


;****************************************************************
; SUBROUTINES
;****************************************************************


;****************************************************************
; Initializes the background, copying the initial part of the level map.
;
; parameters:
; d0.w - map column from which to start drawing tiles
;****************************************************************
              xdef       init_background
init_background:
              movem.l    d0-a6,-(sp)

; initializes the part that will be visible in the display window
              moveq      #5-1,d7                              ; number of tile columns - 1 to draw
              lea        bgnd_surface,a1                      ; address where draw the tile
              move.w     #TILE_WIDTH,d2                       ; position x
.loop         bsr        draw_tile_column
              add.w      #1,d0                                ; increment map column
              add.w      #1,map_ptr
              add.w      #TILE_WIDTH,d2                       ; increase position x
              dbra       d7,.loop

              sub.w      #1,map_ptr

              movem.l    (sp)+,d0-a6
              rts


;************************************************************************
; Scrolls the background to the left.
;************************************************************************
              xdef       scroll_background
scroll_background:
              movem.l    d0-a6,-(sp)

              move.w     bgnd_x,d0                            ; x position of the part of background to draw
              tst.w      d0
              beq        .set_scroll
              ext.l      d0                                   ; every 64 pixels draws a new column
              divu       #TILE_WIDTH,d0
              swap       d0
              tst.w      d0                                   ; remainder of bgnd_x/TILE_WIDTH is zero?
              beq        .draw_new_column                     ; if yes, draws new tile columns at the sides of viewport
              bra        .set_scroll
.draw_new_column:
              add.w      #1,map_ptr
              cmp.w      #TILEMAP_WIDTH,map_ptr               ; end of map?
              bge        .return

              move.w     map_ptr,d0                           ; map column
              move.w     bgnd_x,d2                            ; x position = bgnd_x - TILE_WIDTH
              sub.w      #TILE_WIDTH,d2
              lea        bgnd_surface,a1
              bsr        draw_tile_column                     ; draws the column to the left of the viewport

              move.w     bgnd_x,d2                            ; x position = bgnd_x + VIEWPORT_WIDTH
              add.w      #VIEWPORT_WIDTH,d2 
              lea        bgnd_surface,a1
              bsr        draw_tile_column                     ; draws the column to the right of the viewport
              
.set_scroll:
              move.w     bgnd_x,d0
              and.w      #$000f,d0                            ; selects the first 4 bits, which correspond to the shift
              move.w     #$f,d1                               ; since we want a left scroll, 
              sub.w      d0,d1                                ; we need to decrement the value of scroll, i.e. $f-scroll
              move.w     d1,d2                                ; copy
              move.w     d1,d0                                ; copy
              lsl.w      #4,d0
              or.w       d0,d1                                ; value of bits 0-3 and 4-7 of BPLCON1
              move.w     d1,scrollx                           ; sets the BPLCON1 value for scrolling

              tst.w      d2                                   ; scroll = 0?
              beq        .update_bplptr                       ; yes, update bitplane pointers
              bra        .check_bgnd_end
.update_bplptr:
              move.w     bgnd_x,d1 
              asr.w      #3,d1                                ; offset_x = bgnd_x/8
              and.w      #$fffe,d1                            ; rounds to even addresses
              ext.l      d1                                   ; extends to long
              move.l     #bgnd_surface,d0
              add.l      d1,d0                                ; adds offset_x
              move.l     #BGND_PLANE_SIZE,d1
              bsr        init_bplpointers
              move.w     #$00ff,scrollx                       ; resets scroll value

.check_bgnd_end:
              cmp.w      #TILE_WIDTH+VIEWPORT_WIDTH,bgnd_x    ; end of background surface?
              ble        .incr_x
              move.w     #0,bgnd_x                            ; resets x position of the part of background to draw
              move.l     #bgnd_surface-2,d0
              move.l     #BGND_PLANE_SIZE,d1
              bsr        init_bplpointers
              move.w     #$00ff,scrollx                       ; resets scroll value
              bra        .return
.incr_x:       
              add.w      #1,bgnd_x                            ; increases x position of the part of background to draw

.return       movem.l    (sp)+,d0-a6
              rts