;****************************************************************
; Shots
;
; (c) 2024 Stefano Coppi
;****************************************************************

                    IFND       SHOTS_I
SHOTS_I             SET        1

                    include    "playfield.i"

;****************************************************************
; DATA STRUCTURES
;****************************************************************
; shot fired from ship and enemies
                    rsreset
shot.x              rs.w       1                ; position
shot.y              rs.w       1
shot.speed          rs.w       1                                                      
shot.width          rs.w       1                ; width in px
shot.height         rs.w       1                ; height in px
shot.ssheet_c       rs.w       1                ; spritesheet column of the shot
shot.ssheet_r       rs.w       1                ; spritesheet row of the shot
shot.ssheet_w       rs.w       1                ; spritesheet width in pixels
shot.ssheet_h       rs.w       1                ; spritesheet height in pixels
shot.imgdata        rs.l       1                ; image data address
shot.mask           rs.l       1                ; mask address
shot.state          rs.w       1                ; current state
shot.num_frames     rs.w       1                ; number of animation frames
shot.anim_duration  rs.w       1                ; animation duration (in frames)
shot.anim_timer     rs.w       1                ; animation timer
shot.damage         rs.w       1                ; amount of damage dealt
shot.length         rs.b       0

;****************************************************************
; CONSTANTS
;****************************************************************
SHIP_SHOT_SPEED   equ 10
SHIP_SHOT_WIDTH   equ 64
SHIP_SHOT_HEIGHT  equ 64
SHIP_SHOT_DAMAGE  equ 5
SHOT_STATE_IDLE   equ 0                         ; state where a shot isn't drawn and isn't updated
SHOT_STATE_ACTIVE equ 1                         ; state where a shot is drawn and updated
SHOT_STATE_LAUNCH equ 2                         ; state where a shot throwing animation is played
SHOT_STATE_HIT    equ 3                         ; the shot hits the target
SHOT_MAX_X        equ VIEWPORT_WIDTH+CLIP_LEFT
SHOT_MIN_X        equ 0
PLSHIP_MAX_SHOTS  equ 6
ENEMY_MAX_SHOTS   equ 5
ENEMY_SHOT_SPEED  equ 10
ENEMY_SHOT_WIDTH  equ 64
ENEMY_SHOT_HEIGHT equ 32

                    ENDC