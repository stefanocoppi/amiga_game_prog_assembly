;****************************************************************
; Game states management.
;
; (c) 2024 Stefano Coppi
;****************************************************************

              IFND    GAMESTATES_I
GAMESTATES_I  SET     1

;****************************************************************
; CONSTANTS
;****************************************************************

; game states:
GAME_STATE_PLAYING     equ 0          ; the state in which the game can be played
GAME_STATE_GAMEOVER    equ 1          ; the game is ended
GAME_STATE_TITLESCREEN equ 2          ; the title screen is shown

; game state transitions:
;
; TITLESCREEN   -> PLAYING     : when the player presses the fire button
; PLAYING       -> GAMEOVER    : when player's ship energy is <0
; GAMEOVER      -> TITLESCREEN : after 5 seconds


              ENDC