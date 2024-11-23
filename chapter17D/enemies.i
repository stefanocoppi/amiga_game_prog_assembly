;****************************************************************
; Enemies
;
; (c) 2024 Stefano Coppi
;****************************************************************

                     IFND       ENEMIES_I
ENEMIES_I            SET        1

                     include    "bob.i"
                     include    "collisions.i"

;****************************************************************
; DATA STRUCTURES
;****************************************************************

; enemy
                     rsreset
enemy.bob            rs.b       bob.length
enemy.anim_duration  rs.w       1                      ; duration of animation in frames
enemy.anim_timer     rs.w       1                      ; timer for animation
enemy.num_frames     rs.w       1                      ; number of animation frames
enemy.state          rs.w       1
enemy.score          rs.w       1                      ; score given when enemy is destroyed by the player
enemy.energy         rs.w       1                      ; amount of energy. When reaches zero, the alien is destroyed.
enemy.map_position   rs.w       1                      ; when the camera reaches this position on the map, the enemy will activate
enemy.tx             rs.w       1                      ; target x coordinate
enemy.ty             rs.w       1                      ; target y coordinate
enemy.cmd_pointer    rs.w       1                      ; pointer to the next command
enemy.pause_timer    rs.w       1
enemy.bbox           rs.b       rect.length            ; bounding box
enemy.flash_timer    rs.w       1
enemy.hit_timer      rs.w       1                      ; timer used to measure hit state duration
enemy.visible        rs.w       1
enemy.fire_offx      rs.w       1                      ; x offset where to place the fire shot
enemy.fire_offy      rs.w       1                      ; y offset where to place the fire shot
enemy.cmd_list       rs.b       ENEMY_CMD_LIST_SIZE    ; commands list
enemy.length         rs.b       0


;************************************************************************
; CONSTANTS
;************************************************************************

ENEMY_CMD_LIST_SIZE   equ 40
NUM_ENEMIES           equ 18-3
ENEMY_STATE_INACTIVE  equ 0
ENEMY_STATE_ACTIVE    equ 1
ENEMY_STATE_PAUSE     equ 2
ENEMY_STATE_HIT       equ 3                            ; the enemy has been hit by a shot
ENEMY_STATE_EXPLOSION equ 4                            ; the enemy explodes
ENEMY_STATE_GOTOXY    equ 5                            ; the enemy moves toward a target point
ENEMY_CMD_END         equ 0
ENEMY_CMD_GOTO        equ 1
ENEMY_CMD_PAUSE       equ 2
ENEMY_CMD_FIRE        equ 3
ENEMY_FLASH_DURATION  equ 2
ENEMY_HIT_DURATION    equ 20

                     ENDC