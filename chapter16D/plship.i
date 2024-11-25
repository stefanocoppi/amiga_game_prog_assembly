;****************************************************************
; Player's ship
;
; (c) 2024 Stefano Coppi
;****************************************************************

                    IFND       PLSHIP_I
PLSHIP_I            SET        1

                    include    "playfield.i"
                    include    "bob.i"

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
BASE_FIRE_INTERVAL     equ 7                     ; time interval between two shots


                    ENDC