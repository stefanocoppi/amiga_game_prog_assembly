;************************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 21 - Game Over
;
;
; (c) 2024 Stefano Coppi
;************************************************************************

  incdir     "include"
  include    "hw.i"
  

  xref       take_system,release_system
  xref       wait_vblank
  xref       update_gamestate
  xref       init_play_state
           
;************************************************************************
; MAIN PROGRAM
;************************************************************************
  SECTION    code_section,CODE

main:
  jsr        take_system                   ; takes the control of Amiga's hardware
  jsr        init_play_state

mainloop: 
  jsr        wait_vblank                   ; waits for vertical blank
           
  jsr        update_gamestate              ; updates the game state
           
  btst       #6,CIAAPRA                    ; left mouse button pressed?
  bne        mainloop                      ; if not, repeats the loop

  jsr        release_system                ; releases the hw control to the O.S.
  rts

  END