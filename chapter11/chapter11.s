;****************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 11 - Hardware sprites and joystick reading
;
; (c) 2024 Stefano Coppi
;****************************************************************

              incdir     "include"
              include    "hw.i"
              include    "funcdef.i"
              include    "exec/exec_lib.i"
              include    "graphics/graphics_lib.i"

;****************************************************************
; CONSTANTS
;****************************************************************

; DMACON register settings
; enables sprites DMA (bit 5)
; enables copper DMA (bit 7)
; enables bitplanes DMA (bit 8)
                     ;5432109876543210
DMASET           equ %1000001110100000 


; display
N_PLANES         equ 4
DISPLAY_WIDTH    equ 320
DISPLAY_HEIGHT   equ 256
DISPLAY_PLANE_SZ equ DISPLAY_HEIGHT*(DISPLAY_WIDTH/8)

SPRITE_HEIGHT    equ 17
SPRITE_SPEED     equ 1

              SECTION    code_section,CODE


;****************************************************************
; MAIN PROGRAM
;****************************************************************
main:
              nop
              nop
              bsr        take_system                    ; takes the control of Amiga's hardware
              move.l     #bgnd,d0                       ; address of screen in d0
              bsr        init_bplpointers               ; initializes bitplane pointers to our image
              bsr        init_sprite_pointers
              
              lea        alien_sprite,a1
              move.w     sprite_y,d0                    ; y position
              move.w     sprite_x,d1                    ; x position
              move.w     #SPRITE_HEIGHT,d2              ; sprite height
              bsr        set_sprite_position

              lea        alien_sprite+76,a1
              bsr        set_sprite_position

mainloop: 
              bsr        wait_vblank                    ; waits for vertical blank
              bsr        move_sprite_with_joystick
              bsr        check_collisions

              btst       #6,CIAAPRA                     ; left mouse button pressed?
              bne.s      mainloop                       ; if not, repeats the loop

              bsr        release_system                 ; releases the hw control to the O.S.
              rts


;****************************************************************
; SUBROUTINES
;****************************************************************


;****************************************************************
; Takes full control of Amiga hardware,
; disabling the O.S. in a controlled way.
;****************************************************************
take_system:
              move.l     ExecBase,a6                    ; base address of Exec
              jsr        _LVOForbid(a6)                 ; disables O.S. multitasking
              jsr        _LVODisable(a6)                ; disables O.S. interrupts

              lea        gfx_name,a1                    ; OpenLibrary takes 1 parameter: library name in a1
              jsr        _LVOOldOpenLibrary(a6)         ; opens graphics.library
              move.l     d0,gfx_base                    ; saves base address of graphics.library in a variable
            
              move.l     d0,a6                          ; gfx base                   
              move.l     $26(a6),sys_coplist            ; saves system copperlist address
             
              jsr        _LVOOwnBlitter(a6)             ; takes the Blitter exclusive

              lea        CUSTOM,a5                      ; a5 will always contain CUSTOM chips base address $dff000
          
              move.w     DMACONR(a5),old_dma            ; saves state of DMA channels in a variable
              move.w     #$7fff,DMACON(a5)              ; disables all DMA channels
              move.w     #DMASET,DMACON(a5)             ; sets only dma channels that we will use

              move.l     #copperlist,COP1LC(a5)         ; sets our copperlist address into Copper
              move.w     d0,COPJMP1(a5)                 ; reset Copper PC to the beginning of our copperlist       

              move.w     #0,FMODE(a5)                   ; sets 16 bit FMODE
              move.w     #$c00,BPLCON3(a5)              ; disables 24 bit palette                        
              move.w     #$11,BPLCON4(a5)               ; enables normal palette

              rts


;****************************************************************
; Releases the hardware control to the O.S.
;****************************************************************
release_system:
              move.l     sys_coplist,COP1LC(a5)         ; restores the system copperlist
              move.w     d0,COPJMP1(a5)                 ; starts the system copperlist 

              or.w       #$8000,old_dma                 ; sets bit 15
              move.w     old_dma,DMACON(a5)             ; restores saved DMA state

              move.l     gfx_base,a6
              jsr        _LVODisownBlitter(a6)          ; release Blitter ownership
              move.l     ExecBase,a6                    ; base address of Exec
              jsr        _LVOPermit(a6)                 ; enables O.S. multitasking
              jsr        _LVOEnable(a6)                 ; enables O.S. interrupts
              move.l     gfx_base,a1                    ; base address of graphics.library in a1
              jsr        _LVOCloseLibrary(a6)           ; closes graphics.library
              rts


