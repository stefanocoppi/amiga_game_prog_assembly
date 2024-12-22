;****************************************************************
; Collisions
;
; (c) 2024 Stefano Coppi
;****************************************************************

                 incdir     "include"
                 include    "hw.i"
                 include    "collisions.i"
                 include    "shots.i"
                 include    "enemies.i"
                 include    "bob.i"
                 include    "plship.i"
                 include    "scroll_bgnd.i"

                 xdef       check_coll_shots_enemies
                 xdef       check_coll_shots_plship
                 xdef       check_coll_enemy_plship
                 xdef       check_coll_plship_map
                 xdef       ship_coll_plane
                 xdef       rect1,rect2
                 xdef       rect_intersects

                 xref       ship_shots,enemies_array
                 xref       plship_explode,enemy_explode
                 xref       player_ship_mask,wait_blitter
                 xref       draw_hud_bar

;****************************************************************
; BSS DATA
;****************************************************************
                 SECTION    bss_data,BSS_C

rect1            ds.b       rect.length                                    ; rectangles used for collision checking
rect2            ds.b       rect.length

ship_coll_plane  ds.b       PF1_PLANE_SZ                                   ; plane used for pixel-perfect collisions between player's ship and map


                 SECTION    code_section,CODE
;****************************************************************
; Check if two rectangles r1,r2 intersects.
;
; Input:
; a2 - address of rectangle r1 structure
; a3 - address of rectangle r2 structure
;
; Output:
; d0.w 1 if the two rectangles intersects, 0 otherwise.
;****************************************************************
rect_intersects:
                 movem.l    d1-a6,-(sp)

                 clr.w      d0
                 move.w     rect.x(a3),d1                                  ; r2.left
                 move.w     rect.x(a2),d2       
                 add.w      rect.width(a2),d2                              ; r1.right
                 cmp.w      d2,d1                                          ; r2.left - r1.right
                 bhi        .return                                        ; if r2.left > r1.right the rectangles don't intersect
                 move.w     rect.x(a3),d1
                 add.w      rect.width(a3),d1                              ; r2.right
                 move.w     rect.x(a2),d2                                  ; r1.left
                 cmp.w      d2,d1                                          ; r2.right - r1.left
                 blo        .return                                        ; if r2.right < r1.left the rectangles don't intersect
                 move.w     rect.y(a3),d1                                  ; r2.top
                 move.w     rect.y(a2),d2
                 add.w      rect.height(a2),d2                             ; r1.bottom
                 cmp.w      d2,d1                                          ; r2.top - r1.bottom
                 bhi        .return                                        ; if r2.top > r1.bottom the rectangles don't intersect
                 move.w     rect.y(a2),d1                                  ; r1.top
                 move.w     rect.y(a3),d2
                 add.w      rect.height(a3),d2                             ; r2.bottom
                 cmp.w      d1,d2                                          ; r2.bottom - r1.top
                 blo        .return                                        ; if r2.bottom < r1.top the rectangles don't intersect 
                 move.w     #1,d0                                          ; else the rectangles intersect

.return:
                 movem.l    (sp)+,d1-a6
                 rts


;****************************************************************
; Checks for collisions between player's ship shots and enemies.
;****************************************************************
check_coll_shots_enemies:
                 movem.l    d0-a6,-(sp)

; iterates over all active player's ship shots
;     iterates over all active enemies
;         checks collision between current shot and current enemy
;             setups bounding rectangle for current shot
;             setups bounding rectangle for current enemy
;             checks if current enemy bounding rectangle intersects with current shot bounding rectangle
;         collision response

                 lea        ship_shots,a0
                 move.l     #PLSHIP_MAX_SHOTS-1,d7
; iterates over all active player's ship shots
.shots_loop:
                 cmp.w      #SHOT_STATE_ACTIVE,shot.state(a0)              ; is current shot active?
                 bne        .next_shot                                     ; if not, move on the next shot
    
                 lea        enemies_array,a1
                 move.l     #NUM_ENEMIES-1,d6
; iterates over all active enemies
.enemies_loop:
                 cmp.w      #ENEMY_STATE_INACTIVE,enemy.state(a1)          ; enemy inactive?
                 beq        .next_enemy                                    ; if yes, moves on the next enemy

       ; checks collision between current shot and current enemy
              ; setups bounding rectangle for current shot
                 lea        rect1,a3
                 lea        shot.bbox(a0),a4
                 move.w     shot.x(a0),rect.x(a3)
                 move.w     rect.x(a4),d0
                 add.w      d0,rect.x(a3)
                 move.w     shot.y(a0),rect.y(a3)
                 move.w     rect.y(a4),d0
                 add.w      d0,rect.y(a3)
                 move.w     rect.width(a4),rect.width(a3)
                 move.w     rect.height(a4),rect.height(a3)
              ; setups bounding rectangle for current enemy
                 lea        rect2,a2
                 lea        enemy.bbox(a1),a4
                 move.w     bob.x(a1),rect.x(a2)
                 move.w     rect.x(a4),d0                 
                 add.w      d0,rect.x(a2)     
                 move.w     bob.y(a1),rect.y(a2)
                 move.w     rect.y(a4),d0                 
                 add.w      d0,rect.y(a2)
                 move.w     rect.width(a4),rect.width(a2)
                 move.w     rect.height(a4),rect.height(a2)
              ; checks if current enemy bounding rectangle intersects with current shot bounding rectangle
                 bsr        rect_intersects                                          
              ; response to collision
                 bsr        coll_response_shots_enemies                                         

