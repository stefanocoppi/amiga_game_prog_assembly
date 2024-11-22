;****************************************************************
; Module containing all graphics data
;
; (c) 2024 Stefano Coppi
;****************************************************************

; segment loaded in CHIP RAM
                      SECTION    graphics_data,DATA_C
         

                      xdef       player_ship_gfx,player_ship_mask,ship_engine_gfx,ship_engine_mask
                      xdef       ship_shots_gfx,ship_shots_mask,ship_explosion_gfx,ship_explosion_mask,enemies_gfx,enemies_mask
                      xdef       enemy_shots_gfx,enemy_shots_mask,enemy_explosion_gfx,enemy_explosion_mask

player_ship_gfx       incbin     "gfx/ship.raw"
player_ship_mask      incbin     "gfx/ship.mask"

ship_engine_gfx       incbin     "gfx/ship_engine.raw"
ship_engine_mask      incbin     "gfx/ship_engine.mask"

ship_shots_gfx        incbin     "gfx/ship_shots.raw"
ship_shots_mask       incbin     "gfx/ship_shots.mask"

ship_explosion_gfx    incbin     "gfx/ship_explosion.raw"
ship_explosion_mask   incbin     "gfx/ship_explosion.mask"

enemies_gfx           incbin     "gfx/enemies.raw"
enemies_mask          incbin     "gfx/enemies.mask"

enemy_shots_gfx       incbin     "gfx/enemy_shots.raw"
enemy_shots_mask      incbin     "gfx/enemy_shots.mask"

enemy_explosion_gfx   incbin     "gfx/enemy_explosion.raw"
enemy_explosion_mask  incbin     "gfx/enemy_explosion.mask"