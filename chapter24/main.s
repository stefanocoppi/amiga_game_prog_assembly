;************************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 24 - Power Ups
;
;
; (c) 2024 Stefano Coppi
;************************************************************************

  incdir     "include"
  include    "hw.i"
  include    "keyboard.i"
  

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
  xref       read_mouse
  xref       mouse_rbtn
           
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

  jsr        read_mouse                    ; reads mouse position         
  jsr        update_gamestate              ; updates the game state
  jsr        update_sound_engine
           
  cmp.w      #1,mouse_rbtn                 ; right mouse button pressed?
  beq        .quit                         ; if yes, exits the mainloop
  cmp.b      #KEY_ESC,current_key          ; ESC pressed?
  bne        mainloop                      ; if not, repeats the loop

.quit:
  ;jsr        quit_ptplayer
  jsr        release_system                ; releases the hw control to the O.S.
  rts

  END