.next_enemy:
                 add.l      #enemy.length,a1
                 dbra       d6,.enemies_loop

.next_shot:
                 add.l      #shot.length,a0
                 dbra       d7,.shots_loop

.return:
                 movem.l    (sp)+,d0-a6
                 rts


;****************************************************************
; Responds to collisions between player's ship shots and enemies.
;
; parameters:
; d0.w - collision result: 1 if there is a collision, 0 otherwise
; a0 - pointer to shot instance
; a1 - pointer to enemy instance
;****************************************************************
coll_response_shots_enemies:
                 tst.w      d0                                             ; if d0 = 0 there is no collision
                 beq        .return                                        ; and therefore returns
.collision:
                 move.w     shot.anim_duration(a0),shot.anim_timer(a0)     ; resets anim timer
                 move.w     #0,shot.ssheet_c(a0)                           ; sets hit animation frame
                 add.w      #1,shot.ssheet_r(a0)
                 move.w     #SHOT_STATE_HIT,shot.state(a0)                 ; changes state to hit
                
                 move.w     #ENEMY_STATE_HIT,enemy.state(a1)
                 move.w     #ENEMY_FLASH_DURATION,enemy.flash_timer(a1)
                 move.w     #ENEMY_HIT_DURATION,enemy.hit_timer(a1)
                 move.w     shot.damage(a0),d0
                 sub.w      d0,enemy.energy(a1)
                 ble        .explode
                 bra        .return
.explode:
                 bsr        enemy_explode
.return:
                 rts





;****************************************************************
; Checks for collisions between enemy shots and player's ship.
;****************************************************************
check_coll_shots_plship:
                 movem.l    d0-a6,-(sp)

; iterates over all active enemy shots
;     checks collision between current shot and player's ship
;         collision response

                 lea        enemy_shots,a0
                 move.l     #ENEMY_MAX_SHOTS-1,d7
; iterates over enemy shots
.shots_loop:
                 cmp.w      #SHOT_STATE_ACTIVE,shot.state(a0)              ; is current shot active?
                 bne        .next_shot                                     ; if not, move on the next shot
    
; setups bounding rectangle for current shot
                 lea        rect1,a3
                 lea        shot.bbox(a0),a4
                 move.w     shot.x(a0),rect.x(a3)
                 move.w     rect.x(a4),d0
                 add.w      d0,rect.x(a3)
                 move.w     shot.y(a0),rect.y(a3)
                 move.w     rect.y(a4),d0
                 add.w      d0,rect.y(a3)
                 move.w     rect.width(a4),rect.width(a3)
                 move.w     rect.height(a4),rect.height(a3)

; setups bounding rectangle for player's ship
                 lea        player_ship,a1
                 lea        rect2,a2
                 lea        ship.bbox(a1),a4
                 move.w     bob.x(a1),rect.x(a2)
                 move.w     rect.x(a4),d0                 
                 add.w      d0,rect.x(a2)     
                 move.w     bob.y(a1),rect.y(a2)
                 move.w     rect.y(a4),d0                 
                 add.w      d0,rect.y(a2)
                 move.w     rect.width(a4),rect.width(a2)
                 move.w     rect.height(a4),rect.height(a2)
; checks if player's ship bounding rectangle intersects with current shot bounding rectangle
                 bsr        rect_intersects                                          
; response to collision
                 bsr        coll_response_shots_plship                                         

.next_shot:
                 add.l      #shot.length,a0
                 dbra       d7,.shots_loop

.return:
                 movem.l    (sp)+,d0-a6
                 rts


;****************************************************************
; Responds to collisions between enemy shots and player's ship.
;
; parameters:
; d0.w - collision result: 1 if there is a collision, 0 otherwise
; a0 - pointer to shot instance
; a1 - pointer to player's ship instance
;****************************************************************
coll_response_shots_plship:
                     ;movem.l    d0-a6,-(sp)

; if d0 = 0 there is no collision and therefore returns
                 tst.w      d0                                                       
                 beq        .return                                                
.collision:
                      ;move.w     #$F00,COLOR00(a5)
