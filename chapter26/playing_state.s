;****************************************************************
; Playing state: the player plays the game.
;
; (c) 2024 Stefano Coppi
;****************************************************************

  incdir     "include/"
  include    "hw.i"
  include    "playfield.i"
  include    "tilemaps.i"
  include    "game_state.i"

  xdef       update_play_state
  xdef       init_play_state

  xref       swap_buffers
  xref       scroll_background
  xref       plship_update
  xref       ship_fire_shot
  xref       ship_shots_update
  xref       enemy_shots_update
  xref       enemies_activate
  xref       enemies_update
  xref       check_coll_shots_enemies
  xref       check_coll_shots_plship
  xref       check_coll_enemy_plship
  xref       check_coll_plship_map
  xref       erase_bgnds
  xref       enemies_draw
  xref       plship_draw
  xref       ship_shots_draw
  xref       enemy_shots_draw
  xref       bplpointers1
  xref       playfield1
  xref       init_bplpointers
  xref       bplpointers2
  xref       playfield2a
  xref       map_ptr
  xref       init_background
  xref       bgnd_x
  xref       camera_x
  xref       plship_init
  xref       init_hud
  xref       game_state
  xref       shots_init
  xref       init_enemies_array
  xref       copperlist
  xref       draw_powerup
  xref       update_powerup
  xref       check_coll_ship_powerup

  SECTION    code_section,CODE

;****************************************************************
; Updates the PLAYING game state.
;****************************************************************
update_play_state:
  jsr        swap_buffers                      ; swaps draw and view buffers for implementing double buffering

  jsr        scroll_background                 ; scrolls tilemap toward left

  jsr        plship_update                     ; updates player's ship state
  jsr        ship_fire_shot                    ; fires shots from player's ship
  jsr        ship_shots_update                 ; updates player's ship shots state
  jsr        enemy_shots_update                ; updates enemy shots state
    
  jsr        enemies_activate                  ; activates enemies based on their position on the map 
  jsr        enemies_update                    ; updates enemies state

  jsr        update_powerup                    ; updates powerups state

  jsr        check_coll_shots_enemies          ; checks collisions between player's shots and enemies
  jsr        check_coll_shots_plship           ; checks collisions between enemy shots and player's ship
  jsr        check_coll_enemy_plship           ; checks collisions between enemy and player's ship
  jsr        check_coll_plship_map             ; checks collisions between player's ship and tilemap
  jsr        check_coll_ship_powerup           ; checks collisions between player's ship and power-ups

  jsr        erase_bgnds                       ; erases bobs backgrounds
                    
  jsr        enemies_draw                      ; draws enemies
  jsr        plship_draw                       ; draws player's ship
  jsr        ship_shots_draw                   ; draws player's ship shots
  jsr        enemy_shots_draw                  ; draws enemy shots
  jsr        draw_powerup                      ; draws powerup

  rts


;***************************************************************************
; Initializes the PLAYING game state.
;***************************************************************************
init_play_state:

  move.l     #copperlist,COP1LC(a5)            ; sets our copperlist address into Copper
  move.w     d0,COPJMP1(a5)                    ; reset Copper PC to the beginning of our copperlist
  
; sets bitplane pointers for dual playfield mode            
  move.l     #BPP,d7  
  lea        bplpointers1,a1                   ; bitplane pointers in a1
  move.l     #playfield1+8-2,d0                ; address of background playfield
  move.l     #PF1_PLANE_SZ,d1 
  jsr        init_bplpointers                  ; initializes bitplane pointers for background playfield

  lea        bplpointers2,a1                   ; bitplane pointers in a1
  move.l     #playfield2a,d0                   ; address of foreground playfield
  move.l     #PF2_PLANE_SZ,d1 
  jsr        init_bplpointers                  ; initializes bitplane pointers for foreground playfield

; initializes scrolling background state
  move.w     #0,map_ptr
  move.w     #0*64,camera_x
  move.w     map_ptr,d0
  jsr        init_background
  move.w     #TILE_WIDTH,bgnd_x                ; x position of the part of background to draw

; initializes player's ship state
  jsr        plship_init

; initializes enemies array
  jsr        init_enemies_array

; initializes shots
  jsr        shots_init

; initializes hud 
  jsr        init_hud

; changes the game state to PLAYING
  move.w     #GAME_STATE_PLAYING,game_state
  
  rts
