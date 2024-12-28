;****************************************************************
; Player's ship
;
; (c) 2024 Stefano Coppi
;****************************************************************

                    incdir     "include/"
                    include    "hw.i"
                    include    "plship.i"
                    include    "bob.i"

                     
;****************************************************************
; GRAPHICS DATA in chip ram
;****************************************************************
                    SECTION    graphics_data,DATA_C
         
player_ship_gfx     incbin     "gfx/ship.raw"
player_ship_mask    incbin     "gfx/ship.mask"

ship_engine_gfx     incbin     "gfx/ship_engine.raw"
ship_engine_mask    incbin     "gfx/ship_engine.mask"


;****************************************************************
; VARIABLES
;****************************************************************
                    SECTION    code_section,CODE
                     
fire_prev_frame     dc.w       0                                             ; state of fire button in the previous frame (1 pressed)

                    xdef       player_ship
player_ship         dc.w       0                                             ; bob.x
                    dc.w       0                                             ; bob.y
                    dc.w       2                                             ; bob.speed
                    dc.w       64                                            ; bob.width
                    dc.w       28                                            ; bob.height  
                    dc.w       0                                             ; bob.ssheet_c
                    dc.w       0                                             ; bob.ssheet_r
                    dc.w       64                                            ; bob.ssheet_w
                    dc.w       28                                            ; bob.ssheet_h
                    dc.l       player_ship_gfx                               ; bob.imgdata
                    dc.l       player_ship_mask                              ; bob.mask
                    dc.w       5                                             ; ship.anim_duration 
                    dc.w       5                                             ; ship.anim_timer
                    dc.w       0                                             ; ship.fire_timer

player_ship_engine  dc.w       0                                             ; x position
                    dc.w       0                                             ; y position
                    dc.w       1                                             ; speed
                    dc.w       32                                            ; width
                    dc.w       16                                            ; height  
                    dc.w       0                                             ; spritesheet column of the bob
                    dc.w       0                                             ; spritesheet row of the bob
                    dc.w       128                                           ; spritesheet width in pixels
                    dc.w       16                                            ; spritesheet height in pixels
                    dc.l       ship_engine_gfx                               ; image data address
                    dc.l       ship_engine_mask 


;****************************************************************
; SUBROUTINES
;****************************************************************


;****************************************************************
; Initializes the player's ship state
;****************************************************************
                    xdef       plship_init
plship_init:
                    movem.l    d0-a6,-(sp)

                    lea        player_ship,a0
                    move.w     #PLSHIP_X0,bob.x(a0)
                    move.w     #PLSHIP_Y0,bob.y(a0)
                    clr.w      bob.ssheet_c(a0)
                    move.w     ship.anim_duration(a0),ship.anim_timer(a0)

                    lea        player_ship_engine,a1
                    move.w     #PLSHIP_X0-17,bob.x(a1)
                    move.w     #PLSHIP_Y0+9,bob.y(a1)
                    clr.w      bob.ssheet_c(a1)
                  
.return:
                    movem.l    (sp)+,d0-a6
                    rts


;****************************************************************
; Draws the player's ship.
;****************************************************************
                    xdef       plship_draw
plship_draw:
                    movem.l    d0-a6,-(sp)

                    lea        player_ship,a3
 
                    move.l     draw_buffer,a2
                    bsr        draw_bob                                      ; draws ship

                    lea        player_ship_engine,a3
                    move.l     draw_buffer,a2
                    bsr        draw_bob                                      ; draws engine fire

.return:
                    movem.l    (sp)+,d0-a6
                    rts


;****************************************************************
; Updates the player's ship state
;****************************************************************
                    xdef       plship_update
plship_update:
                    movem.l    d0-a6,-(sp)

                    lea        player_ship,a0
                    bsr        plship_move_with_joystick
                    bsr        plship_limit_movement

; sets engine fire bob position
                    lea        player_ship_engine,a1
                    move.w     bob.x(a0),d0
                    sub.w      #17,d0
                    move.w     d0,bob.x(a1)                                  ; engine.x = ship.x - 17
                    move.w     bob.y(a0),d0
                    add.w      #9,d0
                    move.w     d0,bob.y(a1)                                  ; engine.y = ship.y + 9

; animates engine fire
                    sub.w      #1,ship.anim_timer(a0)
                    tst.w      ship.anim_timer(a0)                           ; anim_timer = 0?
                    beq        .incr_frame
                    bra        .return
.incr_frame:
                    add.w      #1,bob.ssheet_c(a1)                           ; increases animation frame
                    cmp.w      #4,bob.ssheet_c(a1)                           ; ssheet_c >= 4?
                    bge        .reset_frame
                    bra        .reset_timer
.reset_frame:
                    clr.w      bob.ssheet_c(a1)                              ; resets animation frame
.reset_timer:
                    move.w     ship.anim_duration(a0),ship.anim_timer(a0)    ; resets anim_timer
                    bra        .return

