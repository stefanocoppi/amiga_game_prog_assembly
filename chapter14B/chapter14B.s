;************************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 14B - Player's ship
;
; (c) 2024 Stefano Coppi
;************************************************************************

              incdir     "include"
              include    "hw.i"
              include    "funcdef.i"
              include    "exec/exec_lib.i"
              include    "graphics/graphics_lib.i"

;************************************************************************
; CONSTANTS
;************************************************************************

; O.S. subroutines
ExecBase           equ $4
Disable            equ -$78
Forbid             equ -132
Enable             equ -$7e
Permit             equ -138
OpenLibrary        equ -$198
CloseLibrary       equ -$19e
CIAAPRA            equ $bfe001

; DMACON register settings
; enables sprites DMA (bit 5)
; enables blitter DMA (bit 6)
; enables copper DMA (bit 7)
; enables bitplanes DMA (bit 8)
                       ;5432109876543210
DMASET             equ %1000001111100000             

; display
N_PLANES           equ 8
DISPLAY_WIDTH      equ 320
DISPLAY_HEIGHT     equ 256
DISPLAY_PLANE_SZ   equ DISPLAY_HEIGHT*(DISPLAY_WIDTH/8)
DISPLAY_ROW_SIZE   equ (DISPLAY_WIDTH/8)

; tiles
TILE_WIDTH         equ 64
TILE_HEIGHT        equ 64
TILE_PLANE_SZ      equ TILE_HEIGHT*(TILE_WIDTH/8)
TILESET_WIDTH      equ 640
TILESET_HEIGHT     equ 512
TILESET_ROW_SIZE   equ (TILESET_WIDTH/8)
TILESET_PLANE_SZ   equ (TILESET_HEIGHT*TILESET_ROW_SIZE)
TILESET_COLS       equ 10          
TILEMAP_WIDTH      equ 100
TILEMAP_ROW_SIZE   equ TILEMAP_WIDTH*2

; background
BGND_WIDTH         equ 2*DISPLAY_WIDTH+2*TILE_WIDTH
BGND_HEIGHT        equ 256
BGND_PLANE_SIZE    equ BGND_HEIGHT*(BGND_WIDTH/8)
BGND_ROW_SIZE      equ (BGND_WIDTH/8)

; scroll
VIEWPORT_HEIGHT    equ 192
VIEWPORT_WIDTH     equ 320
SCROLL_RESET_VALUE equ $ccff

; sprites
SPRITE_WIDTH       equ 64
SPRITE_HEIGHT      equ 70
SPRITE_SIZE        equ SPRITE_HEIGHT*(SPRITE_WIDTH/8)*2+2*4*4
SPRITE_SPEED       equ 1


              SECTION    code_section,CODE

;************************************************************************
; MAIN PROGRAM
;************************************************************************
main:
              nop
              nop
              bsr        take_system                                  ; takes the control of Amiga's hardware
              move.l     #bgnd_surface+8,d0                           ; address of visible screen buffer
              move.l     #BGND_PLANE_SIZE,d1 
              bsr        init_bplpointers                             ; initializes bitplane pointers to our image
              bsr        init_sprite_pointers
              
              lea        ship_sprite,a1
              move.w     sprite_y,d0                                  ; y position
              move.w     sprite_x,d1                                  ; x position
              move.w     #SPRITE_HEIGHT,d2                            ; sprite height
              bsr        set_sprite_position

              lea        ship_sprite+SPRITE_SIZE,a1
              bsr        set_sprite_position

            ;   lea        ship_sprite+SPRITE_SIZE*2,a1
            ;   add.w      #SPRITE_WIDTH,d1
            ;   bsr        set_sprite_position

            ;   lea        ship_sprite+SPRITE_SIZE*3,a1
            ;   bsr        set_sprite_position
              
              move.w     map_ptr,d0
              bsr        init_background
              move.w     #TILE_WIDTH,bgnd_x                           ; x position of the part of background to draw

mainloop: 
              bsr        wait_vblank                                  ; waits for vertical blank
             
              bsr        scroll_background
              bsr        move_sprite_with_joystick

              btst       #6,CIAAPRA                                   ; left mouse button pressed?
              bne.s      mainloop                                     ; if not, repeats the loop

              bsr        release_system                               ; releases the hw control to the O.S.
              rts


;************************************************************************
; SUBROUTINES
;************************************************************************

