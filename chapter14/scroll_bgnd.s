;************************************************************************
; Scrolling background
;
; (c) 2024 Stefano Coppi
;************************************************************************
            include    "playfield.i"
            include    "tilemaps.i"
            include    "scroll_bgnd.i"

            xref       draw_tile_column,scrollx
            xref       bplpointers1

            xdef       init_background
            xref       scroll_background
            xdef       playfield1,camera_x
            xdef       map_ptr,bgnd_x
            xdef       camera_x


;************************************************************************
; BSS DATA
;************************************************************************
            SECTION    bss_data,BSS_C

playfield1  ds.b       (PF1_PLANE_SZ*BPP)                   ; used for scrolling background


;************************************************************************
; VARIABLES
;************************************************************************
            SECTION    code_section,CODE

camera_x    dc.w       0*64                                 ; x position of camera
map_ptr     dc.w       0                                    ; current map column
bgnd_x      dc.w       0    


;************************************************************************
; Initializes the background, copying the initial part of the level map.
;
; parameters:
; d0.w - map column from which to start drawing tiles
;************************************************************************
init_background:
            movem.l    d0-a6,-(sp)

; initializes the part that will be visible in the display window
            moveq      #5-1,d7                              ; number of tile columns - 1 to draw
            lea        playfield1,a1                        ; address where draw the tile
            move.w     #TILE_WIDTH,d2                       ; position x
.loop       jsr        draw_tile_column
            add.w      #1,d0                                ; increment map column
            add.w      #1,map_ptr
            add.w      #TILE_WIDTH,d2                       ; increase position x
            dbra       d7,.loop

            sub.w      #1,map_ptr
; ; draws the column to the left of the display window
;               add.w      #1,d0                                        ; map column
;               add.w      #1,map_ptr
;               move.w     #0,d2                                        ; x position
;               lea        playfield1,a1
;               jsr draw_tile_column

; ; draws the column to the right of the display window
;               move.w     #VIEWPORT_WIDTH+TILE_WIDTH,d2                 ; x position
;               lea        playfield1,a1
;               jsr draw_tile_column

            movem.l    (sp)+,d0-a6
            rts


;************************************************************************
; Scrolls the background to the left.
;************************************************************************
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
            lea        playfield1,a1
            jsr        draw_tile_column                     ; draws the column to the left of the viewport

            move.w     bgnd_x,d2                            ; x position = bgnd_x + VIEWPORT_WIDTH
            add.w      #VIEWPORT_WIDTH,d2 
            lea        playfield1,a1
            jsr        draw_tile_column                     ; draws the column to the right of the viewport
              
.set_scroll:
            move.w     bgnd_x,d0
            and.w      #$000f,d0                            ; selects the first 4 bits, which correspond to the shift
            move.w     #$f,d1                               ; since we want a left scroll, 
            sub.w      d0,d1                                ; we need to decrement the value of scroll, i.e. $f-scroll
            move.w     d1,scrollx                           ; sets the BPLCON1 value for scrolling

            tst.w      d1                                   ; scroll = 0?
            beq        .update_bplptr                       ; yes, update bitplane pointers
            bra        .check_bgnd_end
.update_bplptr:
            move.w     bgnd_x,d1 
            asr.w      #3,d1                                ; offset_x = bgnd_x/8
            and.w      #$fffe,d1                            ; rounds to even addresses
            ext.l      d1                                   ; extends to long
            lea        bplpointers1,a1
            move.l     #playfield1,d0
            add.l      d1,d0                                ; adds offset_x
            move.l     #PF1_PLANE_SZ,d1
            move.l     #BPP,d7
            jsr        init_bplpointers
            move.w     #$000f,scrollx                       ; resets scroll value

.check_bgnd_end:
            cmp.w      #TILE_WIDTH+VIEWPORT_WIDTH,bgnd_x    ; end of background surface?
            ble        .incr_x
            move.w     #0,bgnd_x                            ; resets x position of the part of background to draw
            lea        bplpointers1,a1
            move.l     #playfield1-2,d0
            move.l     #PF1_PLANE_SZ,d1
            move.l     #BPP,d7
            jsr        init_bplpointers
            move.w     #$000f,scrollx                       ; resets scroll value
            bra        .return
.incr_x:       
            add.w      #SCROLL_SPEED,bgnd_x                 ; increases x position of the part of background to draw
            add.w      #SCROLL_SPEED,camera_x
.return     movem.l    (sp)+,d0-a6
            rts