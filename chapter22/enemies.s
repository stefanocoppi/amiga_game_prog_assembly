;****************************************************************
; Enemies
;
; (c) 2024 Stefano Coppi
;****************************************************************

                      include    "enemies.i"
                      include    "bob.i"
                      include    "sound.i"

                      xdef       enemies_activate
                      xdef       enemies_draw
                      xdef       enemies_update,enemy_explode
                      xdef       init_enemies_array


                      xref       enemies_model
                      xref       enemies_array
                      xref       camera_x
                      xref       draw_buffer,draw_bob
                      xref       enemy_shot_create
                      xref       add_to_score
                      xref       play_sfx
                      xref       play_sample




                    
;****************************************************************
; GRAPHICS DATA in chip ram
;****************************************************************
                      SECTION    graphics_data,DATA_C
enemy_explosion_gfx   incbin     "gfx/enemy_explosion.raw"
enemy_explosion_mask  incbin     "gfx/enemy_explosion.mask"


;****************************************************************
; SUBROUTINES
;****************************************************************
                      SECTION    code_section,CODE


;****************************************************************
; Initializes the enemies array, copying data from enemies_model
;****************************************************************
init_enemies_array:
                      movem.l    d0-a6,-(sp)

                      move.l     #(enemy.length*NUM_ENEMIES),d7
                      lea        enemies_model,a0
                      lea        enemies_array,a1
.copy_loop:
                      move.b     (a0)+,(a1)+
                      dbra       d7,.copy_loop

.return:
                      movem.l    (sp)+,d0-a6
                      rts


;****************************************************************
; Activates enemies based on their map location.
;****************************************************************
enemies_activate:
                      movem.l    d0-a6,-(sp)

                      lea        enemies_array,a0
                      move.l     #NUM_ENEMIES-1,d7                               ; iterates over enemies array

.loop:
                      move.w     enemy.map_position(a0),d0
                      cmp.w      camera_x,d0                                     ; enemy.map_position = camera_x?
                      beq        .activate
                      bra        .next_element
.activate:
                      move.w     #ENEMY_STATE_ACTIVE,enemy.state(a0)             ; changes state to active
.next_element:
                      add.l      #enemy.length,a0                                ; points to next enemy in the array
                      dbra       d7,.loop

.return:
                      movem.l    (sp)+,d0-a6
                      rts


;****************************************************************
; Draws the enemies.
;****************************************************************
enemies_draw:
                      movem.l    d0-a6,-(sp)

                      lea        enemies_array,a3                                         
                      move.l     #NUM_ENEMIES-1,d7                               ; iterates over enemies array

.loop:
                      cmp.w      #ENEMY_STATE_INACTIVE,enemy.state(a3)           ; enemy state is inactive?
                      beq        .skip_draw

                      tst.w      enemy.visible(a3)                               ; enemy visible?
                      beq        .skip_draw                                      ; if not, skip draw
                      
                      move.l     draw_buffer,a2
                      jsr        draw_bob                                        ; draws enemy                
.skip_draw:
                      add.l      #enemy.length,a3                                ; points to next enemy in the array
                      dbra       d7,.loop

.return:
                      movem.l    (sp)+,d0-a6
                      rts


;****************************************************************
; Updates the enemies state.
;****************************************************************
enemies_update:
                      movem.l    d0-a6,-(sp)

                      lea        enemies_array,a0
                      move.l     #NUM_ENEMIES-1,d7                                          
; iterates over the enemies array
.loop:
                      cmp.w      #ENEMY_STATE_INACTIVE,enemy.state(a0)           ; enemy state is inactive?
                      beq        .next_element                                   ; if yes, doesn't update state and skips to next enemy
                      cmp.w      #ENEMY_STATE_HIT,enemy.state(a0)                ; enemy state is hit?
                      beq        .state_hit
                      cmp.w      #ENEMY_STATE_EXPLOSION,enemy.state(a0)          ; enemy state is explosion?
                      beq        .state_explosion
                      cmp.w      #ENEMY_STATE_GOTOXY,enemy.state(a0)             ; enemy state is gotoxy?
                      beq        .state_gotoxy
                      bra        .exec_command