;************************************************************************
; Takes full control of Amiga hardware,
; disabling the O.S. in a controlled way.
;************************************************************************
take_system:
              move.l     ExecBase,a6                                  ; base address of Exec
              jsr        _LVOForbid(a6)                               ; disables O.S. multitasking
              jsr        _LVODisable(a6)                              ; disables O.S. interrupts

              lea        gfx_name,a1                                  ; OpenLibrary takes 1 parameter: library name in a1
              jsr        _LVOOldOpenLibrary(a6)                       ; opens graphics.library
              move.l     d0,gfx_base                                  ; saves base address of graphics.library in a variable
            
              move.l     d0,a6                                        ; gfx base                   
              move.l     $26(a6),sys_coplist                          ; saves system copperlist address
             
              jsr        _LVOOwnBlitter(a6)                           ; takes the Blitter exclusive

              lea        CUSTOM,a5                                    ; a5 will always contain CUSTOM chips base address $dff000
          
              move.w     DMACONR(a5),old_dma                          ; saves state of DMA channels in a variable
              move.w     #$7fff,DMACON(a5)                            ; disables all DMA channels
              move.w     #DMASET,DMACON(a5)                           ; sets only dma channels that we will use

              move.l     #copperlist,COP1LC(a5)                       ; sets our copperlist address into Copper
              move.w     d0,COPJMP1(a5)                               ; reset Copper PC to the beginning of our copperlist       

              move.w     #0,FMODE(a5)                                 ; sets 16 bit FMODE
              move.w     #$c00,BPLCON3(a5)                            ; sets default value                       
              move.w     #$11,BPLCON4(a5)                             ; sets default value

              rts


;************************************************************************
; Releases the hardware control to the O.S.
;************************************************************************
release_system:
              move.l     sys_coplist,COP1LC(a5)                       ; restores the system copperlist
              move.w     d0,COPJMP1(a5)                               ; starts the system copperlist 

              or.w       #$8000,old_dma                               ; sets bit 15
              move.w     old_dma,DMACON(a5)                           ; restores saved DMA state

              move.l     gfx_base,a6
              jsr        _LVODisownBlitter(a6)                        ; release Blitter ownership
              move.l     ExecBase,a6                                  ; base address of Exec
              jsr        _LVOPermit(a6)                               ; enables O.S. multitasking
              jsr        _LVOEnable(a6)                               ; enables O.S. interrupts
              move.l     gfx_base,a1                                  ; base address of graphics.library in a1
              jsr        _LVOCloseLibrary(a6)                         ; closes graphics.library
              rts


;************************************************************************
; Initializes bitplane pointers
;
; parameters;
; d0.l - address of playfield
; d1.l - playfield plane size (in bytes)
;************************************************************************
init_bplpointers:
              movem.l    d0-a6,-(sp)
              
              lea        bplpointers,a1                               ; bitplane pointers in a1
              move.l     #(N_PLANES-1),d7                             ; number of loop iterations in d7
.loop:
              move.w     d0,6(a1)                                     ; copy low word of image address into BPLxPTL (low word of BPLxPT)
              swap       d0                                           ; swap high and low word of image address
              move.w     d0,2(a1)                                     ; copy high word of image address into BPLxPTH (high word of BPLxPT)
              swap       d0                                           ; resets d0 to the initial condition
              ;add.l      #DISPLAY_PLANE_SZ,d0                                     ; point to the next bitplane
              ;add.l      #BGND_PLANE_SIZE,d0                                      ; point to the next bitplane
              add.l      d1,d0                                        ; points to the next bitplane
              add.l      #8,a1                                        ; poinst to next bplpointer
              dbra       d7,.loop                                     ; repeats the loop for all planes
            
              movem.l    (sp)+,d0-a6
              rts 


;************************************************************************
; Wait for the blitter to finish
;************************************************************************
wait_blitter:
.loop:
              btst.b     #6,DMACONR(a5)                               ; if bit 6 is 1, the blitter is busy
              bne        .loop                                        ; and then wait until it's zero
              rts 


;************************************************************************
; Waits for the electron beam to reach a given line.
;
; parameters:
; d2.l - line
;************************************************************************
wait_vline:
              movem.l    d0-a6,-(sp)                                  ; saves registers into the stack

              lsl.l      #8,d2
              move.l     #$1ff00,d1
wait:
              move.l     VPOSR(a5),d0
              and.l      d1,d0
              cmp.l      d2,d0
              bne.s      wait

              movem.l    (sp)+,d0-a6                                  ; restores registers from the stack
              rts


