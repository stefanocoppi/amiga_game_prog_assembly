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
BPP              equ 8
WINDOW_WIDTH     equ 320
WINDOW_HEIGHT    equ 256
PF_PLANE_SZ      equ WINDOW_HEIGHT*(WINDOW_WIDTH/8)
PF_ROW_SIZE      equ (WINDOW_WIDTH/8)


             ENDC  