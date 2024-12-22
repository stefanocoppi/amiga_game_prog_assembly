;****************************************************************
; Mouse input
;
; (c) 2024 Stefano Coppi
;****************************************************************

            incdir     "include/"
            include    "hw.i"

            xdef       read_mouse
            xdef       mouse_dx
            xdef       mouse_dy
            xdef       mouse_lbtn
            xdef       mouse_rbtn


;****************************************************************
; VARIABLES
;****************************************************************
            SECTION    code_section,CODE

mouse_x     dc.b       0                    ; old mouse position
mouse_y     dc.b       0
mouse_dx    dc.w       0                    ; difference between current and old position of mouse
mouse_dy    dc.w       0
mouse_lbtn  dc.w       0                    ; state of left mouse button: 1 pressed, 0 not pressed
mouse_rbtn  dc.w       0                    ; state of left right button: 1 pressed, 0 not pressed


;****************************************************************
; SUBROUTINES
;****************************************************************


;****************************************************************
; Reads the mouse position.
;****************************************************************
read_mouse:
            movem.l    d0-a6,-(sp)


            move.b     JOY0DAT(a5),d1       ; reads mouse vertical position
            move.b     d1,d0                ; copy 
            sub.b      mouse_y,d1           ; subtracts old position
            ext.w      d1                   ; extends d0 to word
            move.w     d1,mouse_dy          ; saves mouse_dy
            move.b     d0,mouse_y           ; saves position

            move.b     JOY0DAT+1(a5),d1     ; reads mouse vertical position
            move.b     d1,d0                ; copy 
            sub.b      mouse_x,d1           ; subtracts old position
            ext.w      d1                   ; extends d0 to word
            move.w     d1,mouse_dx          ; saves mouse_dx
            move.b     d0,mouse_x           ; saves position

; if bit 6 of CIAAPRA = 0, then left mouse button is pressed
            btst       #6,CIAAPRA
            beq        .lbtn_pressed
            clr.w      mouse_lbtn
            bra        .check_rbtn 
.lbtn_pressed:
            move.w     #1,mouse_lbtn

; if bit 2 of POTINP = 0, then right mouse button is pressed
.check_rbtn:
            btst       #2,potinp(a5)
            beq        .rbtn_pressed
            clr.w      mouse_rbtn
            bra        .return
.rbtn_pressed:
            move.w     #1,mouse_rbtn            

.return:
            movem.l    (sp)+,d0-a6
            rts