;****************************************************************
; Shots
;
; (c) 2024 Stefano Coppi
;****************************************************************
                  incdir     "include"
                  include    "hw.i"
                  include    "plship.i"
                  include    "shots.i"
                  include    "collisions.i"
                  include    "bob.i"
                  include    "enemies.i"

                  xref       player_ship,draw_buffer,draw_bob

                  xdef       ship_shots_draw,ship_shots_update
                  xdef       ship_shot_create
                  xdef       enemy_shot_create
                  xdef       enemy_shots_draw
                  xdef       enemy_shots_update
                  xdef       ship_shots,enemy_shots
                  xdef       shots_init

;****************************************************************
; GRAPHICS DATA in chip ram
;****************************************************************
                  SECTION    graphics_data,DATA_C

ship_shots_gfx    incbin     "gfx/ship_shots.raw"
ship_shots_mask   incbin     "gfx/ship_shots.mask"

enemy_shots_gfx   incbin     "gfx/enemy_shots.raw"
enemy_shots_mask  incbin     "gfx/enemy_shots.mask"


;****************************************************************
; BSS DATA
;****************************************************************
                  SECTION    bss_data,BSS_C

ship_shots        ds.b       (shot.length*PLSHIP_MAX_SHOTS)                ; ship's shots array
enemy_shots       ds.b       (shot.length*ENEMY_MAX_SHOTS)                 ; enemy shots array






;****************************************************************
; SUBROUTINES
;****************************************************************
                 
                  SECTION    code_section,CODE


;****************************************************************
; Initializes shots array, making all shots idle
;****************************************************************
shots_init:
                  movem.l    d0-a6,-(sp)

                  lea        ship_shots,a0
                  move.l     #PLSHIP_MAX_SHOTS-1,d7
; changes state to idle for all ship_shots
.loop:
                  move.w     #SHOT_STATE_IDLE,shot.state(a0)
                  add.l      #shot.length,a0
                  dbra       d7,.loop

                  lea        enemy_shots,a0
                  move.l     #ENEMY_MAX_SHOTS-1,d7
; changes state to idle for all enemy_shots
.loop2:
                  move.w     #SHOT_STATE_IDLE,shot.state(a0)
                  add.l      #shot.length,a0
                  dbra       d7,.loop2

.return:
                  movem.l    (sp)+,d0-a6
                  rts


;****************************************************************
; Draws the ship's shots.
;****************************************************************
ship_shots_draw:
                  movem.l    d0-a6,-(sp)

                  lea        ship_shots,a0
                  move.l     #PLSHIP_MAX_SHOTS-1,d7
; iterates over the ship_shots array
.loop:
                  tst.w      shot.state(a0)                                ; shot.state is idle?
                  beq        .next
                     
                  move.l     a0,a3
                  move.l     draw_buffer,a2
                  jsr        draw_bob                                      ; draws shot

.next             add.l      #shot.length,a0                               ; goes to next element
                  dbra       d7,.loop
                  bra        .return

.return:
                  movem.l    (sp)+,d0-a6
                  rts


;****************************************************************
; Updates the ship's shots state.
;****************************************************************
ship_shots_update:
                  movem.l    d0-a6,-(sp)

                  lea        ship_shots,a0
                  move.l     #PLSHIP_MAX_SHOTS-1,d7
; iterates over the ship_shots array
.loop:
                  tst.w      shot.state(a0)                                ; shot.state is idle?
                  beq        .next
                     
                  cmp.w      #SHOT_STATE_LAUNCH,shot.state(a0)             ; shot.state is launch?
                  beq        .launch
                  cmp.w      #SHOT_STATE_ACTIVE,shot.state(a0)             ; shot.state is active?
                  beq        .active
                  cmp.w      #SHOT_STATE_HIT,shot.state(a0)                ; shot.state is hit?
                  beq        .hit
                  bra        .next
.launch:
                  sub.w      #1,shot.anim_timer(a0)                        ; decreases anim_timer
                  beq        .inc_frame                                    ; anim_timer = 0?
                  bra        .next
.inc_frame:
                  add.w      #1,shot.ssheet_c(a0)                          ; increases animation frame
                  move.w     shot.anim_duration(a0),shot.anim_timer(a0)    ; resets anim_timer
                  move.w     shot.ssheet_c(a0),d0
                  cmp.w      shot.num_frames(a0),d0                        ; current frame > num frames?
                  bgt        .end_anim
                  bra        .next
