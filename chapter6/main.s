;****************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 6 - The Copper and copperlist
;
; (c) 2024 Stefano Coppi
;****************************************************************

          incdir     "include"
          include    "hw.i"


          
          xref       take_system
          xref       release_system

          SECTION    code_section,CODE

;****************************************************************
; MAIN PROGRAM
;****************************************************************
main:
          jsr        take_system          ; takes the control of Amiga's hardware
    
mainloop  btst       #6,CIAAPRA           ; left mouse button pressed?
          bne.s      mainloop             ; if not, repeats the loop

          jsr        release_system       ; releases the hw control to the O.S.
          rts

          END