;****************************************************************
; Initializes bitplane pointers
;
; parameters:
; d0.l - address of bitplanes
;****************************************************************
init_bplpointers:
              movem.l    d0-a6,-(sp)
                   
              lea        bplpointers,a1                 ; bitplane pointers in a1
              move.l     #(N_PLANES-1),d1               ; number of loop iterations in d1
.loop:
              move.w     d0,6(a1)                       ; copy low word of image address into BPLxPTL (low word of BPLxPT)
              swap       d0                             ; swap high and low word of image address
              move.w     d0,2(a1)                       ; copy high word of image address into BPLxPTH (high word of BPLxPT)
              swap       d0                             ; resets d0 to the initial condition
              add.l      #DISPLAY_PLANE_SZ,d0           ; point to the next bitplane
              add.l      #8,a1                          ; point to next bplpointer
              dbra       d1,.loop                       ; repeats the loop for all planes
            
              movem.l    (sp)+,d0-a6
              rts 


;************************************************************************
; Waits for the electron beam to reach a given line.
;
; parameters:
; d2.l - line
;************************************************************************
wait_vline:
              movem.l    d0-a6,-(sp)                    ; saves registers into the stack

              lsl.l      #8,d2
              move.l     #$1ff00,d1
wait:
              move.l     VPOSR(a5),d0
              and.l      d1,d0
              cmp.l      d2,d0
              bne.s      wait

              movem.l    (sp)+,d0-a6                    ; restores registers from the stack
              rts


;************************************************************************
; Waits for the vertical blank
;************************************************************************
wait_vblank:
              movem.l    d0-a6,-(sp)                    ; saves registers into the stack
              move.l     #304,d2                        ; line to wait: 304 236
              bsr        wait_vline
              movem.l    (sp)+,d0-a6                    ; restores registers from the stack
              rts


;****************************************************************
; Initializes sprite pointers
;****************************************************************
init_sprite_pointers:
              movem.l    d0-a6,-(sp)

              lea        sprite_pointers,a1
              move.l     #alien_sprite,d0
              move.w     d0,6(a1)                       ; low word
              swap       d0
              move.w     d0,2(a1)                       ; high word

              add.l      #8,a1                          ; next sprite pointer
              move.l     #alien_sprite+76,d0            ; next sprite
              move.w     d0,6(a1)                       ; low word
              swap       d0
              move.w     d0,2(a1)                       ; high word

              bset       #7,alien_sprite+76+3           ; sets sprite1 attached bit

              movem.l    (sp)+,d0-a6
              rts


;****************************************************************
; Sets the position of a sprite
;
; parameters:
; a1 - sprite address
; d0.w - y position (0-255)
; d1.w - x position (0-319)
; d2.w - sprite height
;****************************************************************
set_sprite_position:
              movem.l    d0-a6,-(sp)

              add.w      #$2c,d0                        ; adds offset of screen beginning
              move.b     d0,(a1)                        ; copies y into sprite VSTART byte
              btst.l     #8,d0                          ; bit 8 of y position is set?
              beq        .dontset_bit8
              bset.b     #2,3(a1)                       ; sets bit 8 of VSTART
              bra        .vstop
.dontset_bit8:
              bclr.b     #2,3(a1)                       ; clears bit 8 of VSTART
.vstop:
              add.w      d2,d0                          ; adds height to y position to get VSTOP
              move.b     d0,2(a1)                       ; copies the value into sprite VSTOP byte
              btst.l     #8,d0                          ; bit 8 of VSTOP is set?
              beq        .dontset_VSTOP_bit8
              bset.b     #1,3(a1)                       ; sets bit 8 of VSTOP
              bra        .set_hpos
.dontset_VSTOP_bit8:
              bclr.b     #1,3(a1)                       ; clears bit 8 of VSTOP
.set_hpos:
              add.w      #128,d1                        ; adds horizontal offset to x
              btst.l     #0,d1 
              beq        .HSTART_lsb_zero
              bset.b     #0,3(a1)                       ; sets bit 0 of HSTART
              bra        .set_HSTART
.HSTART_lsb_zero:
              bclr.b     #0,3(a1)                       ; clears bit 0 of HSTART
.set_HSTART:
              lsr.w      #1,d1                          ; shifts 1 position to right to get the 8 most significant bits of x position
              move.b     d1,1(a1)                       ; sets HSTART value
              movem.l    (sp)+,d0-a6
              rts


;****************************************************************
; Moves the sprite with the joystick
;****************************************************************
move_sprite_with_joystick:
              movem.l    d0-a6,-(sp)

              move.w     JOY1DAT(a5),d0
              btst.l     #1,d0                          ; joy right?
              bne        .set_right
              btst.l     #9,d0                          ; joy left?
              bne        .set_left
              bra        .check_up
