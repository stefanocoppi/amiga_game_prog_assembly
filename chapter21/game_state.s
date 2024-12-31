;****************************************************************
; Game states management.
;
; (c) 2024 Stefano Coppi
;****************************************************************

            include    "game_state.i"


;****************************************************************
; VARIABLES
;****************************************************************
            SECTION    code_section,CODE

            xdef       game_state
game_state  dc.w       GAME_STATE_PLAYING         ; current game state

; jump table containing pointers to the game state processing routines
gamestate_table:
            dc.l       update_play_state
            dc.l       update_gameover_state
            dc.l       update_titlescreen_state
            dc.l       0

; jump table containing pointers to the game state initialization routines
init_gamestate_table:
            dc.l       init_play_state
            dc.l       init_gameover_state
            dc.l       init_titlescreen_state
            dc.l       0

                          
;****************************************************************
; SUBROUTINES
;****************************************************************


;****************************************************************
; Updates the current game state
;****************************************************************
            xdef       update_gamestate
update_gamestate:
            movem.l    d0/a0,-(sp)

; uses a jump table to call the update routine for the current game state
            lea        gamestate_table,a0
; the current game state is used as offset of the jump table
            move.w     game_state,d0
; multiplies it x4 because the jump table elements are long
            lsl.w      #2,d0
; calculates the address of the state update routine
            move.l     0(a0,d0.w),a0
; if the address is 0, returns
            move.l     (a0),d0
            tst.l      d0
            beq        .return
; calls the routine
            jsr        (a0)

.return:
            movem.l    (sp)+,d0/a0
            rts


;****************************************************************
; Changes the current game state.
;
; parameters:
; d0.w  - new game state
;****************************************************************
            xdef       change_gamestate
change_gamestate:
            movem.l    d0/a0,-(sp)

; uses a jump table to call the init routine for the current game state
            lea        init_gamestate_table,a0    
; the new game state is used as offset of the jump table
; multiplies it x4 because the jump table elements are long
            lsl.w      #2,d0                      
; calculates the address of the state update routine          
            move.l     0(a0,d0.w),a0
; if the address is 0, returns
            move.l     (a0),d0
            tst.l      d0
            beq        .return
; calls the routine
            jsr        (a0)                       

.return:
            movem.l    (sp)+,d0/a0
            rts