;****************************************************************
; Module containing all graphics data
;
; (c) 2024 Stefano Coppi
;****************************************************************

; segment loaded in CHIP RAM
                      SECTION    graphics_data,DATA_C
         
                      xdef       ship_explosion_gfx,ship_explosion_mask
                      xdef       enemy_explosion_gfx,enemy_explosion_mask


ship_explosion_gfx    incbin     "gfx/ship_explosion.raw"
ship_explosion_mask   incbin     "gfx/ship_explosion.mask"

enemy_explosion_gfx   incbin     "gfx/enemy_explosion.raw"
enemy_explosion_mask  incbin     "gfx/enemy_explosion.mask"