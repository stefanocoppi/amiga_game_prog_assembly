;****************************************************************
; Playfield management.
;
; (c) 2024 Stefano Coppi
;****************************************************************

             IFND    PLAYFIELD_I
PLAYFIELD_I  SET     1



;****************************************************************
; CONSTANTS
;****************************************************************

; display
DISPLAY_WIDTH    equ 320
DISPLAY_HEIGHT   equ 256
DISPLAY_PLANE_SZ equ DISPLAY_HEIGHT*(DISPLAY_WIDTH/8)
DISPLAY_ROW_SIZE equ (DISPLAY_WIDTH/8)

BPP              equ 4
WINDOW_WIDTH     equ 336
WINDOW_HEIGHT    equ 192

VIEWPORT_HEIGHT  equ 192
VIEWPORT_WIDTH   equ 320

; playfield 1: scrolling background
;PF1_WIDTH    equ 2*DISPLAY_WIDTH+2*TILE_WIDTH
PF1_WIDTH        equ 2*320+2*64
PF1_HEIGHT       equ 256
PF1_ROW_SIZE     equ PF1_WIDTH/8
PF1_MOD          equ (PF1_WIDTH-VIEWPORT_WIDTH)/8
;PF1_MOD          equ (PF1_WIDTH-320)/8
PF1_PLANE_SZ     equ PF1_ROW_SIZE*PF1_HEIGHT

; playfield2 used for BOBs rendering
PF2_WIDTH        equ VIEWPORT_WIDTH+CLIP_LEFT+CLIP_RIGHT
;PF2_WIDTH        equ 320+96+64

PF2_HEIGHT       equ 256
PF2_ROW_SIZE     equ PF2_WIDTH/8
PF2_MOD          equ (PF2_WIDTH-VIEWPORT_WIDTH)/8
;PF2_MOD          equ (PF2_WIDTH-320)/8
PF2_PLANE_SZ     equ PF2_ROW_SIZE*PF2_HEIGHT
CLIP_LEFT        equ 64+32
CLIP_RIGHT       equ 64

             ENDC  