.state_hit:
                      sub.w      #1,enemy.flash_timer(a0)
                      beq        .toggle_visibility                              ; if flash_timer=0, toggles visibility
                      bra        .decrease_hit_timer
.toggle_visibility:
                      not.w      enemy.visible(a0)
                      move.w     #ENEMY_FLASH_DURATION,enemy.flash_timer(a0)     ; resets flash_timer
.decrease_hit_timer:
                      sub.w      #1,enemy.hit_timer(a0)                          ; decreases hit_timer
                      bne        .next_element                                   ; if hit_timer <> 0, goes to next element
                      move.w     #ENEMY_STATE_ACTIVE,enemy.state(a0)             ; else changes state to active
                      move.w     #$ffff,enemy.visible(a0)                        ; makes the enemy visible
                      bra        .exec_command
.state_explosion:
                      sub.w      #1,enemy.anim_timer(a0)                         ; decreases anim_timer
                      beq        .frame_advance                                  ; if anim_timer = 0, advances animation frame
                      bra        .next_element
.frame_advance:
                      add.w      #1,bob.ssheet_c(a0)                             ; advances to next frame
                      move.w     enemy.anim_duration(a0),enemy.anim_timer(a0)    ; resets anim timer
                      move.w     bob.ssheet_c(a0),d0
                      cmp.w      enemy.num_frames(a0),d0                         ; ssheet_c >= num_frames?
                      bge        .end_animation
                      bra        .next_element
.end_animation:
                      move.w     #ENEMY_STATE_INACTIVE,enemy.state(a0)
                      clr.w      enemy.cmd_pointer(a0)                           ; resets cmd_pointer
                      bra        .next_element
.state_gotoxy:
                      move.w     bob.speed(a0),d1
                      move.w     enemy.tx(a0),d0
                      cmp.w      bob.x(a0),d0
                      blt        .decr_x                                         ; if tx < x, then decreases x
                      bgt        .incr_x                                         ; if tx > x, then increases x
                      bra        .compare_y
.decr_x:
                      sub.w      d1,bob.x(a0)
                      bra        .compare_y
.incr_x:
                      add.w      d1,bob.x(a0)
                      bra        .compare_y
.compare_y:
                      move.w     enemy.ty(a0),d0
                      cmp.w      bob.y(a0),d0
                      blt        .decr_y                                         ; if ty < y then decreases y
                      bgt        .incr_y                                         ; if ty > y then increases y
                      bra        .exec_command
.decr_y:
                      sub.w      d1,bob.y(a0)
                      bra        .exec_command
.incr_y:
                      add.w      d1,bob.y(a0)
                      bra        .exec_command

.exec_command:
                      bsr        enemies_execute_command
.next_element:
                      add.l      #enemy.length,a0                                ; points to next enemy in the array
                      dbra       d7,.loop

.return:
                      movem.l    (sp)+,d0-a6
                      rts


;****************************************************************
; Executes commands for controlling active enemies.
;
; parameters:
; a0 - enemy instance
;****************************************************************
enemies_execute_command:
                      movem.l    d0-a6,-(sp)

                      cmp.w      #ENEMY_STATE_INACTIVE,enemy.state(a0)           ; enemy state is inactive?
                      beq        .return
                    ;  cmp.w      #ENEMY_STATE_EXPLOSION,enemy.state(a0)        ; enemy state is explosion?
                    ;  beq        .return

.parse_command:
                      lea        enemy.cmd_list(a0),a1
                      add.w      enemy.cmd_pointer(a0),a1
                      move.w     (a1),d0                                         ; fetches current command
                      cmp.w      #ENEMY_CMD_GOTO,d0                              ; interprets the command and executes it
                      beq        .exec_goto
                      cmp.w      #ENEMY_CMD_END,d0
                      beq        .exec_end
                      cmp.w      #ENEMY_CMD_PAUSE,d0
                      beq        .exec_pause
                      cmp.w      #ENEMY_CMD_FIRE,d0
                      beq        .exec_fire
                      cmp.w      #ENEMY_CMD_SETPOS,d0
                      beq        .exec_setpos
                      bra        .return
