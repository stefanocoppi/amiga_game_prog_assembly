;****************************************************************
; Playfield management.
;
; (c) 2024 Stefano Coppi
;****************************************************************

             IFND       PLAYFIELD_I
PLAYFIELD_I  SET        1

             include    "tilemaps.i"

;****************************************************************
; CONSTANTS
;****************************************************************


BPP             equ 4
WINDOW_WIDTH    equ 336
WINDOW_HEIGHT   equ 192

VIEWPORT_WIDTH  equ 320
VIEWPORT_HEIGHT equ 192


; playfield 1: scrolling background
PF1_WIDTH       equ 2*VIEWPORT_WIDTH+2*TILE_WIDTH
PF1_HEIGHT      equ 192
PF1_ROW_SIZE    equ PF1_WIDTH/8
PF1_MOD         equ (PF1_WIDTH-VIEWPORT_WIDTH)/8
PF1_PLANE_SZ    equ PF1_ROW_SIZE*PF1_HEIGHT

; playfield2 used for BOBs rendering
PF2_WIDTH       equ VIEWPORT_WIDTH+CLIP_LEFT+CLIP_RIGHT
PF2_HEIGHT      equ 256
PF2_ROW_SIZE    equ PF2_WIDTH/8
PF2_MOD         equ (PF2_WIDTH-VIEWPORT_WIDTH)/8
PF2_PLANE_SZ    equ PF2_ROW_SIZE*PF2_HEIGHT
CLIP_LEFT       equ 64+32
CLIP_RIGHT      equ 64

             ENDC  