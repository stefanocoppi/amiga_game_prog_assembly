;****************************************************************
; Scrolling background
;
; (c) 2024 Stefano Coppi
;****************************************************************

              incdir     "include/"
              include    "hw.i"
              include    "scroll_bgnd.i"
              include    "playfield.i"
              include    "tilemap.i"

              xref       wait_blitter
              xref       draw_tile_row
              

;****************************************************************
; BSS DATA
;****************************************************************
              SECTION    bss_data,BSS_C
              xdef       bgnd_surface
bgnd_surface  ds.b       (BGND_PLANE_SIZE*BPP)                      ; invisible surface used for scrolling background


;****************************************************************
; VARIABLES
;****************************************************************
              SECTION    code_section,CODE
              xdef       map_ptr
map_ptr       dc.w       TILEMAP_HEIGHT-4                           ; current map row
viewport_y    dc.w       VIEWPORT_HEIGHT+TILE_HEIGHT                ; current y coordinate of viewport into playfield

;****************************************************************
; SUBROUTINES
;****************************************************************


;****************************************************************
; Scrolls the background downwards.
;****************************************************************
              xdef       scroll_background
scroll_background:
              movem.l    d0-a6,-(sp)

              tst.w      map_ptr                                    ; end of map?
              beq        .return                                    ; if yes, returns

; every 64 pixels draws a new map row at at the upper and lower edges of the viewport
              move.w     viewport_y,d0                                
              ext.l      d0
              divu       #64,d0                                     ; viewport_y / 64
              swap       d0
              tst.w      d0                                         ; remainder = 0?
              beq        .draw_new_row                              ; yes, draws new row
              bra        .scroll_viewport

.draw_new_row:
              sub.w      #1,map_ptr

              move.w     map_ptr,d0                                 ; map row
              move.w     viewport_y,d3                              ; y = viewport_y - TILE_HEIGHT
              sub.w      #TILE_HEIGHT,d3 
              lea        bgnd_surface,a1
              bsr        draw_tile_row                              ; draws the row at the top of the viewport

              move.w     viewport_y,d3                              ; y = viewport_y + VIEWPORT_HEIGHT
              add.w      #VIEWPORT_HEIGHT,d3 
              bsr        draw_tile_row                              ; draws the row at the bottom of the viewport

.scroll_viewport:
              sub.w      #1,viewport_y                              ; decreases viewport y, to move it upwards
              tst.w      viewport_y                                 ; viewport_y = 0?
              beq        .reset_viewporty                           ; if yes, resets the viewport y position
              bra        .update_bplpointers
.reset_viewporty:
              move.w     #VIEWPORT_HEIGHT+TILE_HEIGHT,viewport_y
.update_bplpointers:
              move.w     viewport_y,d1
              mulu       #BGND_ROW_SIZE,d1                          ; offset_y = viewport_y * BGND_ROW_SIZE
              ext.l      d1
              move.l     #bgnd_surface,d0
              add.l      d1,d0                                      ; adds offset_y 
              move.l     #BGND_PLANE_SIZE,d1
              bsr        init_bplpointers                           ; updates bitplane pointers

.return       movem.l    (sp)+,d0-a6
              rts




