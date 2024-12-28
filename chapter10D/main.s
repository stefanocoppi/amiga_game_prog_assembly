;************************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 10D - Multi-directional scrolling
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
  jsr        init_map

mainloop: 
  jsr        wait_vblank                   ; waits for vertical blank

  jsr        move_map_with_joy
  jsr        update_map

  btst       #6,CIAAPRA                    ; left mouse button pressed?
  bne        mainloop                      ; if not, repeats the loop
  
  jsr        release_system                ; releases the hw control to the O.S.
  rts

  END