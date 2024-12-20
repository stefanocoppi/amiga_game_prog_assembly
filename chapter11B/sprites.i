;************************************************************************
; Sprites management.
;
; (c) 2024 Stefano Coppi
;************************************************************************

           IFND    SPRITES_I
SPRITES_I  SET     1


;****************************************************************
; CONSTANTS
;****************************************************************
SPRITE_WIDTH     equ 64
SPRITE_HEIGHT    equ 70
SPRITE_SIZE      equ SPRITE_HEIGHT*(SPRITE_WIDTH/8)*2+2*4*4
SPRITE_SPEED     equ 1



           ENDC  