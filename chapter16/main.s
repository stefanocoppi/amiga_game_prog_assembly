;************************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 16 - Collisions and explosions
;
;
; (c) 2024 Stefano Coppi
;************************************************************************

  incdir     "include"
  include    "hw.i"
  include    "funcdef.i"
  include    "exec/exec_lib.i"
  include    "graphics/graphics_lib.i"
  include    "playfield.i"
  include    "tilemaps.i"
  include    "scroll_bgnd.i"
  include    "bob.i"
  include    "plship.i"
  include    "collisions.i"
  include    "enemies.i"
  include    "shots.i"


;************************************************************************
; MAIN PROGRAM
;************************************************************************
  SECTION    code_section,CODE
main:
  jsr        take_system                  ; takes the control of Amiga's hardware
             
  lea        bplpointers1,a1              ; bitplane pointers in a1
  move.l     #playfield1+8-2,d0           ; address of background playfield
  move.l     #PF1_PLANE_SZ,d1 
  jsr        init_bplpointers             ; initializes bitplane pointers for background playfield

  lea        bplpointers2,a1              ; bitplane pointers in a1
  move.l     #playfield2a,d0              ; address of foreground playfield
  move.l     #PF2_PLANE_SZ,d1 
  jsr        init_bplpointers             ; initializes bitplane pointers for foreground playfield

  move.w     map_ptr,d0
  jsr        init_background
  move.w     #TILE_WIDTH,bgnd_x           ; x position of the part of background to draw

  jsr        plship_init

; initializes enemies array
  jsr        init_enemies_array
  
mainloop: 
  jsr        wait_vblank                  ; waits for vertical blank
  jsr        swap_buffers

  jsr        scroll_background

  jsr        plship_update
  jsr        ship_fire_shot               ; fires shots from player's ship
  jsr        ship_shots_update            ; updates player's ship shots state
  jsr        enemy_shots_update           ; updates enemy shots state
    
  jsr        enemies_activate
  jsr        enemies_update

  jsr        check_coll_shots_enemies     ; checks collisions between player's shots and enemies
  jsr        check_coll_shots_plship      ; checks collisions between enemy shots and player's ship
  jsr        check_coll_enemy_plship      ; checks collisions between enemy and player's ship
  jsr        check_coll_plship_map        ; checks collision between player's ship and tilemap
    
  jsr        erase_bgnds
                    
  jsr        enemies_draw
  jsr        plship_draw
  jsr        ship_shots_draw              ; draws player's ship shots
  jsr        enemy_shots_draw             ; draws enemy shots

  btst       #6,CIAAPRA                   ; left mouse button pressed?
  bne.s      mainloop                     ; if not, repeats the loop

  jsr        release_system               ; releases the hw control to the O.S.
  rts

     
  END