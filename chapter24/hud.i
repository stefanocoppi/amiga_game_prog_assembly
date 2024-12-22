;****************************************************************
; HUD (Head Up Display)
;
; (c) 2024 Stefano Coppi
;****************************************************************

       IFND    HUD_I
HUD_I  SET     1

;****************************************************************
; CONSTANTS
;****************************************************************
HUD_WIDTH    equ 320
HUD_HEIGHT   equ 64
HUD_ROW_SIZE equ HUD_WIDTH/8
HUD_PLANE_SZ equ HUD_ROW_SIZE*HUD_HEIGHT
HUD_BPP      equ 5


       ENDC