.exec_goto:
                      move.w     #ENEMY_STATE_GOTOXY,enemy.state(a0)             ; changes state to gotoxy
                      move.w     2(a1),enemy.tx(a0)                              ; gets target coordinates tx,ty
                      move.w     4(a1),enemy.ty(a0)
                      
                      move.w     enemy.tx(a0),d0
                      cmp.w      bob.x(a0),d0                                    ; tx- x
                      beq        .check_ty                                       ; if tx = x, checks ty
                      bra        .return
.check_ty:
                      move.w     enemy.ty(a0),d0
                      cmp.w      bob.y(a0),d0
                      beq        .command_executed                               ; if ty = y, then enemy reached target, so the command has been executed
                      bra        .return

.command_executed:
                      move.w     #ENEMY_STATE_ACTIVE,enemy.state(a0)             ; changes state to active
                      add.w      #3*2,enemy.cmd_pointer(a0)                      ; points to next command
                      bra        .return
.exec_end:
                      move.w     #ENEMY_STATE_INACTIVE,enemy.state(a0)           ; changes state to inactive
                      clr.w      enemy.cmd_pointer(a0)                           ; resets cmd_pointer
                      bra        .return
.exec_pause:
                      cmp.w      #ENEMY_STATE_PAUSE,enemy.state(a0)              ; state = pause?
                      beq        .state_pause
                      move.w     2(a1),d0                                        ; gets pause duration in frames
                      move.w     d0,enemy.pause_timer(a0)                        ; initializes pause timer
                      move.w     #ENEMY_STATE_PAUSE,enemy.state(a0)              ; changes state to pause
                      bra        .return
.state_pause:
                      sub.w      #1,enemy.pause_timer(a0)                        ; updates pause timer
                      beq        .end_pause                                      ; pause timer = 0?
                      bra        .return
.end_pause:
                      move.w     #ENEMY_STATE_ACTIVE,enemy.state(a0)             ; change state to active
                      add.w      #2*2,enemy.cmd_pointer(a0)                      ; points to next command
                      bra        .return
.exec_fire:
                      move.l     a0,a1
                      jsr        enemy_shot_create                               ; creates a new instance of enemy shot
                      add.w      #2,enemy.cmd_pointer(a0)                        ; points to next command
                      bra        .return

.exec_setpos:
                      move.w     2(a1),d0                                        ; gets x0 coordinate
                      move.w     d0,bob.x(a0)                                    ; enemy.x = x0
                      move.w     4(a1),d0
                      move.w     d0,bob.y(a0)                                    ; enemy.y = y0
                      add.w      #3*2,enemy.cmd_pointer(a0)                      ; points to next command
                      bra        .return
.return:
                      movem.l    (sp)+,d0-a6
                      rts


;****************************************************************
; Blows up the enemy.
;
; parameters:
; a0 - shot instance
; a1 - enemy instance
;****************************************************************
enemy_explode:

; adds points to score
                      move.w     enemy.score(a1),d0
                      jsr        add_to_score

; changes enemy state to explosion
                      move.w     #ENEMY_STATE_EXPLOSION,enemy.state(a1)
; setups explosion graphics data and mask
                      move.l     #enemy_explosion_gfx,bob.imgdata(a1)
                      move.l     #enemy_explosion_mask,bob.mask(a1)
; adjusts bob position for explosion animation
                      sub.w      #3,bob.x(a1)
                      sub.w      #12,bob.y(a1)
; setups explosion animation data
                      move.w     #64,bob.width(a1)
                      move.w     #64,bob.height(a1)
                      move.w     #0,bob.ssheet_c(a1)
                      move.w     #0,bob.ssheet_r(a1)
                      move.w     #512,bob.ssheet_w(a1)
                      move.w     #64,bob.ssheet_h(a1)
                      move.w     #3,enemy.anim_duration(a1)
                      move.w     #3,enemy.anim_timer(a1)
                      move.w     #8,enemy.num_frames(a1)
; plays sound fx
                      move.w     #SFX_ID_EXPLOSION,d0
                      clr.w      d1                                              ; no loop
                      jsr        play_sfx
                      ;jsr        play_sample 

                      rts