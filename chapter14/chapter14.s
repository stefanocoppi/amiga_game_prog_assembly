;************************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 14 - Player's ship
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
ExecBase         equ $4
CIAAPRA          equ $bfe001

; DMACON register settings
; enables blitter DMA (bit 6)
; enables copper DMA (bit 7)
; enables bitplanes DMA (bit 8)
                     ;5432109876543210
DMASET           equ %1000001111000000             

; display
N_PLANES         equ 8
DISPLAY_WIDTH    equ 320
DISPLAY_HEIGHT   equ 256
DISPLAY_PLANE_SZ equ DISPLAY_HEIGHT*(DISPLAY_WIDTH/8)
DISPLAY_ROW_SIZE equ (DISPLAY_WIDTH/8)

; tiles
TILE_WIDTH       equ 64
TILE_HEIGHT      equ 64
TILE_PLANE_SZ    equ TILE_HEIGHT*(TILE_WIDTH/8)
TILESET_WIDTH    equ 640
TILESET_HEIGHT   equ 512
TILESET_ROW_SIZE equ (TILESET_WIDTH/8)
TILESET_PLANE_SZ equ (TILESET_HEIGHT*TILESET_ROW_SIZE)
TILESET_COLS     equ 10          
TILEMAP_WIDTH    equ 100
TILEMAP_ROW_SIZE equ TILEMAP_WIDTH*2

; background
BGND_WIDTH       equ 2*DISPLAY_WIDTH+2*TILE_WIDTH
BGND_HEIGHT      equ 192
BGND_PLANE_SIZE  equ BGND_HEIGHT*(BGND_WIDTH/8)
BGND_ROW_SIZE    equ (BGND_WIDTH/8)

; scroll
VIEWPORT_HEIGHT  equ 192
VIEWPORT_WIDTH   equ 320
SCROLL_SPEED     equ 1

PLSHIP_WIDTH     equ 64
PLSHIP_HEIGHT    equ 28
PLSHIP_X0        equ 24
PLSHIP_Y0        equ 81
PLSHIP_XMIN      equ 20
PLSHIP_XMAX      equ VIEWPORT_WIDTH-PLSHIP_WIDTH
PLSHIP_YMIN      equ 0
PLSHIP_YMAX      equ VIEWPORT_HEIGHT-PLSHIP_HEIGHT


;****************************************************************
; DATA STRUCTURES
;****************************************************************

; bob
                   rsreset
bob.x              rs.w       1                            
bob.y              rs.w       1
bob.speed          rs.w       1
bob.width          rs.w       1
bob.height         rs.w       1
bob.ssheet_c       rs.w       1                                                        ; spritesheet column of the bob
bob.ssheet_r       rs.w       1                                                        ; spritesheet row of the bob
bob.ssheet_w       rs.w       1                                                        ; spritesheet width in pixels
bob.ssheet_h       rs.w       1                                                        ; spritesheet height in pixels
bob.imgdata        rs.l       1                                                        ; image data address
bob.mask           rs.l       1                                                        ; mask address
bob.anim_duration  rs.w       1                                                        ; duration of animation in frames
bob.anim_timer     rs.w       1                                                        ; timer for animation
bob.length         rs.b       0 


                   SECTION    code_section,CODE

;************************************************************************
; MAIN PROGRAM
;************************************************************************
main:
                   nop
                   nop
                   bsr        take_system                                              ; takes the control of Amiga's hardware
                   bsr        init_bplpointers                                         ; initializes bitplane pointers to our image

                   move.w     map_ptr,d0
                   bsr        init_background
                   move.w     #TILE_WIDTH,bgnd_x                                       ; x position of the part of background to draw

                   bsr        plship_init

mainloop: 
                   bsr        wait_vblank                                              ; waits for vertical blank
                   bsr        swap_buffers

                   bsr        scroll_background
              
                   bsr        plship_update

                   bsr        plship_draw
               
                   btst       #6,CIAAPRA                                               ; left mouse button pressed?
                   bne.s      mainloop                                                 ; if not, repeats the loop

                   bsr        release_system                                           ; releases the hw control to the O.S.
                   rts


;************************************************************************
; SUBROUTINES
;************************************************************************

