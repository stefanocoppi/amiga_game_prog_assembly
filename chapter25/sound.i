;****************************************************************
; Sound management
;
; (c) 2024 Stefano Coppi
;****************************************************************

                 IFND       SOUND_I
SOUND_I          SET        1

;****************************************************************
; CONSTANTS
;****************************************************************

; sound
SFX_PERIOD        equ 443              ; 8000 Hz
SFX_VOLUME        equ 32

; sound effects priorities (higher value -> higher priority)
SFX_PRI_START     equ 127         
SFX_PRI_BULLET    equ 127 
SFX_PRI_EXPLOSION equ 127
SFX_PRI_POWERUP   equ 127
SFX_PRI_GAMEOVER  equ 127

; sound effects id
SFX_ID_START      equ 0
SFX_ID_BASE_FIRE  equ 1
SFX_ID_RLASER     equ 2
SFX_ID_AALASER    equ 3
SFX_ID_BEAMFIRE   equ 4
SFX_ID_EXPLOSION  equ 5
SFX_ID_HIT        equ 6
SFX_ID_POWERUP    equ 7
SFX_ID_GAMEOVER   equ 8
SFX_ID_LEVELMUSIC equ 9
SFX_ID_TITLEMUSIC equ 10


;****************************************************************
; DATA STRUCTURES
;****************************************************************
; Sound effects structure
                 rsreset
sfx_ptr          rs.l       1          ; pointer to samples
sfx_len          rs.w       1          ; samples length in word
sfx_per          rs.w       1          ; samples period
sfx_vol          rs.w       1          ; volume 0-64
sfx_cha          rs.b       1          ; channel 0-3
sfx_pri          rs.b       1          ; priority
sfx_sizeof       rs.b       0

                 rsreset
sfx_ch0_counter  rs.w       1
sfx_ch1_counter  rs.w       1
sfx_ch2_counter  rs.w       1
sfx_ch3_counter  rs.w       1
sfx_length       rs.b       0

                 ENDC