;************************************************************************
; Waits for the vertical blank
;************************************************************************
wait_vblank:
              movem.l    d0-a6,-(sp)                                  ; saves registers into the stack
              move.l     #304,d2                                      ; line to wait: 304 236
              bsr        wait_vline
              movem.l    (sp)+,d0-a6                                  ; restores registers from the stack
              rts


;************************************************************************
; Draws a 64x64 pixel tile using Blitter.
;
; parameters:
; d0.w - tile index
; d2.w - x position of the screen where the tile will be drawn (multiple of 16)
; d3.w - y position of the screen where the tile will be drawn
; a1   - address where draw the tile
;************************************************************************
draw_tile:
              movem.l    d0-a6,-(sp)                                  ; saves registers into the stack

; calculates the screen address where to draw the tile
              mulu       #BGND_ROW_SIZE,d3                            ; y_offset = y * BGND_ROW_SIZE
              lsr.w      #3,d2                                        ; x_offset = x / 8
              ext.l      d2
              add.l      d3,a1                                        ; sums offsets to a1
              add.l      d2,a1

; calculates row and column of tile in tileset starting from index
              ext.l      d0                                           ; extends d0 to a long because the destination operand if divu must be long
              divu       #TILESET_COLS,d0                             ; tile_index / TILESET_COLS
              swap       d0
              move.w     d0,d1                                        ; the remainder indicates the tile column
              swap       d0                                           ; the quotient indicates the tile row
         
; calculates the x,y coordinates of the tile in the tileset
              lsl.w      #6,d0                                        ; y = row * 64
              lsl.w      #6,d1                                        ; x = column * 64
         
; calculates the offset to add to a0 to get the address of the source image
              mulu       #TILESET_ROW_SIZE,d0                         ; offset_y = y * TILESET_ROW_SIZE
              lsr.w      #3,d1                                        ; offset_x = x / 8
              ext.l      d1

              lea        tileset,a0                                   ; source image address
              add.l      d0,a0                                        ; add y_offset
              add.l      d1,a0                                        ; add x_offset

              moveq      #N_PLANES-1,d7
         
              bsr        wait_blitter
              move.w     #$ffff,BLTAFWM(a5)                           ; don't use mask
              move.w     #$ffff,BLTALWM(a5)
              move.w     #$09f0,BLTCON0(a5)                           ; enable channels A,D
                                                                                  ; logical function = $f0, D = A
              move.w     #0,BLTCON1(a5)
              move.w     #(TILESET_WIDTH-TILE_WIDTH)/8,BLTAMOD(a5)    ; A channel modulus
              move.w     #(BGND_WIDTH-TILE_WIDTH)/8,BLTDMOD(a5)       ; D channel modulus
.loop:
              bsr        wait_blitter
              move.l     a0,BLTAPT(a5)                                ; source address
              move.l     a1,BLTDPT(a5)                                ; destination address
              move.w     #64*64+4,BLTSIZE(a5)                         ; blit size: 64 rows for 4 word
              add.l      #TILESET_PLANE_SZ,a0                         ; advances to the next plane
              add.l      #BGND_PLANE_SIZE,a1
              dbra       d7,.loop
              bsr        wait_blitter

              movem.l    (sp)+,d0-a6                                  ; restore registers from the stack
              rts


;************************************************************************
; Draws a column of 3 tiles.
;
; parameters:
; d0.w - map column
; d2.w - x position (multiple of 16)
; a1   - address where draw the tile
;************************************************************************
draw_tile_column: 
              movem.l    d0-a6,-(sp)
        
; calculates the tilemap address from which to read the tile index
              lea        map,a0
              lsl.w      #1,d0                                        ; offset_x = map_column * 2
              ext.l      d0
              add.l      d0,a0
         
              moveq      #3-1,d7                                      ; number or tilemap rows - 1
              move.w     #0,d3                                        ; y position
.loop:
              move.w     (a0),d0                                      ; tile index
              bsr        draw_tile
              add.w      #TILE_HEIGHT,d3                              ; increment y position
              add.l      #TILEMAP_ROW_SIZE,a0                         ; move to the next row of the tilemap
              dbra       d7,.loop

              movem.l    (sp)+,d0-a6
              rts


;************************************************************************
; Initializes the background, copying the initial part of the level map.
;
; parameters:
; d0.w - map column from which to start drawing tiles
;************************************************************************
init_background:
              movem.l    d0-a6,-(sp)