;************************************************************************
; Takes full control of Amiga hardware,
; disabling the O.S. in a controlled way.
;************************************************************************
take_system:
                   move.l     ExecBase,a6                                              ; base address of Exec
                   jsr        _LVOForbid(a6)                                           ; disables O.S. multitasking
                   jsr        _LVODisable(a6)                                          ; disables O.S. interrupts

                   lea        gfx_name,a1                                              ; OpenLibrary takes 1 parameter: library name in a1
                   jsr        _LVOOldOpenLibrary(a6)                                   ; opens graphics.library
                   move.l     d0,gfx_base                                              ; saves base address of graphics.library in a variable
            
                   move.l     d0,a6                                                    ; gfx base                   
                   move.l     $26(a6),sys_coplist                                      ; saves system copperlist address
             
                   jsr        _LVOOwnBlitter(a6)                                       ; takes the Blitter exclusive

                   lea        CUSTOM,a5                                                ; a5 will always contain CUSTOM chips base address $dff000
          
                   move.w     DMACONR(a5),old_dma                                      ; saves state of DMA channels in a variable
                   move.w     #$7fff,DMACON(a5)                                        ; disables all DMA channels
                   move.w     #DMASET,DMACON(a5)                                       ; sets only dma channels that we will use

                   move.l     #copperlist,COP1LC(a5)                                   ; sets our copperlist address into Copper
                   move.w     d0,COPJMP1(a5)                                           ; reset Copper PC to the beginning of our copperlist       

                   move.w     #0,FMODE(a5)                                             ; sets 16 bit FMODE
                   move.w     #$c00,BPLCON3(a5)                                        ; sets default value                       
                   move.w     #$11,BPLCON4(a5)                                         ; sets default value

                   rts


;************************************************************************
; Releases the hardware control to the O.S.
;************************************************************************
release_system:
                   move.l     sys_coplist,COP1LC(a5)                                   ; restores the system copperlist
                   move.w     d0,COPJMP1(a5)                                           ; starts the system copperlist 

                   or.w       #$8000,old_dma                                           ; sets bit 15
                   move.w     old_dma,DMACON(a5)                                       ; restores saved DMA state

                   move.l     gfx_base,a6
                   jsr        _LVODisownBlitter(a6)                                    ; release Blitter ownership
                   move.l     ExecBase,a6                                              ; base address of Exec
                   jsr        _LVOPermit(a6)                                           ; enables O.S. multitasking
                   jsr        _LVOEnable(a6)                                           ; enables O.S. interrupts
                   move.l     gfx_base,a1                                              ; base address of graphics.library in a1
                   jsr        _LVOCloseLibrary(a6)                                     ; closes graphics.library
                   rts


;************************************************************************
; Initializes bitplane pointers
;************************************************************************
init_bplpointers:
                   movem.l    d0-a6,-(sp)
                   
                   move.l     #dbuffer1,d0                                             ; address of visible screen buffer
                   lea        bplpointers,a1                                           ; bitplane pointers in a1
                   move.l     #(N_PLANES-1),d1                                         ; number of loop iterations in d1
.loop:
                   move.w     d0,6(a1)                                                 ; copy low word of image address into BPLxPTL (low word of BPLxPT)
                   swap       d0                                                       ; swap high and low word of image address
                   move.w     d0,2(a1)                                                 ; copy high word of image address into BPLxPTH (high word of BPLxPT)
                   swap       d0                                                       ; resets d0 to the initial condition
                   add.l      #DISPLAY_PLANE_SZ,d0                                     ; point to the next bitplane
              ;add.l      #BGND_PLANE_SIZE,d0                                      ; point to the next bitplane
                   add.l      #8,a1                                                    ; point to next bplpointer
                   dbra       d1,.loop                                                 ; repeats the loop for all planes
            
                   movem.l    (sp)+,d0-a6
                   rts 


;************************************************************************
; Wait for the blitter to finish
;************************************************************************
wait_blitter:
.loop:
                   btst.b     #6,DMACONR(a5)                                           ; if bit 6 is 1, the blitter is busy
                   bne        .loop                                                    ; and then wait until it's zero
                   rts 


;************************************************************************
; Waits for the electron beam to reach a given line.
;
; parameters:
; d2.l - line
;************************************************************************
wait_vline:
                   movem.l    d0-a6,-(sp)                                              ; saves registers into the stack

                   lsl.l      #8,d2
                   move.l     #$1ff00,d1
wait:
                   move.l     VPOSR(a5),d0
                   and.l      d1,d0
                   cmp.l      d2,d0
                   bne.s      wait

                   movem.l    (sp)+,d0-a6                                              ; restores registers from the stack
                   rts


