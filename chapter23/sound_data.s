;****************************************************************
; Sound data
;
; (c) 2024 Stefano Coppi
;****************************************************************

                  xdef       sfx_table
                  xdef       title_music


;****************************************************************
; SOUND EFFECTS
;****************************************************************
                  SECTION    sounds,DATA_C

sfx_start         dc.w       0                             ; the first two bytes of sfx must be zero for using ptplayer lib
                  incbin     "sfx/sfx_start.raw"
                  even
sfx_start_len        equ (*-sfx_start)/2

sfx_base_fire     dc.w       0 
                  incbin     "sfx/sfx_base_fire.raw"
                  even
sfx_base_fire_len    equ (*-sfx_base_fire)/2

sfx_rlaser        dc.w       0 
                  incbin     "sfx/sfx_rlaser.raw"
                  even
sfx_rlaser_len       equ (*-sfx_rlaser)/2

sfx_aalaser       dc.w       0 
                  incbin     "sfx/sfx_aalaser.raw"
                  even
sfx_aalaser_len      equ (*-sfx_aalaser)/2

sfx_beam_fire     dc.w       0 
                  incbin     "sfx/sfx_beam_fire.raw"
                  even
sfx_beam_fire_len    equ (*-sfx_beam_fire)/2

sfx_explosion     dc.w       0 
                  incbin     "sfx/sfx_explosion.raw"
                  even
sfx_explosion_len    equ (*-sfx_explosion)/2

sfx_hit           dc.w       0 
                  incbin     "sfx/sfx_hit.raw"
                  even
sfx_hit_len          equ (*-sfx_hit)/2

sfx_powerup       dc.w       0 
                  incbin     "sfx/sfx_powerup.raw"
                  even
sfx_powerup_len      equ (*-sfx_powerup)/2

sfx_game_over     dc.w       0 
                  incbin     "sfx/sfx_game_over2.raw"
                  even
sfx_game_over_len    equ (*-sfx_game_over)/2

sfx_level1_music  dc.w       0 
                  incbin     "sfx/sfx_level1_music.raw"
                  even
sfx_level1_music_len equ (*-sfx_level1_music)/2

sfx_title_music   dc.w       0 
                  incbin     "sfx/sfx_title_music.raw"
                  even
sfx_title_music_len  equ (*-sfx_title_music)/2

title_music       incbin     "sfx/xenon2.mod"
                  even

                  include    "sound.i"

                  SECTION    sounds,CODE

; sound effects table
sfx_table:
                  ; 0 - start
                  dc.l       sfx_start                     ; samples pointer
                  dc.w       sfx_start_len                 ; samples length (bytes)
                  dc.w       SFX_PERIOD                    ; period
                  dc.w       SFX_VOLUME                    ; volume
                  dc.b       -1                            ; channel
                  dc.b       SFX_PRI_START                 ; priority

                  ; 1 - base_fire
                  dc.l       sfx_base_fire                 ; samples pointer
                  dc.w       sfx_base_fire_len             ; samples length (bytes)
                  dc.w       SFX_PERIOD                    ; period
                  dc.w       SFX_VOLUME                    ; volume
                  dc.b       -1                            ; channel
                  dc.b       SFX_PRI_BULLET                ; priority

                    ; 2 - rlaser
                  dc.l       sfx_rlaser                    ; samples pointer
                  dc.w       sfx_rlaser_len                ; samples length (bytes)
                  dc.w       SFX_PERIOD                    ; period
                  dc.w       SFX_VOLUME                    ; volume
                  dc.b       -1                            ; channel
                  dc.b       SFX_PRI_BULLET                ; priority

                    ; 3 - aalaser
                  dc.l       sfx_aalaser                   ; samples pointer
                  dc.w       sfx_aalaser_len               ; samples length (bytes)
                  dc.w       SFX_PERIOD                    ; period
                  dc.w       SFX_VOLUME                    ; volume
                  dc.b       -1                            ; channel
                  dc.b       SFX_PRI_BULLET                ; priority

                    ; 4 - beam_fire
                  dc.l       sfx_beam_fire                 ; samples pointer
                  dc.w       sfx_beam_fire_len             ; samples length (bytes)
                  dc.w       SFX_PERIOD                    ; period
                  dc.w       SFX_VOLUME                    ; volume
                  dc.b       -1                            ; channel
                  dc.b       SFX_PRI_BULLET                ; priority

                    ; 5 - explosion
                  dc.l       sfx_explosion                 ; samples pointer
                  dc.w       sfx_explosion_len             ; samples length (bytes)
                  dc.w       SFX_PERIOD                    ; period
                  dc.w       SFX_VOLUME                    ; volume
                  dc.b       -1                            ; channel
                  dc.b       SFX_PRI_EXPLOSION             ; priority

                    ; 6 - hit
                  dc.l       sfx_hit                       ; samples pointer
                  dc.w       sfx_hit_len                   ; samples length (bytes)
                  dc.w       SFX_PERIOD                    ; period
                  dc.w       SFX_VOLUME                    ; volume
                  dc.b       -1                            ; channel
                  dc.b       SFX_PRI_EXPLOSION             ; priority

                    ; 7 - powerup
                  dc.l       sfx_powerup                   ; samples pointer
                  dc.w       sfx_powerup_len               ; samples length (bytes)
                  dc.w       SFX_PERIOD                    ; period
                  dc.w       SFX_VOLUME                    ; volume
                  dc.b       -1                            ; channel
                  dc.b       SFX_PRI_POWERUP               ; priority

                    ; 8 - game_over
                  dc.l       sfx_game_over                 ; samples pointer
                  dc.w       sfx_game_over_len             ; samples length (bytes)
                  dc.w       SFX_PERIOD                    ; period
                  dc.w       SFX_VOLUME                    ; volume
                  dc.b       -1                            ; channel
                  dc.b       SFX_PRI_GAMEOVER              ; priority

                    ; 9 - level music
                  dc.l       sfx_level1_music              ; samples pointer
                  dc.w       sfx_level1_music_len          ; samples length (bytes)
                  dc.w       SFX_PERIOD                    ; period
                  dc.w       48                            ; volume
                  dc.b       0                             ; channel
                  dc.b       SFX_PRI_GAMEOVER              ; priority

                    ; 10 - title music
                  dc.l       sfx_title_music               ; samples pointer
                  dc.w       sfx_title_music_len           ; samples length (bytes)
                  dc.w       SFX_PERIOD                    ; period
                  dc.w       64                            ; volume
                  dc.b       0                             ; channel
                  dc.b       SFX_PRI_GAMEOVER              ; priority