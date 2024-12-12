;****************************************************************
; Power Ups management
;
; (c) 2024 Stefano Coppi
;****************************************************************

              include    "powerup.i"
              include    "enemies.i"
              include    "plship.i"
              include    "sound.i"

              xref       draw_bob
              xref       draw_buffer
              xref       player_ship
              xref       rect1,rect2
              xref       rect_intersects
              xref       play_sample


;****************************************************************
; GRAPHICS DATA in chip ram
;****************************************************************
              SECTION    graphics_data,DATA_C

powerup_gfx   incbin     "gfx/powerup.raw"
powerup_mask  incbin     "gfx/powerup.mask"


;****************************************************************
; VARIABLES
;****************************************************************
              SECTION    code_section,CODE

powerup       dcb.b      powerup.length,0                       ; current powerup instance
; powerup       dc.w       200
;               dc.w       100
;               dc.w       0
;               dc.w       PU_WIDTH
;               dc.w       PU_HEIGHT
;               dc.w       0
;               dc.w       0
;               dc.w       PU_WIDTH
;               dc.w       PU_HEIGHT
;               dc.l       powerup_gfx
;               dc.l       powerup_mask
;               dc.w       PU_S_ACTIVE
;               dc.w       0
;               dc.w       PU_VIS_DUR

;****************************************************************
; SUBROUTINES
;****************************************************************


;****************************************************************
; Creates a powerup object.
;
; parameters:
; a0 - address of the enemy data structure
;****************************************************************
              xdef       create_powerup
create_powerup:
              movem.l    d0-a6,-(sp)

              cmp.w      #PU_TYPE_NONE,enemy.powerup(a0)        ; if powerup type is none,
              beq        .return                                ; returns immediately
              lea        powerup,a1                             ; else initializes the current
              move.w     bob.x(a0),powerup.x(a1)                ; powerup instance
              move.w     bob.y(a0),powerup.y(a1)
              move.w     #PU_WIDTH,powerup.width(a1)
              move.w     #PU_HEIGHT,powerup.height(a1)
              move.w     #0,powerup.ssheet_c(a1)
              move.w     #0,powerup.ssheet_r(a1)
              move.w     #PU_WIDTH,powerup.ssheet_w(a1)
              move.w     #PU_HEIGHT,powerup.ssheet_h(a1)
              move.l     #powerup_gfx,powerup.imgdata(a1)
              move.l     #powerup_mask,powerup.mask(a1)
              move.w     #PU_S_ACTIVE,powerup.state(a1)
              move.w     enemy.powerup(a0),powerup.type(a1)    
              move.w     #PU_VIS_DUR,powerup.vis_timer(a1)
        
.return:
              movem.l    (sp)+,d0-a6
              rts


;****************************************************************
; Draws a powerup object.
;****************************************************************
              xdef       draw_powerup
draw_powerup:
              movem.l    d0-a6,-(sp)

              lea        powerup,a3                             ; pointer to current powerup object
              cmp.w      #PU_S_INACTIVE,powerup.state(a3)       ; if powerup is inactive,
              beq        .return                                ; doesn't draw it
              move.l     draw_buffer,a2 
              jsr        draw_bob                                

.return:
              movem.l    (sp)+,d0-a6
              rts


;****************************************************************
; Updates the powerup object state.
;****************************************************************
              xdef       update_powerup
update_powerup:
              movem.l    d0-a6,-(sp)

              lea        powerup,a3                             ; pointer to current powerup object
              cmp.w      #PU_S_INACTIVE,powerup.state(a3)       ; if powerup is inactive,
              beq        .return                                ; doesn't update it

              sub.w      #1,powerup.vis_timer(a3)               ; decreases visibility timer
              beq        .make_inactive                         ; if timer reaches zero, makes the powerup inactive
              bra        .return

.make_inactive:
              move.w     #PU_S_INACTIVE,powerup.state(a3)

.return:
              movem.l    (sp)+,d0-a6
              rts


;****************************************************************
; Checks the collision between ship and powerup.
;****************************************************************
              xdef       check_coll_ship_powerup
check_coll_ship_powerup:
; pseudocode:
;
; if ship and powerup are both in active state
;     if ship collides with current powerup
;         make the powerup inactive
;         activate powerup

              movem.l    d0-a6,-(sp)

              lea        powerup,a0
              lea        player_ship,a1
              cmp.w      #PU_S_INACTIVE,powerup.state(a0)       ; if powerup is inactive,
              beq        .return                                ; returns immediately
              cmp.w      #PLSHIP_STATE_NORMAL,ship.state(a1)    ; if ship isn't in normal state,
              bne        .return                                ; returns immediately

              lea        rect1,a2                               ; initializes ship bounding rectangle
              lea        ship.bbox(a1),a4
              move.w     bob.x(a1),rect.x(a2)
              move.w     rect.x(a4),d0                 
              add.w      d0,rect.x(a2)     
              move.w     bob.y(a1),rect.y(a2)
              move.w     rect.y(a4),d0                 
              add.w      d0,rect.y(a2)
              move.w     rect.width(a4),rect.width(a2)
              move.w     rect.height(a4),rect.height(a2)

              lea        rect2,a3                               ; initializes powerup bounding rectangle
              move.w     powerup.x(a0),rect.x(a3)
              move.w     powerup.y(a0),rect.y(a3)
              move.w     #PU_WIDTH,rect.width(a3)
              move.w     #PU_HEIGHT,rect.height(a3)

              jsr        rect_intersects                        ; checks if ship and powerup bounding rectangles intersects
              tst.w      d0                                     ; if d0=0 there is no collision
              beq        .return                                ; so returns immediately
              move.w     #PU_S_INACTIVE,powerup.state(a0)       ; else makes powerup inactive
              bsr        activate_powerup                       ; activates powerup
              move.w     #SFX_ID_POWERUP,d0                     ; plays sound effect
              clr.w      d1                                     ; no loop
              ;jsr        play_sfx
              jsr        play_sample

.return:
              movem.l    (sp)+,d0-a6
              rts


;****************************************************************
; Activates a powerup.
;
; parameters:
; a0 - pointer to powerup instance
; a1 - pointer to ship instance
;****************************************************************
activate_powerup:
              movem.l    d0-a6,-(sp)

              move.w     #PLSHIP_FIRE_2,ship.fire_type(a1)      ; changes ship fire type to fire2

.return:
              movem.l    (sp)+,d0-a6
              rts