;************************************************************************
; Waits for the vertical blank
;************************************************************************
wait_vblank:
                   movem.l    d0-a6,-(sp)                                              ; saves registers into the stack
                   move.l     #304,d2                                                  ; line to wait: 304 236
                   bsr        wait_vline
                   movem.l    (sp)+,d0-a6                                              ; restores registers from the stack
                   rts


;************************************************************************
; Swaps video buffers, causing draw_buffer to be displayed.
;************************************************************************
swap_buffers:
                   movem.l    d0-a6,-(sp)                                              ; saves registers into the stack

                   move.l     draw_buffer,d0                                           ; swaps the values ​​of draw_buffer and view_buffer
                   move.l     view_buffer,draw_buffer
                   move.l     d0,view_buffer
                   lea        bplpointers,a1                                           ; sets the bitplane pointers to the view_buffer 
                   moveq      #N_PLANES-1,d1                                            
.loop:
                   move.w     d0,6(a1)                                                 ; copies low word
                   swap       d0                                                       ; swaps low and high word of d0
                   move.w     d0,2(a1)                                                 ; copies high word
                   swap       d0                                                       ; resets d0 to the initial condition
                   add.l      #DISPLAY_PLANE_SZ,d0                                     ; points to the next bitplane
                   add.l      #8,a1                                                    ; points to next bplpointer
                   dbra       d1,.loop                                                 ; repeats the loop for all planes

                   movem.l    (sp)+,d0-a6                                              ; restores registers from the stack
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
                   movem.l    d0-a6,-(sp)                                              ; saves registers into the stack

; calculates the screen address where to draw the tile
                   mulu       #BGND_ROW_SIZE,d3                                        ; y_offset = y * BGND_ROW_SIZE
                   lsr.w      #3,d2                                                    ; x_offset = x / 8
                   ext.l      d2
                   add.l      d3,a1                                                    ; sums offsets to a1
                   add.l      d2,a1

; calculates row and column of tile in tileset starting from index
                   ext.l      d0                                                       ; extends d0 to a long because the destination operand if divu must be long
                   divu       #TILESET_COLS,d0                                         ; tile_index / TILESET_COLS
                   swap       d0
                   move.w     d0,d1                                                    ; the remainder indicates the tile column
                   swap       d0                                                       ; the quotient indicates the tile row
         
; calculates the x,y coordinates of the tile in the tileset
                   lsl.w      #6,d0                                                    ; y = row * 64
                   lsl.w      #6,d1                                                    ; x = column * 64
         
; calculates the offset to add to a0 to get the address of the source image
                   mulu       #TILESET_ROW_SIZE,d0                                     ; offset_y = y * TILESET_ROW_SIZE
                   lsr.w      #3,d1                                                    ; offset_x = x / 8
                   ext.l      d1

                   lea        tileset,a0                                               ; source image address
                   add.l      d0,a0                                                    ; add y_offset
                   add.l      d1,a0                                                    ; add x_offset

                   moveq      #N_PLANES-1,d7
         
                   bsr        wait_blitter
                   move.w     #$ffff,BLTAFWM(a5)                                       ; don't use mask
                   move.w     #$ffff,BLTALWM(a5)
                   move.w     #$09f0,BLTCON0(a5)                                       ; enable channels A,D
                                                                                  ; logical function = $f0, D = A
                   move.w     #0,BLTCON1(a5)
                   move.w     #(TILESET_WIDTH-TILE_WIDTH)/8,BLTAMOD(a5)                ; A channel modulus
                   move.w     #(BGND_WIDTH-TILE_WIDTH)/8,BLTDMOD(a5)                   ; D channel modulus
.loop:
                   bsr        wait_blitter
                   move.l     a0,BLTAPT(a5)                                            ; source address
                   move.l     a1,BLTDPT(a5)                                            ; destination address
                   move.w     #64*64+4,BLTSIZE(a5)                                     ; blit size: 64 rows for 4 word
                   add.l      #TILESET_PLANE_SZ,a0                                     ; advances to the next plane
                   add.l      #BGND_PLANE_SIZE,a1
                   dbra       d7,.loop
                   bsr        wait_blitter

                   movem.l    (sp)+,d0-a6                                              ; restore registers from the stack
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
                   lsl.w      #1,d0                                                    ; offset_x = map_column * 2
                   ext.l      d0
                   add.l      d0,a0
         
                   moveq      #3-1,d7                                                  ; number or tilemap rows - 1
                   move.w     #0,d3                                                    ; y position
