;****************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 7 - How to display images on screen
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
; Graphics data
;****************************************************************

; segment loaded in CHIP RAM
           SECTION    graphics_data,DATA_C
img_space  incbin     "gfx/space.raw"         ; image 320 x 256 pixel , 8 bitplanes


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