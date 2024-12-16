;****************************************************************
; Player's ship
;
; (c) 2024 Stefano Coppi
;****************************************************************

                    IFND       PLSHIP_I
PLSHIP_I            SET        1

                    include    "playfield.i"
                    include    "bob.i"
                    include    "collisions.i"

;****************************************************************
; DATA STRUCTURES
;****************************************************************

; player's ship
                    rsreset
ship.bob            rs.b       bob.length
ship.anim_duration  rs.w       1                 ; duration of animation in frames
ship.anim_timer     rs.w       1                 ; timer for animation
ship.fire_timer     rs.w       1                 ; timer to measure the interval between two shots
ship.fire_delay     rs.w       1                 ; time interval betweeen two shots (in frames)
ship.bbox           rs.b       rect.length       ; bounding box for collisions
ship.visible        rs.w       1                 ; 0 not visible, $ffff visible
ship.flash_timer    rs.w       1                 ; measures flashing duration
ship.hit_timer      rs.w       1                 ; timer used to measure hit state duration
ship.energy         rs.w       1                 ; amount of energy. When reaches zero, the ship is destroyed.
ship.state          rs.w       1
ship.fire_type      rs.w       1
ship.length         rs.b       0 


;****************************************************************
; CONSTANTS
;****************************************************************

PLSHIP_WIDTH           equ 64
PLSHIP_HEIGHT          equ 28
PLSHIP_X0              equ CLIP_LEFT+8
PLSHIP_Y0              equ 81
PLSHIP_XMIN            equ CLIP_LEFT+8
PLSHIP_XMAX            equ CLIP_LEFT+VIEWPORT_WIDTH-PLSHIP_WIDTH
PLSHIP_YMIN            equ 0
PLSHIP_YMAX            equ VIEWPORT_HEIGHT-PLSHIP_HEIGHT
PLSHIP_STATE_NORMAL    equ 0
PLSHIP_STATE_HIT       equ 1
PLSHIP_STATE_EXPLOSION equ 2
PLSHIP_STATE_IDLE      equ 3
PLSHIP_FLASH_DURATION  equ 1
PLSHIP_HIT_DURATION    equ 10
FIRE_INTERVAL          equ 7                     ; time interval between two shots
PLSHIP_MAX_ENERGY      equ 20                    ; 20
PLSHIP_FIRE_BASE       equ 0
PLSHIP_FIRE_2          equ 1

                    ENDC