.loop:
                   move.w     (a0),d0                                                  ; tile index
                   bsr        draw_tile
                   add.w      #TILE_HEIGHT,d3                                          ; increment y position
                   add.l      #TILEMAP_ROW_SIZE,a0                                     ; move to the next row of the tilemap
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
                   moveq      #5-1,d7                                                  ; number of tile columns - 1 to draw
                   lea        bgnd_surface,a1                                          ; address where draw the tile
                   move.w     #TILE_WIDTH,d2                                           ; position x
.loop              bsr        draw_tile_column
                   add.w      #1,d0                                                    ; increment map column
                   add.w      #1,map_ptr
                   add.w      #TILE_WIDTH,d2                                           ; increase position x
                   dbra       d7,.loop

; draws the column to the left of the display window
                   add.w      #1,d0                                                    ; map column
                   add.w      #1,map_ptr
                   move.w     #0,d2                                                    ; x position
                   lea        bgnd_surface,a1
                   bsr        draw_tile_column

; draws the column to the right of the display window
                   move.w     #DISPLAY_WIDTH+TILE_WIDTH,d2                             ; x position
                   lea        bgnd_surface,a1
                   bsr        draw_tile_column

                   movem.l    (sp)+,d0-a6
                   rts


;************************************************************************
; Draws the background, copying it from background_surface via Blitter.
;
; parameters:
;
; d0.w - x position of the part of background to draw
; a1   - buffer where to draw
;************************************************************************
draw_background:
                   movem.l    d0-a6,-(sp)

                   moveq      #N_PLANES-1,d7
                   lea        bgnd_surface,a0
; calculates the source image address
                   move.w     d0,d2                                                    ; copy of x
                   asr.w      #3,d0                                                    ; offset_x = x/8
                   and.w      #$fffe,d0                                                ; rounds to even addresses
                   ext.l      d0
; calculates the shift value
                   add.l      d0,a0                                                    ; address of image to copy
                   and.w      #$000f,d2                                                ; selects the first 4 bits, which correspond to the shift
                   move.w     #$f,d3                                                   ; since we want a left scroll, 
                   sub.w      d2,d3                                                    ; we need to decrement the value of scroll, i.e. $f-scroll
                   lsl.w      #8,d3                                                    ; moves the 4 shift bits to the position they occupy in BLTCON0
                   lsl.w      #4,d3
                   or.w       #$09f0,d3                                                ; inserts the 4 bits into the value to be assigned to BLTCON0
.planeloop:
                   bsr        wait_blitter
                   move.l     a0,BLTAPT(a5)                                            ; channel A points to background surface
                   move.l     a1,BLTDPT(a5)                                            ; channel D points to draw buffer
                   move.w     #$ffff,BLTAFWM(a5)                                       ; no first word mask
                   move.w     #$0000,BLTALWM(a5)                                       ; masks last word
                   move.w     d3,BLTCON0(a5)                                            
                   move.w     #0,BLTCON1(a5)
                   move.w     #(BGND_WIDTH-VIEWPORT_WIDTH-16)/8,BLTAMOD(a5) 
                   move.w     #(DISPLAY_WIDTH-VIEWPORT_WIDTH-16)/8,BLTDMOD(a5)
                   move.w     #VIEWPORT_HEIGHT<<6+(VIEWPORT_WIDTH/16)+1,BLTSIZE(a5)
                   move.l     a0,d0
                   add.l      #BGND_PLANE_SIZE,d0                                      ; points a0 to the next plane
                   move.l     d0,a0
                   move.l     a1,d0
                   add.l      #DISPLAY_PLANE_SZ,d0                                     ; points a1 to the next plane
                   move.l     d0,a1
                   dbra       d7,.planeloop

                   movem.l    (sp)+,d0-a6
                   rts


;************************************************************************
; Scrolls the background to the left.
;************************************************************************
scroll_background:
                   movem.l    d0-a6,-(sp)

                   move.w     bgnd_x,d0                                                ; x position of the part of background to draw
                   move.l     draw_buffer,a1                                           ; buffer where to draw                                                  
                   bsr        draw_background

                   ext.l      d0                                                       ; every TILE_WIDTH (64) pixels draws a new column
                   divu       #TILE_WIDTH,d0
                   swap       d0
                   tst.w      d0                                                       ; remainder of bgnd_x/TILE_WIDTH is zero?
                   beq        .draw_new_column
                   bra        .check_bgnd_end
