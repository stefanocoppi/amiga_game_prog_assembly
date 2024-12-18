;****************************************************************
; Tilemap and tileset
;
; (c) 2024 Stefano Coppi
;****************************************************************

           IFND    TILEMAP_I
TILEMAP_I  SET     1


TILE_WIDTH       equ 64
TILE_HEIGHT      equ 64
TILE_PLANE_SZ    equ TILE_HEIGHT*(TILE_WIDTH/8)
TILESET_WIDTH    equ 640
TILESET_HEIGHT   equ 512
TILESET_ROW_SIZE equ (TILESET_WIDTH/8)
TILESET_PLANE_SZ equ (TILESET_HEIGHT*TILESET_ROW_SIZE)
TILESET_COLS     equ 10          
TILEMAP_ROW_SIZE equ 100*2

           ENDC