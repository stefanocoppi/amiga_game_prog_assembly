;************************************************************************
; Blitter Objects (Bobs) management
;
; (c) 2024 Stefano Coppi
;************************************************************************

;************************************************************************
; INCLUDES
;************************************************************************
             incdir     "include"
             include    "hw.i"
             include    "playfield.i"


;************************************************************************
; BSS DATA
;************************************************************************
             SECTION    bss_data,BSS_C

             xdef       dbuffer1
dbuffer1     ds.b       (PF_PLANE_SZ*BPP)          ; display buffers used for double buffering
dbuffer2     ds.b       (PF_PLANE_SZ*BPP)   


;************************************************************************
; VARIABLES
;************************************************************************
             SECTION    code_section,CODE
             
view_buffer  dc.l       dbuffer1                   ; buffer displayed on screen
             
             xdef       draw_buffer
draw_buffer  dc.l       dbuffer2                   ; drawing buffer (not visible)


;************************************************************************
; SUBROUTINES
;************************************************************************          
             

;************************************************************************
; Wait for the blitter to finish
;************************************************************************
             xdef       wait_blitter
wait_blitter:
.loop:
             btst.b     #6,DMACONR(a5)             ; if bit 6 is 1, the blitter is busy
             bne        .loop                      ; and then wait until it's zero
             rts


;************************************************************************
; Swaps video buffers, causing draw_buffer to be displayed.
;************************************************************************
             xdef       swap_buffers
swap_buffers:
             movem.l    d0-a6,-(sp)                ; saves registers into the stack

             move.l     draw_buffer,d0             ; swaps the values ​​of draw_buffer and view_buffer
             move.l     view_buffer,draw_buffer
             move.l     d0,view_buffer
             lea        bplpointers,a1             ; sets the bitplane pointers to the view_buffer 
             moveq      #BPP-1,d1                                            
.loop:
             move.w     d0,6(a1)                   ; copies low word
             swap       d0                         ; swaps low and high word of d0
             move.w     d0,2(a1)                   ; copies high word
             swap       d0                         ; resets d0 to the initial condition
             add.l      #PF_PLANE_SZ,d0            ; points to the next bitplane
             add.l      #8,a1                      ; points to next bplpointer
             dbra       d1,.loop                   ; repeats the loop for all planes

             movem.l    (sp)+,d0-a6                ; restores registers from the stack
             rts