.draw_new_column:
                   add.w      #1,map_ptr
                   cmp.w      #TILEMAP_WIDTH,map_ptr                                   ; end of map?
                   bge        .return

                   move.w     map_ptr,d0                                               ; map column
                   move.w     bgnd_x,d2                                                ; x position = bgnd_x - TILE_WIDTH
                   sub.w      #TILE_WIDTH,d2
                   lea        bgnd_surface,a1
                   bsr        draw_tile_column                                         ; draws the column to the left of the viewport

                   move.w     bgnd_x,d2                                                ; x position = bgnd_x + VIEWPORT_WIDTH
                   add.w      #VIEWPORT_WIDTH,d2 
                   lea        bgnd_surface,a1
                   bsr        draw_tile_column                                         ; draws the column to the right of the viewport
.check_bgnd_end:
                   cmp.w      #TILE_WIDTH+VIEWPORT_WIDTH,bgnd_x                        ; end of background surface?
                   ble        .incr_x
                   move.w     #SCROLL_SPEED,bgnd_x                                     ; resets x position of the part of background to draw
                   bra        .return
.incr_x            add.w      #SCROLL_SPEED,bgnd_x                                     ; increases x position of the part of background to draw

.return            movem.l    (sp)+,d0-a6
                   rts


;************************************************************************
; Draws a Bob using the blitter.
;
; parameters:
; a3 - bob's data
; a2 - destination video buffer address
;************************************************************************
draw_bob:
                   movem.l    d0-a6,-(sp)

    ; calculates destination address (D channel)
                   move.w     bob.y(a3),d1
                   mulu.w     #DISPLAY_ROW_SIZE,d1                                     ; offset_y = y * DISPLAY_ROW_SIZE
                   add.l      d1,a2                                                    ; adds offset_y to destination address
                   move.w     bob.x(a3),d0
                   lsr.w      #3,d0                                                    ; offset_x = x/8
                   and.w      #$fffe,d0                                                ; makes offset_x even
                   add.w      d0,a2                                                    ; adds offset_x to destination address
    
    ; calculates source address (channels A,B)
                   move.l     bob.imgdata(a3),a0
                   move.l     bob.mask(a3),a1
                   move.w     bob.width(a3),d1             
                   lsr.w      #3,d1                                                    ; bob width in bytes (bob_width/8)
                   move.w     bob.ssheet_c(a3),d4
                   mulu       d1,d4                                                    ; offset_x = column * (bob_width/8)
                   add.w      d4,a0                                                    ; adds offset_x to the base address of bob's image
                   add.w      d4,a1                                                    ; and bob's mask
                   move.w     bob.height(a3),d3
                   move.w     bob.ssheet_r(a3),d5
                   mulu       d3,d5                                                    ; bob_height * row
                   move.w     bob.ssheet_w(a3),d1
                   asr.w      #3,d1                                                    ; spritesheet_row_size = spritesheet_width / 8
                   mulu       d1,d5                                                    ; offset_y = row * bob_height * spritesheet_row_size
                   add.w      d5,a0                                                    ; adds offset_y to the base address of bob's image
                   add.w      d5,a1                                                    ; and bob's mask

    ; calculates the modulus of channels A,B
                   move.w     bob.ssheet_w(a3),d1                                      ; copies spritesheet_width in d1
                   move.w     bob.width(a3),d2
                   sub.w      d2,d1                                                    ; spritesheet_width - bob_width
                   sub.w      #16,d1                                                   ; spritesheet_width - bob_width -16
                   asr.w      #3,d1                                                    ; (spritesheet_width - bob_width -16)/8

    ; calculates the modulus of channels C,D
                   move.w     bob.width(a3),d2
                   lsr        #3,d2                                                    ; bob_width/8
                   add.w      #2,d2                                                    ; adds 2 to the sprite width in bytes, due to the shift
                   move.w     #DISPLAY_ROW_SIZE,d4                                     ; screen width in bytes
                   sub.w      d2,d4                                                    ; modulus (d4) = screen_width - bob_width
    
    ; calculates the shift value for channels A,B (d6) and value of BLTCON0 (d5)
                   move.w     bob.x(a3),d6
                   and.w      #$000f,d6                                                ; selects the first 4 bits of x
                   lsl.w      #8,d6                                                    ; moves the shift value to the upper nibble
                   lsl.w      #4,d6                                                    ; so as to have the value to insert in BLTCON1
                   move.w     d6,d5                                                    ; copy to calculate the value to insert in BLTCON0
                   or.w       #$0fca,d5                                                ; value to insert in BLTCON0
                                                       ; logic function LF = $ca

    ; calculates the blit size (d3)
                   move.w     bob.height(a3),d3
                   lsl.w      #6,d3                                                    ; bob_height<<6
                   lsr.w      #1,d2                                                    ; bob_width/2 (in word)
                   or         d2,d3                                                    ; combines the dimensions into the value to be inserted into BLTSIZE

    ; calculates the size of a BOB spritesheet bitplane
                   move.w     bob.ssheet_w(a3),d2                                      ; copies spritesheet_width in d2
                   lsr.w      #3,d2                                                    ; spritesheet_width/8
                   and.w      #$fffe,d2                                                ; makes even
                   move.w     bob.ssheet_h(a3),d0                                      ; spritesheet_height
                   mulu       d0,d2                                                    ; multiplies by the height

    ; initializes the registers that remain constant
                   bsr        wait_blitter
                   move.w     #$ffff,BLTAFWM(a5)                                       ; first word of channel A: no mask
                   move.w     #$0000,BLTALWM(a5)                                       ; last word of channel A: reset all bits
                   move.w     d6,BLTCON1(a5)                                           ; shift value for channel A
                   move.w     d5,BLTCON0(a5)                                           ; activates all 4 channels,logic_function=$CA,shift
                   move.w     d1,BLTAMOD(a5)                                           ; modules for channels A,B
                   move.w     d1,BLTBMOD(a5)
                   move.w     d4,BLTCMOD(a5)                                           ; modules for channels C,D
                   move.w     d4,BLTDMOD(a5)
                   moveq      #N_PLANES-1,d7                                           ; number of cycle repetitions

    ; copy cycle for each bitplane
