;****************************************************************
; Tilemap and tileset
;
; (c) 2024 Stefano Coppi
;****************************************************************

           IFND    TILEMAP_I
TILEMAP_I  SET     1


TILE_WIDTH    equ 64
TILE_HEIGHT   equ 64
TILE_PLANE_SZ equ TILE_HEIGHT*(TILE_WIDTH/8)

           ENDC