.return:
                    movem.l    (sp)+,d0-a6
                    rts


;****************************************************************
; Moves the player's ship with the joystick
;
; parameters:
; a0 - player's ship
;****************************************************************
plship_move_with_joystick:
                    movem.l    d0-a6,-(sp)

                    move.w     JOY1DAT(a5),d0
                    move.w     bob.speed(a0),d2
                    btst.l     #1,d0                                         ; joy right?
                    bne        .set_right
                    btst.l     #9,d0                                         ; joy left?
                    bne        .set_left
                    bra        .check_up
.set_right:
                    add.w      d2,bob.x(a0)                                  ; ship.x += ship.speed 
                    bra        .check_up
.set_left:
                    sub.w      d2,bob.x(a0)                                  ; ship.x -= ship.speed
.check_up:
                    move.w     d0,d1
                    lsr.w      #1,d1
                    eor.w      d1,d0
                    btst.l     #8,d0                                         ; joy up?
                    bne        .set_up
                    btst.l     #0,d0                                         ; joy down?
                    bne        .set_down
                    bra        .return
.set_up:
                    sub.w      d2,bob.y(a0)                                  ; ship.y-= ship.speed
                    bra        .return
.set_down:
                    add.w      d2,bob.y(a0)                                  ; ship.y+= ship.speed

.return:
                    movem.l    (sp)+,d0-a6
                    rts


;****************************************************************
; Limits player's ship movement, avoiding exiting from the viewport.
;
; parameters:
; a0 - player's ship
;****************************************************************
plship_limit_movement:
                    movem.l    d0-a6,-(sp)

                    move.w     bob.x(a0),d0
                    cmp.w      #PLSHIP_XMIN,d0                               ; x < PLSHIP_XMIN?
                    blt        .limit_xmin
                    bra        .check_xmax
.limit_xmin:
                    move.w     #PLSHIP_XMIN,bob.x(a0)                        ; x = PLSHIP_XMIN
                    bra        .check_ymin
.check_xmax:
                    cmp.w      #PLSHIP_XMAX,d0                               ; x > PLSHIP_XMAX?
                    bgt        .limit_xmax
                    bra        .check_ymin
.limit_xmax:
                    move.w     #PLSHIP_XMAX,bob.x(a0)                        ; x = PLSHIP_XMAX
.check_ymin:
                    move.w     bob.y(a0),d0
                    cmp.w      #PLSHIP_YMIN,d0                               ; y < PLSHIP_YMIN?
                    blt        .limit_ymin
                    bra        .check_ymax
.limit_ymin:
                    move.w     #PLSHIP_YMIN,bob.y(a0)                        ; y = PLSHIP_YMIN
                    bra        .return
.check_ymax:
                    cmp.w      #PLSHIP_YMAX,d0                               ; y > PLSHIP_YMAX?
                    bgt        .limit_ymax
                    bra        .return
.limit_ymax:
                    move.w     #PLSHIP_YMAX,bob.y(a0)                        ; y = PLSHIP_YMAX
.return:
                    movem.l    (sp)+,d0-a6
                    rts


;****************************************************************
; Fires a shot from the ship.
;****************************************************************
                    xdef       ship_fire_shot
ship_fire_shot:
                    movem.l    d0-a6,-(sp)

; decreases fire_timer
; avoids fire_timer from becoming negative
; if fire button is pressed
;     if fire button previous frame is not pressed
;         if fire_timer = 0
;             fire_timer = FIRE_INTERVAL
;             create shot
;     fire_prev_fame = 1
; else
;     fire_prev_frame = 0

                    lea        player_ship,a0
                    sub.w      #1,ship.fire_timer(a0)                        ; decreases fire timer, time interval between two shots
                    tst.w      ship.fire_timer(a0)                           ; fire_timer < 0?
                    blt        .avoid_neg
                    bra        .check_fire_btn
.avoid_neg:
                    clr.w      ship.fire_timer(a0)
.check_fire_btn:
                    btst       #7,CIAAPRA                                    ; fire button of joystick #1 pressed?
                    beq        .check_prev_state
                    bra        .fire_not_pressed                           
.check_prev_state:
                    cmp.w      #1,fire_prev_frame                            ; fire button pressed previous frame?
                    bne        .check_timer
                    bra        .prev_frame
.check_timer:    
                    tst.w      ship.fire_timer(a0)                           ; fire_timer = 0?
                    beq        .create_shot
                    bra        .prev_frame                             
.create_shot:                        
                    move.w     #FIRE_INTERVAL,ship.fire_timer(a0)            ; fire_timer = FIRE_INTERVAL
                    jsr        ship_shot_create
                    bra        .prev_frame
.fire_not_pressed:                                         
                    clr.w      fire_prev_frame                                      
                    bra        .return
.prev_frame:
                    move.w     #1,fire_prev_frame
.return:
                    movem.l    (sp)+,d0-a6
                    rts
