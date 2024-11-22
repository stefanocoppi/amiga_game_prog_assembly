;****************************************************************
; Scrolling background
;
; (c) 2024 Stefano Coppi
;****************************************************************

               IFND       SCROLL_BGND_I
SCROLL_BGND_I  SET        1

               include    "playfield.i"
               include    "tilemaps.i"

;****************************************************************
; CONSTANTS
;****************************************************************

BGND_WIDTH      equ 2*DISPLAY_WIDTH+2*TILE_WIDTH
BGND_HEIGHT     equ 256
BGND_PLANE_SIZE equ BGND_HEIGHT*(BGND_WIDTH/8)
BGND_ROW_SIZE   equ (BGND_WIDTH/8)
SCROLL_SPEED    equ 1

               ENDC