.end_anim:
                  move.w     #6,shot.ssheet_c(a0)                          ; sets shot flight frame
                  move.w     #SHOT_STATE_ACTIVE,shot.state(a0)             ; changes shot state to active
                  bra        .next
.active:
                  move.w     shot.speed(a0),d0
                  add.w      d0,shot.x(a0)                                 ; shot.x += shot.speed
                  cmp.w      #SHOT_MAX_X,shot.x(a0)                        ; shot.x >= SHOT_MAX_X ?
                  bge        .deactivate
                  bra        .next
.deactivate       move.w     #SHOT_STATE_IDLE,shot.state(a0)
                  bra        .next
.hit:
                  sub.w      #1,shot.anim_timer(a0)                        ; decreases anim_timer
                  beq        .inc_frame2                                   ; anim_timer = 0?
                  bra        .next
.inc_frame2:
                  add.w      #1,shot.ssheet_c(a0)                          ; increases animation frame
                  move.w     shot.anim_duration(a0),shot.anim_timer(a0)    ; resets anim_timer
                  move.w     shot.ssheet_c(a0),d0
                  cmp.w      shot.num_frames(a0),d0                        ; current frame > num frames?
                  bgt        .end_anim2
                  bra        .next
.end_anim2:
                  move.w     #SHOT_STATE_IDLE,shot.state(a0)               ; changes shot state to idle
                  bra        .next
.next             add.l      #shot.length,a0                               ; goes to next element
                  dbra       d7,.loop
                  bra        .return

.return:
                  movem.l    (sp)+,d0-a6
                  rts


;****************************************************************
; Creates a new ship's shot.
;****************************************************************
ship_shot_create:
                  movem.l    d0-a6,-(sp)

                  lea        ship_shots,a0
; finds the first free element in the array
                  move.l     #PLSHIP_MAX_SHOTS-1,d7
.loop:
                  tst.w      shot.state(a0)                                ; shot.state is idle?
                  beq        .insert_new_shot
                  add.l      #shot.length,a0                               ; goes to next element
                  dbra       d7,.loop
                  bra        .return
; creates a new shot instance and inserts in the first free element of the array
.insert_new_shot:
                  lea        player_ship,a1
                  move.w     bob.x(a1),d0
                  add.w      #47,d0
                  move.w     d0,shot.x(a0)                                 ; shot.x = bob.x + ship.width
                  move.w     bob.y(a1),d0
                  sub.w      #9,d0
                  move.w     d0,shot.y(a0)                                 ; shot.y = bob.y + 10
                  move.w     #SHIP_SHOT_SPEED,shot.speed(a0)               ; shot.speed = SHOT_SPEED
                  move.w     #SHIP_SHOT_WIDTH,shot.width(a0)
                  move.w     #SHIP_SHOT_HEIGHT,shot.height(a0)
                  move.w     #0,shot.ssheet_c(a0)
                  cmp.w      #PLSHIP_FIRE_2,ship.fire_type(a1)
                  beq        .fire2
                  move.w     #0,shot.ssheet_r(a0)
                  move.w     #SHIP_SHOT_DAMAGE1,shot.damage(a0)
                  bra        .continue
.fire2:
                  move.w     #2,shot.ssheet_r(a0)
                  move.w     #SHIP_SHOT_DAMAGE2,shot.damage(a0)
.continue:
                  move.w     #448,shot.ssheet_w(a0)
                  move.w     #256,shot.ssheet_h(a0)
                  move.l     #ship_shots_gfx,shot.imgdata(a0)
                  move.l     #ship_shots_mask,shot.mask(a0)
                  move.w     #SHOT_STATE_LAUNCH,shot.state(a0)
                  move.w     #6,shot.num_frames(a0)
                  move.w     #3,shot.anim_duration(a0)
                  move.w     #3,shot.anim_timer(a0)
                  
; setups bounding box for collisions
                  lea        shot.bbox(a0),a2
                  move.w     #20,rect.x(a2)                                ; rect.x = shot.x + 20
                  move.w     #25,rect.y(a2)                                ; rect.y = shot.y + 25                                                    
                  move.w     #40,rect.width(a2)
                  move.w     #15,rect.height(a2)
.return:
                  movem.l    (sp)+,d0-a6
                  rts


;****************************************************************
; Creates a new enemy shot.
;
; parameters:
; a1 - enemy instance
;****************************************************************
enemy_shot_create:
                  movem.l    d0-a6,-(sp)

                  lea        enemy_shots,a0
; finds the first free element in the array
                  move.l     #ENEMY_MAX_SHOTS-1,d7