.plane_loop:
                   bsr        wait_blitter
                   move.l     a1,BLTAPT(a5)                                            ; channel A: Bob's mask
                   move.l     a0,BLTBPT(a5)                                            ; channel B: Bob's image
                   move.l     a2,BLTCPT(a5)                                            ; channel C: draw buffer
                   move.l     a2,BLTDPT(a5)                                            ; channel D: draw buffer
                   move.w     d3,BLTSIZE(a5)                                           ; blit size and starts blit operation

                   add.l      d2,a0                                                    ; points to the next bitplane
                   add.l      #DISPLAY_PLANE_SZ,a2                                         
                   dbra       d7,.plane_loop                                           ; repeats the cycle for each bitplane

                   movem.l    (sp)+,d0-a6
                   rts


;****************************************************************
; Initializes the player's ship state
;****************************************************************
plship_init:
                   movem.l    d0-a6,-(sp)

                   lea        bob_ship,a0
                   move.w     #PLSHIP_X0,bob.x(a0)
                   move.w     #PLSHIP_Y0,bob.y(a0)
                   clr.w      bob.ssheet_c(a0)
                   move.w     bob.anim_duration(a0),bob.anim_timer(a0)

                   lea        bob_ship_engine,a1
                   move.w     #PLSHIP_X0-17,bob.x(a1)
                   move.w     #PLSHIP_Y0+9,bob.y(a1)
                   clr.w      bob.ssheet_c(a1)
                   move.w     bob.anim_duration(a1),bob.anim_timer(a1)
                  
.return:
                   movem.l    (sp)+,d0-a6
                   rts


;****************************************************************
; Draw the player's ship
;****************************************************************
plship_draw:
                   movem.l    d0-a6,-(sp)

                   lea        bob_ship,a3
                   move.l     draw_buffer,a2
                   bsr        draw_bob                                                 ; draws ship

                   lea        bob_ship_engine,a3
                   move.l     draw_buffer,a2
                   bsr        draw_bob                                                 ; draws engine fire                   
                  
.return:
                   movem.l    (sp)+,d0-a6
                   rts


;****************************************************************
; Moves the player's ship with the joystick
;
; parameters:
; a0 - player's ship
;****************************************************************
plship_move_with_joystick:
                   movem.l    d0-a6,-(sp)

                   move.w     JOY1DAT(a5),d0
                   move.w     bob.speed(a0),d2
                   btst.l     #1,d0                                                    ; joy right?
                   bne        .set_right
                   btst.l     #9,d0                                                    ; joy left?
                   bne        .set_left
                   bra        .check_up
