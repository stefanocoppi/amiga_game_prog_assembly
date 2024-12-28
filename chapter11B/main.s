;****************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 11B - AGA sprites and joystick reading
;
; (c) 2024 Stefano Coppi
;****************************************************************

      incdir     "include"
      include    "hw.i"
      include    "playfield.i"
      include    "sprites.i"
      

;****************************************************************
; EXTERNAL REFERENCES
;****************************************************************
      xref       take_system
      xref       release_system
      xref       init_bplpointers
      xref       bplpointers
      xref       wait_vblank
      xref       init_sprite_pointers
      xref       set_sprite_position
      xref       ship_sprite
      xref       sprite_x
      xref       sprite_y
      xref       move_sprite_with_joystick
      xref       check_collisions 
          

      
;****************************************************************
; MAIN PROGRAM
;****************************************************************
      SECTION    code_section,CODE
main:
      nop
      nop
      jsr        take_system                     ; takes the control of Amiga's hardware

; initializes bitplane pointers to background image
      lea        bplpointers,a1                  ; address of bitplane pointers in copperlist
      move.l     #bgnd,d0                        ; address of background image
      move.l     #PF_PLANE_SZ,d1                 ; plane size
      move.l     #BPP,d7                         ; number of bitplanes
      jsr        init_bplpointers

; initializes sprite pointers 
      jsr        init_sprite_pointers

; initializes sprite position      
      lea        ship_sprite,a1
      move.w     sprite_y,d0                     ; y position
      move.w     sprite_x,d1                     ; x position
      move.w     #SPRITE_HEIGHT,d2               ; sprite height
      bsr        set_sprite_position

      lea        ship_sprite+SPRITE_SIZE,a1
      bsr        set_sprite_position

      lea        ship_sprite+SPRITE_SIZE*2,a1
      add.w      #SPRITE_WIDTH,d1
      bsr        set_sprite_position

      lea        ship_sprite+SPRITE_SIZE*3,a1
      bsr        set_sprite_position
    
mainloop:  
      jsr        wait_vblank                     ; waits for vertical blank
  
      jsr        move_sprite_with_joystick
      jsr        check_collisions

      btst       #6,CIAAPRA                      ; left mouse button pressed?
      bne.s      mainloop                        ; if not, repeats the loop

      jsr        release_system                  ; releases the hw control to the O.S.
      rts


;****************************************************************
; Graphics data
;****************************************************************

; segment loaded in CHIP RAM
      SECTION    graphics_data,DATA_C

      CNOP       0,8                             ; 64-bit alignment
bgnd  incbin     "gfx/bgnd_256.raw"              ; background image

      END