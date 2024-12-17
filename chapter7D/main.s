;****************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 7D - Interlaced mode
;
; (c) 2024 Stefano Coppi
;****************************************************************

     incdir     "include"
     include    "hw.i"
     include    "playfield.i"


          
     xref       take_system
     xref       release_system
     xref       init_bplpointers
     xref       bplpointers

;************************************************************************
; Graphics data
;************************************************************************

; segment loaded in CHIP RAM
     SECTION    graphics_data,DATA_C
img  incbin     "gfx/image640.raw"      ; image 640 x 256 pixel , 4 bitplanes


     SECTION    code_section,CODE

;****************************************************************
; MAIN PROGRAM
;****************************************************************
main:
     jsr        take_system             ; takes the control of Amiga's hardware

mainloop:
     lea        bplpointers,a1          ; address of bitplane pointers in copperlist
     move.l     #img,d0                 ; address of image in d0
     move.l     #PF_PLANE_SZ,d1         ; plane size
     move.l     #BPP,d7                 ; number of bitplanes

     move.w     VPOSR(a5),d2
     btst.l     #15,d2
     beq        .oddlines
     add.l      #80,d0
.oddlines:
     jsr        init_bplpointers        ; initializes bitplane pointers to our image

     btst       #6,CIAAPRA              ; left mouse button pressed?
     bne.s      mainloop                ; if not, repeats the loop

     jsr        release_system          ; releases the hw control to the O.S.
     rts

     END