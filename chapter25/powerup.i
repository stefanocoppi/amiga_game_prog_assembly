;****************************************************************
; Power Ups management
;
; (c) 2024 Stefano Coppi
;****************************************************************

                   IFND       POWERUP_I
POWERUP_I          SET        1


;****************************************************************
; DATA STRUCTURES
;****************************************************************

; powerup
                   rsreset
powerup.x          rs.w       1                            
powerup.y          rs.w       1
powerup.speed      rs.w       1
powerup.width      rs.w       1
powerup.height     rs.w       1
powerup.ssheet_c   rs.w       1            ; spritesheet column of the bob
powerup.ssheet_r   rs.w       1            ; spritesheet row of the bob
powerup.ssheet_w   rs.w       1            ; spritesheet width in pixels
powerup.ssheet_h   rs.w       1            ; spritesheet height in pixels
powerup.imgdata    rs.l       1            ; image data address
powerup.mask       rs.l       1            ; mask address
powerup.state      rs.w       1            ; current state: active, inactive
powerup.type       rs.w       1            ; type of powerup: none, satellite, r_laser, aa_laser
powerup.vis_timer  rs.w       1            ; timer to count the time the powerup is visible
powerup.length     rs.b       0 


;****************************************************************
; CONSTANTS
;****************************************************************

; states:
PU_S_INACTIVE   equ 0                      ; inactive: not visible and collisions disabled
PU_S_ACTIVE     equ 1                      ; active: visible and collisions enabled

; types:
PU_TYPE_NONE    equ 0                      ; the alien doesn't releases any powerup
PU_TYPE_FIRE2   equ 1                      ; powerup that activates a new powerful fire


PU_VIS_DUR      equ (2*50)                 ; visibility duration (5 sec * 50 frames)
PU_FRAME_SZ     equ 320                    ; frame size (bytes)
PU_MASK_SZ      equ 80                     ; mask size (bytes)
PU_WIDTH        equ 64                     ; width (pixels)
PU_HEIGHT       equ 64                     ; height (pixels)

                   ENDC