; initializes the part that will be visible in the display window
              moveq      #5-1,d7                                      ; number of tile columns - 1 to draw
              lea        bgnd_surface,a1                              ; address where draw the tile
              move.w     #TILE_WIDTH,d2                               ; position x
.loop         bsr        draw_tile_column
              add.w      #1,d0                                        ; increment map column
              add.w      #1,map_ptr
              add.w      #TILE_WIDTH,d2                               ; increase position x
              dbra       d7,.loop

; draws the column to the left of the display window
              add.w      #1,d0                                        ; map column
              add.w      #1,map_ptr
              move.w     #0,d2                                        ; x position
              lea        bgnd_surface,a1
              bsr        draw_tile_column

; draws the column to the right of the display window
              move.w     #DISPLAY_WIDTH+TILE_WIDTH,d2                 ; x position
              lea        bgnd_surface,a1
              bsr        draw_tile_column

              movem.l    (sp)+,d0-a6
              rts


;************************************************************************
; Scrolls the background to the left.
;************************************************************************
scroll_background:
              movem.l    d0-a6,-(sp)

              move.w     bgnd_x,d0                                    ; x position of the part of background to draw
              tst.w      d0
              beq        .set_scroll
              ext.l      d0                                           ; every 64 pixels draws a new column
              divu       #TILE_WIDTH,d0
              swap       d0
              tst.w      d0                                           ; remainder of bgnd_x/TILE_WIDTH is zero?
              beq        .draw_new_column                             ; if yes, draws new tile columns at the sides of viewport
              bra        .set_scroll
.draw_new_column:
              add.w      #1,map_ptr
              cmp.w      #TILEMAP_WIDTH,map_ptr                       ; end of map?
              bge        .return

              move.w     map_ptr,d0                                   ; map column
              move.w     bgnd_x,d2                                    ; x position = bgnd_x - TILE_WIDTH
              sub.w      #TILE_WIDTH,d2
              lea        bgnd_surface,a1
              bsr        draw_tile_column                             ; draws the column to the left of the viewport

              move.w     bgnd_x,d2                                    ; x position = bgnd_x + VIEWPORT_WIDTH
              add.w      #VIEWPORT_WIDTH,d2 
              lea        bgnd_surface,a1
              bsr        draw_tile_column                             ; draws the column to the right of the viewport
              
.set_scroll:
              move.w     bgnd_x,d0
              divu       #64,d0
              swap       d0                                           ; remainder is the scroll amount
              tst.w      d0                                           ; if remainder = 0, updates the bitplane pointers
              beq        .update_bplptr
              move.w     #63,d1
              sub.w      d0,d1
              move.w     d1,d0
              move.w     d0,d1
              and.w      #%110000,d1                                  ; extracts only bits 6-7 of scroll amount
              move.w     d1,d2
              lsl.w      #6,d1                                        ; moves msb into bits 10-11
              lsl.w      #8,d2                                        ; moves msb into bit 14-15
              lsl.w      #2,d2                                        ; moves msb into bit 14-15
              or.w       d1,d2
              move.w     d0,d1
              and.w      #%1111,d1                                    ; extracts bits 2-5 of scroll amount
              move.w     d1,d3
              lsl.w      #4,d3
              or.w       d1,d3
              or.w       d3,d2                                        ; d2 contains BPLCON1 value
              move.w     d2,scrollx                                   ; sets the BPLCON1 value for scrolling
              bra        .check_bgnd_end
.update_bplptr:
              move.w     bgnd_x,d1 
              asr.w      #3,d1                                        ; offset_x = bgnd_x/8
              and.w      #$fffe,d1                                    ; rounds to even addresses
              ext.l      d1                                           ; extends to long
              move.l     #bgnd_surface,d0
              add.l      d1,d0                                        ; adds offset_x
              move.l     #BGND_PLANE_SIZE,d1
              bsr        init_bplpointers
              move.w     #SCROLL_RESET_VALUE,scrollx                  ; resets scroll value
.check_bgnd_end:
              cmp.w      #TILE_WIDTH+VIEWPORT_WIDTH,bgnd_x            ; end of background surface?
              ble        .incr_x
              move.w     #0,bgnd_x                                    ; resets x position of the part of background to draw
              move.l     #bgnd_surface,d0                             ; -2?
              move.l     #BGND_PLANE_SIZE,d1
              bsr        init_bplpointers
              move.w     #SCROLL_RESET_VALUE,scrollx                  ; resets scroll value
              bra        .return
