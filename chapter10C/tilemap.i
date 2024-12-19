;****************************************************************
; Tilemap and tileset
;
; (c) 2024 Stefano Coppi
;****************************************************************

           IFND    TILEMAP_I
TILEMAP_I  SET     1

;****************************************************************
; CONSTANTS
;****************************************************************
TILE_WIDTH       equ 64
TILE_HEIGHT      equ 64
TILE_PLANE_SZ    equ TILE_HEIGHT*(TILE_WIDTH/8)
TILESET_WIDTH    equ 640
TILESET_HEIGHT   equ 192
TILESET_ROW_SIZE equ (TILESET_WIDTH/8)
TILESET_PLANE_SZ equ (TILESET_HEIGHT*TILESET_ROW_SIZE)
TILESET_COLS     equ 10          
TILEMAP_WIDTH    equ 5
TILEMAP_HEIGHT   equ 40
TILEMAP_ROW_SIZE equ TILEMAP_WIDTH*2

           ENDC