;************************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 22 - Sound
;
;
; (c) 2024 Stefano Coppi
;************************************************************************

  incdir     "include"
  include    "hw.i"
  
     
;************************************************************************
; MAIN PROGRAM
;************************************************************************
  SECTION    code_section,CODE

main:
  jsr        take_system                   ; takes the control of Amiga's hardware
  jsr        init_ptplayer
  ;jsr        init_sound
  jsr        init_titlescreen_state

mainloop: 
  jsr        wait_vblank                   ; waits for vertical blank
           
  jsr        update_gamestate              ; updates the game state
  ;jsr        update_sound_engine
           
  btst       #6,CIAAPRA                    ; left mouse button pressed?
  bne        mainloop                      ; if not, repeats the loop

  jsr        quit_ptplayer
  jsr        release_system                ; releases the hw control to the O.S.
  rts

  END