.incr_x:       
              add.w      #1,bgnd_x                                    ; increases x position of the part of background to draw

.return       movem.l    (sp)+,d0-a6
              rts


;****************************************************************
; Initializes sprite pointers
;****************************************************************
init_sprite_pointers:
              movem.l    d0-a6,-(sp)

              lea        sprite_pointers,a1
              move.l     #ship_sprite,d0
              move.w     d0,6(a1)                                     ; low word
              swap       d0
              move.w     d0,2(a1)                                     ; high word

              add.l      #8,a1                                        ; next sprite pointer
              move.l     #ship_sprite+SPRITE_SIZE,d0                  ; next sprite
              move.w     d0,6(a1)                                     ; low word
              swap       d0
              move.w     d0,2(a1)                                     ; high word

              bset       #7,ship_sprite+SPRITE_SIZE+9                 ; sets sprite1 attached bit

              add.l      #8,a1                                        ; next sprite pointer
              move.l     #ship_sprite+SPRITE_SIZE*2,d0                ; next sprite
              move.w     d0,6(a1)                                     ; low word
              swap       d0
              move.w     d0,2(a1)                                     ; high word

              add.l      #8,a1                                        ; next sprite pointer
              move.l     #ship_sprite+SPRITE_SIZE*3,d0                ; next sprite
              move.w     d0,6(a1)                                     ; low word
              swap       d0
              move.w     d0,2(a1)                                     ; high word

              bset       #7,ship_sprite+SPRITE_SIZE*3+9               ; sets sprite3 attached bit

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

              add.w      #$2c,d0                                      ; adds offset of screen beginning
              move.b     d0,(a1)                                      ; copies y into sprite VSTART byte
              btst.l     #8,d0                                        ; bit 8 of y position is set?
              beq        .dontset_bit8
              bset.b     #2,9(a1)                                     ; sets bit 8 of VSTART
              bra        .vstop
.dontset_bit8:
              bclr.b     #2,9(a1)                                     ; clears bit 8 of VSTART
.vstop:
              add.w      d2,d0                                        ; adds height to y position to get VSTOP
              move.b     d0,8(a1)                                     ; copies the value into sprite VSTOP byte
              btst.l     #8,d0                                        ; bit 8 of VSTOP is set?
              beq        .dontset_VSTOP_bit8
              bset.b     #1,9(a1)                                     ; sets bit 8 of VSTOP
              bra        .set_hpos
.dontset_VSTOP_bit8:
              bclr.b     #1,9(a1)                                     ; clears bit 8 of VSTOP
.set_hpos:
              add.w      #128,d1                                      ; adds horizontal offset to x
              btst.l     #0,d1 
              beq        .HSTART_lsb_zero
              bset.b     #0,9(a1)                                     ; sets bit 0 of HSTART
              bra        .set_HSTART
.HSTART_lsb_zero:
              bclr.b     #0,9(a1)                                     ; clears bit 0 of HSTART
.set_HSTART:
              lsr.w      #1,d1                                        ; shifts 1 position to right to get the 8 most significant bits of x position
              move.b     d1,1(a1)                                     ; sets HSTART value
              movem.l    (sp)+,d0-a6
              rts


;****************************************************************
; Moves the sprite with the joystick
;****************************************************************
move_sprite_with_joystick:
              movem.l    d0-a6,-(sp)

              move.w     JOY1DAT(a5),d0
              btst.l     #1,d0                                        ; joy right?
              bne        .set_right
              btst.l     #9,d0                                        ; joy left?
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
              btst.l     #8,d0                                        ; joy up?
              bne        .set_up
              btst.l     #0,d0                                        ; joy down?
              bne        .set_down
              bra        .move_sprite
.set_up:
              sub.w      #SPRITE_SPEED,sprite_y
              bra        .move_sprite
.set_down:
              add.w      #SPRITE_SPEED,sprite_y
.move_sprite:
              lea        ship_sprite,a1
              move.w     sprite_y,d0                                  ; y position
              move.w     sprite_x,d1                                  ; x position
              move.w     #SPRITE_HEIGHT,d2                            ; sprite height
              bsr        set_sprite_position

              lea        ship_sprite+SPRITE_SIZE,a1
              bsr        set_sprite_position

              lea        ship_sprite+SPRITE_SIZE*2,a1
              add.w      #SPRITE_WIDTH,d1
              bsr        set_sprite_position

              lea        ship_sprite+SPRITE_SIZE*3,a1
              bsr        set_sprite_position

              movem.l    (sp)+,d0-a6
              rts