; changes the shot state to idle
                 move.w     #SHOT_STATE_IDLE,shot.state(a0)                          
; changes player's ship state to hit
                 move.w     #PLSHIP_STATE_HIT,ship.state(a1)                         
                 move.w     #PLSHIP_FLASH_DURATION,ship.flash_timer(a1)
                 move.w     #PLSHIP_HIT_DURATION,ship.hit_timer(a1)
; subtracts energy from the player's ship
                 move.w     shot.damage(a0),d0
                 sub.w      d0,ship.energy(a1)

                 move.w     ship.energy(a1),d0
                 jsr        draw_hud_bar

; if energy <= 0 then makes explode the player's ship
                 tst.w      ship.energy(a1)
                 ble        .explode
                 bra        .return
.explode:
                 jsr        plship_explode
.return:
                     ;movem.l    (sp)+,d0-a6
                 rts


;****************************************************************
; Checks for collisions between enemy and player's ship.
;****************************************************************
check_coll_enemy_plship:
                 movem.l    d0-a6,-(sp)

; iterates over all active enemy
;     checks collision between current enemy and player's ship
;         collision response

                 lea        player_ship,a1                                 ; bounding rectangle for player's ship
                 cmp.w      #PLSHIP_STATE_NORMAL,ship.state(a1)            ; state is normal?
                 bne        .return                                        ; if not, doesn't checks for collisions

                 lea        enemies_array,a0
                 move.l     #NUM_ENEMIES-1,d7

.enemies_loop:
                 cmp.w      #ENEMY_STATE_INACTIVE,enemy.state(a0)          ; is current enemy inactive?
                 beq        .next_enemy                                    ; if yes, move on the next enemy
    
                 lea        rect1,a3                                       ; bounding rectangle for current enemy
                 lea        enemy.bbox(a0),a4
                 move.w     bob.x(a0),rect.x(a3)
                 move.w     rect.x(a4),d0                                  ; enemy.bbox.x
                 add.w      d0,rect.x(a3)                                  ; rect.x = bob.x + enemy.bbox.x
                 move.w     bob.y(a0),rect.y(a3)
                 move.w     rect.y(a4),d0                                  ; enemy.bbox.y
                 add.w      d0,rect.y(a3)                                  ; rect.y = bob.y + enemy.bbox.y
                 move.w     rect.width(a4),rect.width(a3)                  ; rect.width = enemy.bbox.width
                 move.w     rect.height(a4),rect.height(a3)                ; rect.height = enemy.bbox.height

                 lea        rect2,a2
                 lea        ship.bbox(a1),a4
                 move.w     bob.x(a1),rect.x(a2)
                 move.w     rect.x(a4),d0                 
                 add.w      d0,rect.x(a2)                                  ; rect2.x = ship.x + ship.bbox.x
                 move.w     bob.y(a1),rect.y(a2)
                 move.w     rect.y(a4),d0                 
                 add.w      d0,rect.y(a2)                                  ; rect2.y = ship.y + ship.bbox.y
                 move.w     rect.width(a4),rect.width(a2)                  ; rect2.width = ship.bbox.width
                 move.w     rect.height(a4),rect.height(a2)                ; rect2.height = ship.bbox.height

                 bsr        rect_intersects                                ; checks if player's ship bbox intersects enemy bbox                                 

                 bsr        coll_response_enemy_plship                     ; collision response                                 

.next_enemy:
                 add.l      #enemy.length,a0
                 dbra       d7,.enemies_loop

.return:
                 movem.l    (sp)+,d0-a6
                 rts


;****************************************************************
; Responds to collisions between enemy and player's ship.
;
; parameters:
; d0.w - collision result: 1 if there is a collision, 0 otherwise
; a0 - pointer to enemy instance
; a1 - pointer to player's ship instance
;****************************************************************
coll_response_enemy_plship:
                 tst.w      d0                                             ; d0 = 0?                                      
                 beq        .return                                        ; if yes, there is no collision and therefore returns
.collision:
                 move.w     #PLSHIP_STATE_HIT,ship.state(a1)               ; changes player's ship state to hit                 
                 move.w     #PLSHIP_FLASH_DURATION,ship.flash_timer(a1)    ; resets flash timer
                 move.w     #PLSHIP_HIT_DURATION,ship.hit_timer(a1)        ; resets hit timer
                                       
                 sub.w      #5,ship.energy(a1)                             ; subtracts energy from the player's ship

                 move.w     ship.energy(a1),d0
                 jsr        draw_hud_bar

                 tst.w      ship.energy(a1)
                 ble        .explode                                       ; if energy <= 0 then makes explode the player's ship
                 bra        .return
.explode:
                 bsr        plship_explode
.return:
                 rts


