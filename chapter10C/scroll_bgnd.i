;****************************************************************
; Scrolling background
;
; (c) 2024 Stefano Coppi
;****************************************************************

               IFND       SCROLL_BGND_I
SCROLL_BGND_I  SET        1

               include    "playfield.i"
               include    "tilemap.i"

;****************************************************************
; CONSTANTS
;****************************************************************
BGND_WIDTH      equ 320
BGND_HEIGHT     equ 2*VIEWPORT_HEIGHT+2*TILE_HEIGHT
BGND_PLANE_SIZE equ BGND_HEIGHT*(BGND_WIDTH/8)
BGND_ROW_SIZE   equ (BGND_WIDTH/8)

VIEWPORT_HEIGHT equ 256
VIEWPORT_WIDTH  equ 320

SCROLL_SPEED    equ 1

               ENDC