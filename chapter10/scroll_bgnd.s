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
; BSS DATA
;****************************************************************
              SECTION    bss_data,BSS_C

bgnd_surface  ds.b       (BGND_PLANE_SIZE*BPP)                                    ; invisible surface used for scrolling background


;****************************************************************
; VARIABLES
;****************************************************************
              SECTION    code_section,CODE
              xdef       map_ptr
map_ptr       dc.w       0                                                        ; current map column
              xdef       bgnd_x
bgnd_x        dc.w       0                                                        ; current x coordinate of camera into background surface


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
              moveq      #5-1,d7                                                  ; number of tile columns - 1 to draw
              lea        bgnd_surface,a1                                          ; address where draw the tile
              move.w     #TILE_WIDTH,d2                                           ; position x
.loop         bsr        draw_tile_column
              add.w      #1,d0                                                    ; increment map column
              add.w      #1,map_ptr
              add.w      #TILE_WIDTH,d2                                           ; increase position x
              dbra       d7,.loop

              sub.w      #1,map_ptr

              movem.l    (sp)+,d0-a6
              rts


;************************************************************************
; Draws the background, copying it from background_surface via Blitter.
;
; parameters:
;
; d0.w - x position of the part of background to draw
; a1   - buffer where to draw
;************************************************************************
draw_background:
              movem.l    d0-a6,-(sp)

              moveq      #BPP-1,d7
              lea        bgnd_surface,a0
; calculates the source image address
              move.w     d0,d2                                                    ; copy of x
              asr.w      #3,d0                                                    ; offset_x = x/8
              and.w      #$fffe,d0                                                ; rounds to even addresses
              ext.l      d0
; calculates the shift value
              add.l      d0,a0                                                    ; address of image to copy
              and.w      #$000f,d2                                                ; selects the first 4 bits, which correspond to the shift
              move.w     #$f,d3                                                   ; since we want a left scroll, 
              sub.w      d2,d3                                                    ; we need to decrement the value of scroll, i.e. $f-scroll
              lsl.w      #8,d3                                                    ; moves the 4 shift bits to the position they occupy in BLTCON0
              lsl.w      #4,d3
              or.w       #$09f0,d3                                                ; inserts the 4 bits into the value to be assigned to BLTCON0
.planeloop:
              jsr        wait_blitter
              move.l     a0,BLTAPT(a5)                                            ; channel A points to background surface
              move.l     a1,BLTDPT(a5)                                            ; channel D points to draw buffer
              move.w     #$ffff,BLTAFWM(a5)                                       ; no first word mask
              move.w     #$0000,BLTALWM(a5)                                       ; masks last word
              move.w     d3,BLTCON0(a5)                                            
              move.w     #0,BLTCON1(a5)
              move.w     #(BGND_WIDTH-VIEWPORT_WIDTH-16)/8,BLTAMOD(a5) 
              move.w     #(WINDOW_WIDTH-VIEWPORT_WIDTH-16)/8,BLTDMOD(a5)
              move.w     #VIEWPORT_HEIGHT<<6+(VIEWPORT_WIDTH/16)+1,BLTSIZE(a5)
              move.l     a0,d0
              add.l      #BGND_PLANE_SIZE,d0                                      ; points a0 to the next plane
              move.l     d0,a0
              move.l     a1,d0
              add.l      #PF_PLANE_SZ,d0                                          ; points a1 to the next plane
              move.l     d0,a1
              dbra       d7,.planeloop

              movem.l    (sp)+,d0-a6
              rts


;************************************************************************
; Scrolls the background to the left.
;************************************************************************
              xdef       scroll_background
scroll_background:
              movem.l    d0-a6,-(sp)

              move.w     bgnd_x,d0                                                ; x position of the part of background to draw
              move.l     draw_buffer,a1                                           ; buffer where to draw                                                  
              bsr        draw_background

              ext.l      d0                                                       ; every TILE_WIDTH (64) pixels draws a new column
              divu       #TILE_WIDTH,d0
              swap       d0
              tst.w      d0                                                       ; remainder of bgnd_x/TILE_WIDTH is zero?
              beq        .draw_new_column
              bra        .check_bgnd_end
.draw_new_column:
              add.w      #1,map_ptr
              cmp.w      #TILEMAP_WIDTH,map_ptr                                   ; end of map?
              bge        .return

              move.w     map_ptr,d0                                               ; map column
              move.w     bgnd_x,d2                                                ; x position = bgnd_x - TILE_WIDTH
              sub.w      #TILE_WIDTH,d2
              lea        bgnd_surface,a1
              bsr        draw_tile_column                                         ; draws the column to the left of the viewport

              move.w     bgnd_x,d2                                                ; x position = bgnd_x + VIEWPORT_WIDTH
              add.w      #VIEWPORT_WIDTH,d2 
              lea        bgnd_surface,a1
              bsr        draw_tile_column                                         ; draws the column to the right of the viewport
.check_bgnd_end:
              cmp.w      #TILE_WIDTH+VIEWPORT_WIDTH,bgnd_x                        ; end of background surface?
              ble        .incr_x
              move.w     #SCROLL_SPEED,bgnd_x                                     ; resets x position of the part of background to draw
              bra        .return
.incr_x       add.w      #SCROLL_SPEED,bgnd_x                                     ; increases x position of the part of background to draw

.return       movem.l    (sp)+,d0-a6
              rts