.set_right:
                   add.w      d2,bob.x(a0)                                             ; bob.x += bob.speed 
                   bra        .check_up
.set_left:
                   sub.w      d2,bob.x(a0)                                             ; bob.x -= bob.speed
.check_up:
                   move.w     d0,d1
                   lsr.w      #1,d1
                   eor.w      d1,d0
                   btst.l     #8,d0                                                    ; joy up?
                   bne        .set_up
                   btst.l     #0,d0                                                    ; joy down?
                   bne        .set_down
                   bra        .return
.set_up:
                   sub.w      d2,bob.y(a0)                                             ; bob.y -= bob.speed
                   bra        .return
.set_down:
                   add.w      d2,bob.y(a0)                                             ; bob.y += bob.speed

.return:
                   movem.l    (sp)+,d0-a6
                   rts


;****************************************************************
; Updates the player's ship state
;****************************************************************
plship_update:
                   movem.l    d0-a6,-(sp)

                   lea        bob_ship,a0
                   bsr        plship_move_with_joystick
                   bsr        plship_limit_movement

; sets engine fire bob position
                   lea        bob_ship_engine,a1
                   move.w     bob.x(a0),d0
                   sub.w      #17,d0
                   move.w     d0,bob.x(a1)                                             ; engine.x = ship.x - 17
                   move.w     bob.y(a0),d0
                   add.w      #9,d0
                   move.w     d0,bob.y(a1)                                             ; engine.y = ship.y + 9

; animates engine fire
                   sub.w      #1,bob.anim_timer(a1)
                   tst.w      bob.anim_timer(a1)                                       ; anim_timer = 0?
                   beq        .incr_frame
                   bra        .return
.incr_frame:
                   add.w      #1,bob.ssheet_c(a1)                                      ; increases animation frame
                   cmp.w      #4,bob.ssheet_c(a1)                                      ; ssheet_c >= 4?
                   bge        .reset_frame
                   bra        .reset_timer
.reset_frame:
                   clr.w      bob.ssheet_c(a1)                                         ; resets animation frame
.reset_timer:
                   move.w     bob.anim_duration(a1),bob.anim_timer(a1)                 ; resets anim_timer
.return:
                   movem.l    (sp)+,d0-a6
                   rts


;****************************************************************
; Limits player's ship movement, avoiding exiting from the viewport.
;
; parameters:
; a0 - player's ship
;****************************************************************
plship_limit_movement:
                   movem.l    d0-a6,-(sp)

                   move.w     bob.x(a0),d0
                   cmp.w      #PLSHIP_XMIN,d0                                          ; x < PLSHIP_XMIN?
                   blt        .limit_xmin
                   bra        .check_xmax
.limit_xmin:
                   move.w     #PLSHIP_XMIN,bob.x(a0)                                   ; x = PLSHIP_XMIN
                   bra        .check_ymin
.check_xmax:
                   cmp.w      #PLSHIP_XMAX,d0                                          ; x > PLSHIP_XMAX?
                   bgt        .limit_xmax
                   bra        .check_ymin
.limit_xmax:
                   move.w     #PLSHIP_XMAX,bob.x(a0)                                   ; x = PLSHIP_XMAX
.check_ymin:
                   move.w     bob.y(a0),d0
                   cmp.w      #PLSHIP_YMIN,d0                                          ; y < PLSHIP_YMIN?
                   blt        .limit_ymin
                   bra        .check_ymax
.limit_ymin:
                   move.w     #PLSHIP_YMIN,bob.y(a0)                                   ; y = PLSHIP_YMIN
                   bra        .return
.check_ymax:
                   cmp.w      #PLSHIP_YMAX,d0                                          ; y > PLSHIP_YMAX?
                   bgt        .limit_ymax
                   bra        .return
.limit_ymax:
                   move.w     #PLSHIP_YMAX,bob.y(a0)                                   ; y = PLSHIP_YMAX
.return:
                   movem.l    (sp)+,d0-a6
                   rts





;************************************************************************
; VARIABLES
;************************************************************************
gfx_name           dc.b       "graphics.library",0,0                                   ; string containing the name of graphics.library
gfx_base           dc.l       0                                                        ; base address of graphics.library
old_dma            dc.w       0                                                        ; saved state of DMACON
sys_coplist        dc.l       0                                                        ; address of system copperlist                                     

map_ptr            dc.w       3                                                        ; current map column
bgnd_x             dc.w       0                                                        ; current x coordinate of camera into background surface
map                include    "gfx/shooter_map.i"