;****************************************************************
; Checks for collisions between player's ship and map.
;****************************************************************
check_coll_plship_map:
                 movem.l    d0-a6,-(sp)

                 lea        player_ship,a0

                 cmp.w      #PLSHIP_STATE_NORMAL,ship.state(a0)            ; ship state is normal?
                 bne        .return                                        ; if not, doesn't check for collisions

; performs an AND blitter operation between the ship mask and a collision plane containing the background tiles

                 lea        player_ship_mask,a1

; calculates ship address on collision plane
                 lea        ship_coll_plane,a2                             ; destination address
                 move.w     bob.y(a0),d1                                   ; ship y position
                 mulu.w     #PF1_ROW_SIZE,d1                               ; offset Y = y * PF1_ROW_SIZE
                 add.l      d1,a2                                          ; adds offset Y to destination address
                 move.w     bob.x(a0),d0                                   ; ship x position
                 add.w      bgnd_x,d0                                      ; adds viewport position
                 sub.w      #CLIP_LEFT,d0                                  ; subtracts CLIP_LEFT because there is no invisible clipping edge on the collision plane
                 move.w     d0,d6                                          ; copies the x
                 lsr.w      #3,d0                                          ; offset x=x/8
                 and.w      #$fffe,d0                                      ; makes x even
                 add.w      d0,a2                                          ; adds offset x to destination address
                      
; calculates the shift value
                 and.w      #$000f,d6                                      ; selects the first 4 bits of the X
                 lsl.w      #8,d6                                          ; shifts the shift value to the high nibble
                 lsl.w      #4,d6                                          ; in order to have the value of shift to be inserted in BLTCON0
                 or.w       #$0aa0,d6                                      ; value to be inserted in BLTCON0: enables channels A and C, minterms = AND

; calculates the modulus of channel C
                 move.w     #(PLSHIP_WIDTH/8),d0                           ; ship width in bytes
                 add.w      #2,d0                                          ; adds 2 to the width in bytes, due to the shift
                 move.w     #PF1_ROW_SIZE,d4                               ; collision plane width in bytes
                 sub.w      d0,d4                                          ; modulus = coll.plane width - bob width in d4

; calculates blit size
                 move.w     #PLSHIP_HEIGHT,d3                              ; ship height in px
                 lsl.w      #6,d3                                          ; height*64
                 lsr.w      #1,d0                                          ; width/2 (in word)
                 or         d0,d3                                          ; combines the dimensions into the value to be entered in BLTSIZE
                          
                 jsr        wait_blitter
                 move.w     #$ffff,BLTAFWM(a5)                             ; lets everything go through
                 move.w     #$0000,BLTALWM(a5)                             ; clears the last word of channel A
                 move.w     #0,BLTCON1(a5)              
                 move.w     d6,BLTCON0(a5)              
                 move.w     #$fffe,BLTAMOD(a5)                             ; modulo -2 to go back by 2 bytes due to the extra word introduced for the shift
                 move.w     d4,BLTCMOD(a5) 
                 move.l     a1,BLTAPT(a5)                                  ; channel A: ship mask
                 move.l     a2,BLTCPT(a5)                                  ; channel C: ship collision plane
                 move.w     d3,BLTSIZE(a5)                                 ; set the size and starts the blitter
                 jsr        wait_blitter

                 move.w     DMACONR(a5),d0
                 btst.l     #13,d0                                         ; tests the BZERO flag of DMACONR
                 beq        .yes_coll                                      ; if it is zero then there has been a collision
                 bra        .return
.yes_coll:
                 move.w     #1,d0                                          ; 1 indicates that there has been a collision
                 lea        player_ship,a0
                 bsr        coll_response_plship_map

.return:
                 movem.l    (sp)+,d0-a6
                 rts


;****************************************************************
; Responds to collisions between player's ship and map.
;
; parameters:
; d0.w - collision result: 1 if there is a collision, 0 otherwise
; a0 - pointer to player's ship instance
;****************************************************************
coll_response_plship_map:
                 tst.w      d0                                             ; d0 = 0?                                      
                 beq        .return                                        ; if yes, there is no collision and therefore returns
.collision:
                 move.w     #PLSHIP_STATE_HIT,ship.state(a0)               ; changes player's ship state to hit                 
                 move.w     #PLSHIP_FLASH_DURATION,ship.flash_timer(a0)    ; resets flash timer
                 move.w     #PLSHIP_HIT_DURATION,ship.hit_timer(a0)        ; resets hit timer
                                       
                 sub.w      #5,ship.energy(a0)                             ; subtracts energy from the player's ship

                 move.w     ship.energy(a0),d0
                 jsr        draw_hud_bar
                 
                 tst.w      ship.energy(a0)
                 ble        .explode                                       ; if energy <= 0 then makes explode the player's ship
                 bra        .return
.explode:
                 move.l     a0,a1
                 bsr        plship_explode
.return:
                 rts