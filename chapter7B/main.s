;****************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 7B - How to enlarge the display window
;
; (c) 2024 Stefano Coppi
;****************************************************************


;****************************************************************
; INCLUDES
;****************************************************************
           incdir     "include"
           include    "hw.i"
           include    "playfield.i"


;****************************************************************
; EXTERNAL REFERENCES
;****************************************************************          
           xref       take_system
           xref       release_system
           xref       init_bplpointers
           xref       bplpointers


;************************************************************************
; Graphics data
;************************************************************************

; segment loaded in CHIP RAM
           SECTION    graphics_data,DATA_C
img_space  incbin     "gfx/image352.raw"      ; image 352 x 256 pixel , 4 bitplanes


;****************************************************************
; MAIN PROGRAM
;****************************************************************
           SECTION    code_section,CODE
main:
           jsr        take_system             ; takes the control of Amiga's hardware

           lea        bplpointers,a1          ; address of bitplane pointers in copperlist
           move.l     #img_space,d0           ; address of image in d0
           move.l     #PF_PLANE_SZ,d1         ; plane size
           move.l     #BPP,d7                 ; number of bitplanes
           jsr        init_bplpointers        ; initializes bitplane pointers to our image
    
mainloop   btst       #6,CIAAPRA              ; left mouse button pressed?
           bne.s      mainloop                ; if not, repeats the loop

           jsr        release_system          ; releases the hw control to the O.S.
           rts

           END