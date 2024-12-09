;************************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 24 - Keyboard input
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
  xref       init_titlescreen_state
  xref       init_ptplayer
  xref       quit_ptplayer
  xref       update_sound_engine
  xref       init_sound
  xref       init_keyboard
  xref       current_key
           
;************************************************************************
; MAIN PROGRAM
;************************************************************************
  SECTION    code_section,CODE

main:
  jsr        take_system                   ; takes the control of Amiga's hardware
  ;jsr        init_ptplayer
  jsr        init_keyboard
  jsr        init_sound
  
  jsr        init_titlescreen_state

mainloop: 
  jsr        wait_vblank                   ; waits for vertical blank
           
  jsr        update_gamestate              ; updates the game state
  jsr        update_sound_engine
           
  ;btst       #6,CIAAPRA                    ; left mouse button pressed?
  cmp.b      #$45,current_key
  bne        mainloop                      ; if not, repeats the loop

  ;move.b     #%10011111,CIAAICR            ; re-enable all CIA IRQs
  
  ;jsr        quit_ptplayer
  jsr        release_system                ; releases the hw control to the O.S.
  rts

  END