.loop:
                  tst.w      shot.state(a0)                                ; shot.state is idle?
                  beq        .insert_new_shot
                  add.l      #shot.length,a0                               ; goes to next element
                  dbra       d7,.loop
                  bra        .return
; creates a new shot instance and inserts in the first free element of the array
.insert_new_shot:
                  move.w     bob.x(a1),d0
                  add.w      enemy.fire_offx(a1),d0
                  move.w     d0,shot.x(a0)                                 ; shot.x = enemy.x -34
                  move.w     bob.y(a1),d0
                  add.w      enemy.fire_offy(a1),d0
                  move.w     d0,shot.y(a0)                                 ; shot.y = enemy.y + 15
                  move.w     #ENEMY_SHOT_SPEED,shot.speed(a0)              ; shot.speed = SHOT_SPEED
                  move.w     #ENEMY_SHOT_WIDTH,shot.width(a0)
                  move.w     #ENEMY_SHOT_HEIGHT,shot.height(a0)
                  move.w     #0,shot.ssheet_c(a0)
                  move.w     #0,shot.ssheet_r(a0)
                  move.w     #384,shot.ssheet_w(a0)
                  move.w     #32,shot.ssheet_h(a0)
                  move.l     #enemy_shots_gfx,shot.imgdata(a0)
                  move.l     #enemy_shots_mask,shot.mask(a0)
                  move.w     #SHOT_STATE_LAUNCH,shot.state(a0)
                  move.w     #5,shot.num_frames(a0)
                  move.w     #3,shot.anim_duration(a0)
                  move.w     #3,shot.anim_timer(a0)
                  move.w     #ENEMY_SHOT_DAMAGE,shot.damage(a0)
.return:
                  movem.l    (sp)+,d0-a6
                  rts


;****************************************************************
; Draws the enemy shots.
;****************************************************************
enemy_shots_draw:
                  movem.l    d0-a6,-(sp)

                  lea        enemy_shots,a0
                  move.l     #ENEMY_MAX_SHOTS-1,d7

; iterates over the enemy_shots array
.loop:
                  tst.w      shot.state(a0)                                ; shot.state is idle?
                  beq        .next
                     
                  move.l     a0,a3
                  move.l     draw_buffer,a2
                  bsr        draw_bob                                      ; draws shot

.next             add.l      #shot.length,a0                               ; goes to next element
                  dbra       d7,.loop
                  bra        .return

.return:
                  movem.l    (sp)+,d0-a6
                  rts


;****************************************************************
; Updates the enemy shots state.
;****************************************************************
enemy_shots_update:
                  movem.l    d0-a6,-(sp)

                  lea        enemy_shots,a0
                  move.l     #ENEMY_MAX_SHOTS-1,d7

; iterates over the enemy_shots array
.loop:
                  tst.w      shot.state(a0)                                ; shot.state is idle?
                  beq        .next
                     
                  cmp.w      #SHOT_STATE_LAUNCH,shot.state(a0)             ; shot.state is launch?
                  beq        .launch
                  cmp.w      #SHOT_STATE_ACTIVE,shot.state(a0)             ; shot.state is active?
                  beq        .active
                  bra        .next
.launch:
                  sub.w      #1,shot.anim_timer(a0)                        ; decreases anim_timer
                  beq        .inc_frame                                    ; anim_timer = 0?
                  bra        .next
.inc_frame:
                  add.w      #1,shot.ssheet_c(a0)                          ; increases animation frame
                  move.w     shot.anim_duration(a0),shot.anim_timer(a0)    ; resets anim_timer
                  move.w     shot.ssheet_c(a0),d0
                  cmp.w      shot.num_frames(a0),d0                        ; current frame > num frames?
                  bgt        .end_anim
                  bra        .next
.end_anim:
                  move.w     #5,shot.ssheet_c(a0)                          ; sets shot flight frame
                  move.w     #SHOT_STATE_ACTIVE,shot.state(a0)             ; changes shot state to active
                  bra        .next
.active:
                  move.w     shot.speed(a0),d0
                  sub.w      d0,shot.x(a0)                                 ; shot.x -= shot.speed
                  cmp.w      #SHOT_MIN_X,shot.x(a0)                        ; shot.x <= SHOT_MIN_X ?
                  ble        .deactivate
                  bra        .next
.deactivate       move.w     #SHOT_STATE_IDLE,shot.state(a0)

.next             add.l      #shot.length,a0                               ; goes to next element
                  dbra       d7,.loop
                  bra        .return

.return:
                  movem.l    (sp)+,d0-a6
                  rts