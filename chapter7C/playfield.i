;****************************************************************
; Playfield management.
;
; (c) 2024 Stefano Coppi
;****************************************************************

             IFND    PLAYFIELD_I
PLAYFIELD_I  SET     1


;****************************************************************
; CONSTANTS
;****************************************************************


BPP           equ 4
WINDOW_WIDTH  equ 640
WINDOW_HEIGHT equ 256
PF_PLANE_SZ   equ WINDOW_HEIGHT*(WINDOW_WIDTH/8)

             ENDC  