;************************************************************************
; VARIABLES
;************************************************************************
gfx_name      dc.b       "graphics.library",0,0                       ; string containing the name of graphics.library
gfx_base      dc.l       0                                            ; base address of graphics.library
old_dma       dc.w       0                                            ; saved state of DMACON
sys_coplist   dc.l       0                                            ; address of system copperlist                                     

map_ptr       dc.w       0                                            ; current map column
bgnd_x        dc.w       0                                            ; current x coordinate of camera into background surface
map           include    "gfx/shooter_map.i"

sprite_x      dc.w       64
sprite_y      dc.w       16

;************************************************************************
; Graphics data
;************************************************************************

; segment loaded in CHIP RAM
              SECTION    graphics_data,DATA_C

              CNOP       0,8                                          ; 64-bit alignment
copperlist:
              dc.w       DIWSTRT,$2cc1                                ; display window start at ($81,$2c)
              dc.w       DIWSTOP,$2cc1                                ; display window stop at ($1c1,$12c)
              dc.w       DDFSTRT,$38                                  ; display data fetch start at $18 to hide scrolling artifacts
              dc.w       DDFSTOP,$d0                                  ; display data fetch stop at $d0
              dc.w       BPLCON1
scrollx       dc.w       SCROLL_RESET_VALUE                           ; bits 0-3 and 4-7 scroll value                                         
              dc.w       BPLCON2,%100100                              ; sets sprites priority over playfield                                           
              dc.w       BPL1MOD,(BGND_WIDTH-VIEWPORT_WIDTH)/8-8      ; -8 because we fetch 64 more pixels                                          
              dc.w       BPL2MOD,(BGND_WIDTH-VIEWPORT_WIDTH)/8-8      ; -8 because of 64 bit fetch
            

; BPLCON0 ($100)
; bit 0: set to 1 to enable BLTCON3 register
; bit 4: most significant bit of bitplane number
; bit 9: set to 1 to enable composite video output
; bit 12-14: least significant bits of bitplane number
; bitplane number: 8 => %1000
;                                 5432109876543210
              dc.w       BPLCON0,%0000001000010001

; FMODE
; bit 0-1: 64 bit fetch mode
; bit 2-3: 64 pixel sprite width
              dc.w       FMODE,%1111

; BPLCON4
; bit 0-3 palette selection for even sprites
; bit 4-7 palette selection for odd sprites
; we select palette 7 for both so %1110
              dc.w       BPLCON4,%11101110

bplpointers:
              dc.w       $e0,0,$e2,0                                  ; plane 1
              dc.w       $e4,0,$e6,0                                  ; plane 2
              dc.w       $e8,0,$ea,0                                  ; plane 3
              dc.w       $ec,0,$ee,0                                  ; plane 4
              dc.w       $f0,0,$f2,0                                  ; plane 5
              dc.w       $f4,0,$f6,0                                  ; plane 6
              dc.w       $f8,0,$fa,0                                  ; plane 7
              dc.w       $fc,0,$fe,0                                  ; plane 8

sprite_pointers:
              dc.w       SPR0PTH,0,SPR0PTL,0
              dc.w       SPR1PTH,0,SPR1PTL,0
              dc.w       SPR2PTH,0,SPR2PTL,0
              dc.w       SPR3PTH,0,SPR3PTL,0
              dc.w       SPR4PTH,0,SPR4PTL,0
              dc.w       SPR5PTH,0,SPR5PTL,0
              dc.w       SPR6PTH,0,SPR6PTL,0
              dc.w       SPR7PTH,0,SPR7PTL,0
              
palette       incbin     "gfx/shooter_tiles.pal"                      ; palette
              incbin     "gfx/player_ship.pal"

              dc.w       $ffff,$fffe                                  ; end of copperlist

              CNOP       0,8
ship_sprite   incbin     "gfx/player_ship.raw"

              CNOP       0,8                                          ; 64-bit alignment
tileset       incbin     "gfx/shooter_tiles.raw"                      ; image 640 x 512 pixel , 8 bitplanes


;************************************************************************
; BSS DATA
;************************************************************************

              SECTION    bss_data,BSS_C

              CNOP       0,8                                          ; 64-bit alignment
bgnd_surface  ds.b       (BGND_PLANE_SIZE*N_PLANES)                   ; surface used for scrolling background

              END