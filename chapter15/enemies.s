;****************************************************************
; Enemies
;
; (c) 2024 Stefano Coppi
;****************************************************************

                      include    "enemies.i"
                      include    "bob.i"

                      xdef       enemies_activate
                      xdef       enemies_draw
                      xdef       enemies_update

                      xref       enemies_array,camera_x
                      xref       draw_buffer,draw_bob
                      xref       enemy_shot_create


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
                      cmp.w      #ENEMY_STATE_GOTOXY,enemy.state(a0)             ; enemy state is gotoxy?
                      beq        .state_gotoxy
                      bra        .exec_command

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

.return:
                      movem.l    (sp)+,d0-a6
                      rts

