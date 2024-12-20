;****************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 12 - Blitter Objects
;
; simple version using Blitter to scroll.
;
; (c) 2024 Stefano Coppi
;****************************************************************

           incdir     "include"
           include    "hw.i"
           include    "playfield.i"
           include    "bob.i"
           

;****************************************************************
; EXTERNAL REFERENCES
;****************************************************************
           xref       take_system
           xref       release_system
           xref       init_bplpointers
           xref       bplpointers
           xref       wait_vblank
           xref       swap_buffers
           xref       dbuffer1
           xref       restore_bob_bgnd
           xref       save_bob_bgnd
           xref       update_bob
           
          

           SECTION    code_section,CODE
;****************************************************************
; MAIN PROGRAM
;****************************************************************
main:
           nop
           nop
           jsr        take_system             ; takes the control of Amiga's hardware

           lea        bplpointers,a1          ; address of bitplane pointers in copperlist
           move.l     #dbuffer1,d0            ; address of screen in d0
           move.l     #PF_PLANE_SZ,d1         ; plane size
           move.l     #BPP,d7                 ; number of bitplanes
           jsr        init_bplpointers        ; initializes bitplane pointers to our image

    
mainloop:  
           jsr        wait_vblank             ; waits for vertical blank
           jsr        swap_buffers

           lea        bob_ship,a1             ; updates bob's position
           jsr        update_bob
           lea        bob_ship2,a1                 
           jsr        update_bob
           lea        bob_ship3,a1                 
           jsr        update_bob

           lea        bob_ship,a1             ; restores bobs background
           jsr        restore_bob_bgnd
           lea        bob_ship2,a1                 
           jsr        restore_bob_bgnd
           lea        bob_ship3,a1                 
           jsr        restore_bob_bgnd
               
           lea        bob_ship,a1             ; saves bob_ship background
           jsr        save_bob_bgnd
               
           lea        bob_ship,a3
           move.l     draw_buffer,a2
           jsr        draw_bob                ; draws bob_ship

           lea        bob_ship2,a1            ; saves bob_ship2 background
           jsr        save_bob_bgnd
               
           lea        bob_ship2,a3
           move.l     draw_buffer,a2
           jsr        draw_bob                ; draws  bob_ship2

           lea        bob_ship3,a1            ; saves bob_ship3 background
           jsr        save_bob_bgnd
               
           lea        bob_ship3,a3
           move.l     draw_buffer,a2
           jsr        draw_bob                ; draws  bob_ship3

           btst       #6,CIAAPRA              ; left mouse button pressed?
           bne        mainloop                ; if not, repeats the loop

           jsr        release_system          ; releases the hw control to the O.S.
           rts


;************************************************************************
; VARIABLES
;************************************************************************
bob_ship   dc.w       0                       ; bob.valid1
           dc.w       0                       ; bob.valid2
           dc.w       0                       ; x position
           dc.w       81                      ; y position
           dc.w       6                       ; bob.speed
           dc.w       128                     ; width
           dc.w       77                      ; height  
           dc.l       0                       ; dst_addr1 
           dc.l       0                       ; dst_addr2
           dc.w       0                       ; blit size
           dc.w       0                       ; spritesheet column of the bob
           dc.w       0                       ; spritesheet row of the bob
           dc.w       128                     ; spritesheet width in pixels
           dc.w       77                      ; spritesheet height in pixels
           dc.l       ship                    ; image data address
           dc.l       ship_mask               ; mask address
           dcb.b      BOB_PLANE_SZ*BPP,0
           dcb.b      BOB_PLANE_SZ*BPP,0


bob_ship2  dc.w       0                       ; bob.valid1
           dc.w       0                       ; bob.valid2
           dc.w       0                       ; x position
           dc.w       160                     ; y position
           dc.w       8                       ; bob.speed
           dc.w       128                     ; width
           dc.w       77                      ; height  
           dc.l       0                       ; dst_addr1 
           dc.l       0                       ; dst_addr2
           dc.w       0                       ; blit size
           dc.w       0                       ; spritesheet column of the bob
           dc.w       0                       ; spritesheet row of the bob
           dc.w       128                     ; spritesheet width in pixels
           dc.w       77                      ; spritesheet height in pixels
           dc.l       ship                    ; image data address
           dc.l       ship_mask               ; mask address
           dcb.b      BOB_PLANE_SZ*BPP,0
           dcb.b      BOB_PLANE_SZ*BPP,0

bob_ship3  dc.w       0                       ; bob.valid1
           dc.w       0                       ; bob.valid2
           dc.w       0                       ; x position
           dc.w       0                       ; y position
           dc.w       4                       ; bob.speed
           dc.w       128                     ; width
           dc.w       77                      ; height  
           dc.l       0                       ; dst_addr1 
           dc.l       0                       ; dst_addr2
           dc.w       0                       ; blit size
           dc.w       0                       ; spritesheet column of the bob
           dc.w       0                       ; spritesheet row of the bob
           dc.w       128                     ; spritesheet width in pixels
           dc.w       77                      ; spritesheet height in pixels
           dc.l       ship                    ; image data address
           dc.l       ship_mask               ; mask address
           dcb.b      BOB_PLANE_SZ*BPP,0
           dcb.b      BOB_PLANE_SZ*BPP,0

               
;************************************************************************
; Graphics data
;************************************************************************
; segment loaded in CHIP RAM
           SECTION    graphics_data,DATA_C

ship       incbin     "gfx/ship6.raw"
ship_mask  incbin     "gfx/ship6.mask"

           END