view_buffer        dc.l       dbuffer1                                                 ; buffer displayed on screen
draw_buffer        dc.l       dbuffer2                                                 ; drawing buffer (not visible)

bob_ship           dc.w       0                                                        ; x position
                   dc.w       0                                                        ; y position
                   dc.w       1                                                        ; bob.speed
                   dc.w       64                                                       ; width
                   dc.w       28                                                       ; height  
                   dc.w       0                                                        ; spritesheet column of the bob
                   dc.w       0                                                        ; spritesheet row of the bob
                   dc.w       64                                                       ; spritesheet width in pixels
                   dc.w       28                                                       ; spritesheet height in pixels
                   dc.l       ship                                                     ; image data address
                   dc.l       ship_mask                                                ; mask address
                   dc.w       0                                                        ; bob.anim_duration
                   dc.w       0                                                        ; bob.anim_timer

bob_ship_engine    dc.w       0                                                        ; x position
                   dc.w       0                                                        ; y position
                   dc.w       1                                                        ; bob.speed
                   dc.w       32                                                       ; width
                   dc.w       16                                                       ; height  
                   dc.w       0                                                        ; spritesheet column of the bob
                   dc.w       0                                                        ; spritesheet row of the bob
                   dc.w       128                                                      ; spritesheet width in pixels
                   dc.w       16                                                       ; spritesheet height in pixels
                   dc.l       ship_engine                                              ; image data address
                   dc.l       ship_engine_m                                            ; mask address
                   dc.w       5                                                        ; bob.anim_duration
                   dc.w       5                                                        ; bob.anim_timer


;************************************************************************
; Graphics data
;************************************************************************

; segment loaded in CHIP RAM
                   SECTION    graphics_data,DATA_C

copperlist:
                   dc.w       DIWSTRT,$2c91                                            ; display window start at ($91,$2c)
              ;dc.w       DIWSTRT,$2c81                                            ; display window start at ($81,$2c)
                   dc.w       DIWSTOP,$2cc1                                            ; display window stop at ($1c1,$12c)
                   dc.w       DDFSTRT,$38                                              ; display data fetch start at $38
                   dc.w       DDFSTOP,$d0                                              ; display data fetch stop at $d0
                   dc.w       BPLCON1,0                                          
                   dc.w       BPLCON2,0                                             
                   dc.w       BPL1MOD,0                                            
                   dc.w       BPL2MOD,0
            

  ; BPLCON0 ($100)
  ; bit 0: set to 1 to enable BLTCON3 register
  ; bit 4: most significant bit of bitplane number
  ; bit 9: set to 1 to enable composite video output
  ; bit 12-14: least significant bits of bitplane number
  ; bitplane number: 8 => %1000
  ;                               5432109876543210
                   dc.w       BPLCON0,%0000001000010001
                   dc.w       FMODE,0                                                  ; 16 bit fetch mode

bplpointers:
                   dc.w       $e0,0,$e2,0                                              ; plane 1
                   dc.w       $e4,0,$e6,0                                              ; plane 2
                   dc.w       $e8,0,$ea,0                                              ; plane 3
                   dc.w       $ec,0,$ee,0                                              ; plane 4
                   dc.w       $f0,0,$f2,0                                              ; plane 5
                   dc.w       $f4,0,$f6,0                                              ; plane 6
                   dc.w       $f8,0,$fa,0                                              ; plane 7
                   dc.w       $fc,0,$fe,0                                              ; plane 8

palette            incbin     "gfx/shooter.pal"                                        ; palette

                   dc.w       $ffff,$fffe                                              ; end of copperlist

         
tileset            incbin     "gfx/shooter_tiles.raw"                                  ; image 640 x 512 pixel , 8 bitplanes

ship               incbin     "gfx/ship.raw"
ship_mask          incbin     "gfx/ship.mask"

ship_engine        incbin     "gfx/ship_engine.raw"
ship_engine_m      incbin     "gfx/ship_engine.mask"


;************************************************************************
; BSS DATA
;************************************************************************

                   SECTION    bss_data,BSS_C

dbuffer1           ds.b       (DISPLAY_PLANE_SZ*N_PLANES)                              ; display buffers used for double buffering
dbuffer2           ds.b       (DISPLAY_PLANE_SZ*N_PLANES)   

bgnd_surface       ds.b       (BGND_PLANE_SIZE*N_PLANES)                               ; invisible surface used for scrolling background

                   END