.set_right:
              add.w      #SPRITE_SPEED,sprite_x
              bra        .check_up
.set_left:
              sub.w      #SPRITE_SPEED,sprite_x
.check_up:
              move.w     d0,d1
              lsr.w      #1,d1
              eor.w      d1,d0
              btst.l     #8,d0                          ; joy up?
              bne        .set_up
              btst.l     #0,d0                          ; joy down?
              bne        .set_down
              bra        .move_sprite
.set_up:
              sub.w      #SPRITE_SPEED,sprite_y
              bra        .move_sprite
.set_down:
              add.w      #SPRITE_SPEED,sprite_y
.move_sprite:
              lea        alien_sprite,a1
              move.w     sprite_y,d0                    ; y position
              move.w     sprite_x,d1                    ; x position
              move.w     #SPRITE_HEIGHT,d2              ; sprite height
              bsr        set_sprite_position

              lea        alien_sprite+76,a1
              bsr        set_sprite_position

              movem.l    (sp)+,d0-a6
              rts


;****************************************************************
; Checks the collisions between sprite and playfield.
; If a collision is detected, change the border color to red.
;****************************************************************
check_collisions:
              movem.l    d0-a6,-(sp)

              move.w     CLXDAT(a5),d0
              btst.l     #1,d0                          ; bit 1 checks collisions between playfield and sprites 0-1
              bne        .collision
              move.w     #$0000,bgnd_palette+2
              bra        .return
.collision:
              move.w     #$0f00,bgnd_palette+2
.return:
              movem.l    (sp)+,d0-a6
              rts


;****************************************************************
; VARIABLES
;****************************************************************
gfx_name      dc.b       "graphics.library",0,0         ; string containing the name of graphics.library
gfx_base      dc.l       0                              ; base address of graphics.library
old_dma       dc.w       0                              ; saved state of DMACON
sys_coplist   dc.l       0                              ; address of system copperlist  
sprite_x      dc.w       16
sprite_y      dc.w       16

;****************************************************************
; Graphics data
;****************************************************************

; segment loaded in CHIP RAM
              SECTION    graphics_data,DATA_C

copperlist:
              dc.w       DIWSTRT,$2c81                  ; display window start at ($81,$2c)
              dc.w       DIWSTOP,$2cc1                  ; display window stop at ($1c1,$12c)
              dc.w       DDFSTRT,$38                    ; display data fetch start at $38
              dc.w       DDFSTOP,$d0                    ; display data fetch stop at $d0
              dc.w       BPLCON1,0                                          
              dc.w       BPLCON2,%100100                ; sets sprites priority over playfield                               
              dc.w       BPL1MOD,0                                             
              dc.w       BPL2MOD,0

  ; BPLCON0 ($100)
  ; bit 9: set to 1 to enable composite video output
  ; bit 12-14: least significant bits of bitplane number
  ;                               5432109876543210
              dc.w       BPLCON0,%0100001000000000

  ; Controls sprite-bitplane collisions
  ; bit 12: enable sprite 1
  ; bit 6-9: enable bitplanes 1-4
  ; bit 0-5: color index for collisions with playfield
  ;                              5432109876543210
              dc.w       CLXCON,%0001001111001000

bplpointers:
              dc.w       $e0,0,$e2,0                    ; plane 1
              dc.w       $e4,0,$e6,0                    ; plane 2
              dc.w       $e8,0,$ea,0                    ; plane 3
              dc.w       $ec,0,$ee,0                    ; plane 4

sprite_pointers:
              dc.w       SPR0PTH,0,SPR0PTL,0
              dc.w       SPR1PTH,0,SPR1PTL,0
              dc.w       SPR2PTH,0,SPR2PTL,0
              dc.w       SPR3PTH,0,SPR3PTL,0
              dc.w       SPR4PTH,0,SPR4PTL,0
              dc.w       SPR5PTH,0,SPR5PTL,0
              dc.w       SPR6PTH,0,SPR6PTL,0
              dc.w       SPR7PTH,0,SPR7PTL,0

bgnd_palette  incbin     "gfx/bgnd.pal"
palette       incbin     "gfx/alien.pal"

              dc.w       $ffff,$fffe                    ; end of copperlist

alien_sprite  incbin     "gfx/alien.raw"

; .\amigeconv.exe -f sprite -a -w 16 -t -d 4 .\alien.png alien.raw
; .\amigeconv.exe -f palette -p pal4 -c 16 -x .\alien.png alien.pal


bgnd          incbin     "gfx/bgnd.raw"                 ; background image

;************************************************************************
; BSS DATA
;************************************************************************

              SECTION    bss_data,BSS_C

screen        ds.b       (DISPLAY_PLANE_SZ*N_PLANES)    ; visible screen

              END