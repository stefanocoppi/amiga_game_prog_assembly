;****************************************************************
; Game over state
;
; (c) 2024 Stefano Coppi
;****************************************************************

                include    "game_state.i"
                include    "playfield.i"
                include    "bob.i"
                include    "sound.i"

;****************************************************************
; CONSTANTS
;****************************************************************
FLASH_DURATION equ 6
STATE_DURATION equ 50*6                                       ; 6 seconds

;****************************************************************
; GRAPHICS DATA in chip ram
;****************************************************************
                SECTION    graphics_data,DATA_C
gameover_gfx    incbin     "gfx/game_over.raw"
gameover_mask   incbin     "gfx/game_over.mask"


;****************************************************************
; VARIABLES
;****************************************************************
                SECTION    code_section,CODE

gameover_text   dc.w       CLIP_LEFT+70                       ; x position
                dc.w       90                                 ; y position
                dc.w       1                                  ; speed
                dc.w       176                                ; width
                dc.w       22                                 ; height  
                dc.w       0                                  ; spritesheet column of the bob
                dc.w       0                                  ; spritesheet row of the bob
                dc.w       176                                ; spritesheet width in pixels
                dc.w       44                                 ; spritesheet height in pixels
                dc.l       gameover_gfx                       ; image data address
                dc.l       gameover_mask 

flash_timer     dc.w       0
gameover_timer  dc.w       0                                  ; measures the permanence in this state


;****************************************************************
; SUBROUTINES
;****************************************************************


;****************************************************************
; Initializes the GAMEOVER game state.
;****************************************************************
                xdef       init_gameover_state
init_gameover_state:
                movem.l    d0-a6,-(sp)

                move.w     #STATE_DURATION,gameover_timer
                move.w     #FLASH_DURATION,flash_timer
                lea        gameover_text,a0
                move.w     #0,bob.ssheet_r(a0)

; changes the game state to GAMEOVER
                move.w     #GAME_STATE_GAMEOVER,game_state

; plays sound fx
                move.w     #SFX_ID_GAMEOVER,d0
                clr.w      d1                                 ; no loop
                ;jsr        play_sfx
                jsr        play_sample
                

                movem.l    (sp)+,d0-a6
                rts


;****************************************************************
; Updates the GAMEOVER game state.
;****************************************************************
                xdef       update_gameover_state
update_gameover_state:
                movem.l    d0-a6,-(sp)

                jsr        swap_buffers                       ; swaps draw and view buffers for implementing double buffering

                jsr        scroll_background                  ; scrolls tilemap toward left

                jsr        plship_update                      ; updates player's ship state
                jsr        ship_fire_shot                     ; fires shots from player's ship
                jsr        ship_shots_update                  ; updates player's ship shots state
                jsr        enemy_shots_update                 ; updates enemy shots state
    
                jsr        enemies_activate                   ; activates enemies based on their position on the map 
                jsr        enemies_update                     ; updates enemies state

                jsr        check_coll_shots_enemies           ; checks collisions between player's shots and enemies
                jsr        check_coll_shots_plship            ; checks collisions between enemy shots and player's ship
                jsr        check_coll_enemy_plship            ; checks collisions between enemy and player's ship
                jsr        check_coll_plship_map              ; checks collisions between player's ship and tilemap
    
                jsr        erase_bgnds                        ; erases bobs backgrounds
                    
                jsr        enemies_draw                       ; draws enemies
                jsr        plship_draw                        ; draws player's ship
                jsr        ship_shots_draw                    ; draws player's ship shots
                jsr        enemy_shots_draw                   ; draws enemy shots

                jsr        update_gameover_text
                jsr        draw_gameover_text

                movem.l    (sp)+,d0-a6
                rts


;****************************************************************
; Draws the gameover text.
;****************************************************************
draw_gameover_text:
                movem.l    d0-a6,-(sp)

                lea        gameover_text,a3       
                move.l     draw_buffer,a2
                bsr        draw_bob

.return:
                movem.l    (sp)+,d0-a6
                rts


;****************************************************************
; Updates the gameover text, making it flash.
;****************************************************************
update_gameover_text:
                movem.l    d0-a6,-(sp)     
               
                sub.w      #1,gameover_timer
                beq        .change_state
                bra        .decr_flash_timer
.change_state:
                move.w     #GAME_STATE_TITLESCREEN,d0
                jsr        change_gamestate
.decr_flash_timer:
                sub.w      #1,flash_timer
                beq        .change_frame
                bra        .return

.change_frame:
                move.w     #FLASH_DURATION,flash_timer
                lea        gameover_text,a0
                add.w      #1,bob.ssheet_r(a0)
                cmp.w      #2,bob.ssheet_r(a0)
                bge        .reset_animation
                bra        .return
.reset_animation:
                clr.w      bob.ssheet_r(a0)       

.return:
                movem.l    (sp)+,d0-a6
                rts