;************************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 14C - Player's ship
;
; optimized version using hardware scrolling and dual playfield mode
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
ExecBase            equ $4
Disable             equ -$78
Forbid              equ -132
Enable              equ -$7e
Permit              equ -138
OpenLibrary         equ -$198
CloseLibrary        equ -$19e
CIAAPRA             equ $bfe001

; DMACON register settings
; enables blitter DMA (bit 6)
; enables copper DMA (bit 7)
; enables bitplanes DMA (bit 8)
                     ;5432109876543210
DMASET              equ %1000001111000000             

; display
N_PLANES            equ 4
DISPLAY_WIDTH       equ 320
DISPLAY_HEIGHT      equ 256
DISPLAY_PLANE_SZ    equ DISPLAY_HEIGHT*(DISPLAY_WIDTH/8)
DISPLAY_ROW_SIZE    equ (DISPLAY_WIDTH/8)

BPP                 equ 4
WINDOW_WIDTH        equ 336
WINDOW_HEIGHT       equ 192
CLIP_WIDTH          equ 32

; tiles
TILE_WIDTH          equ 64
TILE_HEIGHT         equ 64
TILE_PLANE_SZ       equ TILE_HEIGHT*(TILE_WIDTH/8)
TILESET_WIDTH       equ 640
TILESET_HEIGHT      equ 512
TILESET_ROW_SIZE    equ (TILESET_WIDTH/8)
TILESET_PLANE_SZ    equ (TILESET_HEIGHT*TILESET_ROW_SIZE)
TILESET_COLS        equ 10          
TILEMAP_WIDTH       equ 100
TILEMAP_ROW_SIZE    equ TILEMAP_WIDTH*2

; background
BGND_WIDTH          equ 2*DISPLAY_WIDTH+2*TILE_WIDTH
BGND_HEIGHT         equ 256
BGND_PLANE_SIZE     equ BGND_HEIGHT*(BGND_WIDTH/8)
BGND_ROW_SIZE       equ (BGND_WIDTH/8)

; playfield 1: scrolling background
PF1_WIDTH           equ 2*DISPLAY_WIDTH+2*TILE_WIDTH
PF1_HEIGHT          equ 256
PF1_ROW_SIZE        equ PF1_WIDTH/8
PF1_MOD             equ (PF1_WIDTH-VIEWPORT_WIDTH)/8
PF1_PLANE_SZ        equ PF1_ROW_SIZE*PF1_HEIGHT

; playfield2 used for BOBs rendering
PF2_WIDTH           equ 320
PF2_HEIGHT          equ 256
PF2_ROW_SIZE        equ PF2_WIDTH/8
PF2_MOD             equ (PF2_WIDTH-VIEWPORT_WIDTH)/8
PF2_PLANE_SZ        equ PF2_ROW_SIZE*PF2_HEIGHT

BGND_LIST_MAX_ITEMS equ 100

; scroll
VIEWPORT_HEIGHT     equ 192
VIEWPORT_WIDTH      equ 320

PLSHIP_WIDTH        equ 64
PLSHIP_HEIGHT       equ 28
PLSHIP_X0           equ 32+8
PLSHIP_Y0           equ 81
PLSHIP_XMIN         equ 32+8
PLSHIP_XMAX         equ 32+VIEWPORT_WIDTH-PLSHIP_WIDTH
PLSHIP_YMIN         equ 0
PLSHIP_YMAX         equ VIEWPORT_HEIGHT-PLSHIP_HEIGHT


;****************************************************************
; DATA STRUCTURES
;****************************************************************

; bob
                    rsreset
bob.x               rs.w       1                            
bob.y               rs.w       1
bob.speed           rs.w       1
bob.width           rs.w       1
bob.height          rs.w       1
bob.ssheet_c        rs.w       1                                             ; spritesheet column of the bob
bob.ssheet_r        rs.w       1                                             ; spritesheet row of the bob
bob.ssheet_w        rs.w       1                                             ; spritesheet width in pixels
bob.ssheet_h        rs.w       1                                             ; spritesheet height in pixels
bob.imgdata         rs.l       1                                             ; image data address
bob.mask            rs.l       1                                             ; mask address
bob.length          rs.b       0 

; background of a bob, which needs to be cleared for moving the bob
                    rsreset
bob_bgnd.addr       rs.l       1                                             ; address in the playfield
bob_bgnd.width      rs.w       1                                             ; width in pixel
bob_bgnd.height     rs.w       1                                             ; height in pixel
bob_bgnd.length     rs.b       0

; player's ship
                    rsreset
ship.bob            rs.b       bob.length
ship.anim_duration  rs.w       1                                             ; duration of animation in frames
ship.anim_timer     rs.w       1                                             ; timer for animation
ship.length         rs.b       0 


                    SECTION    code_section,CODE

;************************************************************************
; MAIN PROGRAM
;************************************************************************
main:
                    nop
                    nop
                    bsr        take_system                                   ; takes the control of Amiga's hardware
             
                    lea        bplpointers1,a1                               ; bitplane pointers in a1
                    move.l     #playfield1+8-2,d0                            ; address of background playfield
                    move.l     #PF1_PLANE_SZ,d1 
                    bsr        init_bplpointers                              ; initializes bitplane pointers for background playfield

                    lea        bplpointers2,a1                               ; bitplane pointers in a1
                    move.l     #playfield2a,d0                               ; address of foreground playfield
                    move.l     #PF2_PLANE_SZ,d1 
                    bsr        init_bplpointers                              ; initializes bitplane pointers for foreground playfield

                    move.w     map_ptr,d0
                    bsr        init_background
                    move.w     #TILE_WIDTH,bgnd_x                            ; x position of the part of background to draw

                    bsr        plship_init

mainloop: 
                    bsr        wait_vblank                                   ; waits for vertical blank
                    bsr        swap_buffers

                    bsr        scroll_background

                    bsr        plship_update

                    bsr        erase_bgnds
                    
                    bsr        plship_draw

                    btst       #6,CIAAPRA                                    ; left mouse button pressed?
                    bne.s      mainloop                                      ; if not, repeats the loop

                    bsr        release_system                                ; releases the hw control to the O.S.
                    rts


;************************************************************************
; SUBROUTINES
;************************************************************************

;************************************************************************
; Takes full control of Amiga hardware,
; disabling the O.S. in a controlled way.
;************************************************************************
take_system:
                    move.l     ExecBase,a6                                   ; base address of Exec
                    jsr        _LVOForbid(a6)                                ; disables O.S. multitasking
                    jsr        _LVODisable(a6)                               ; disables O.S. interrupts

                    lea        gfx_name,a1                                   ; OpenLibrary takes 1 parameter: library name in a1
                    jsr        _LVOOldOpenLibrary(a6)                        ; opens graphics.library
                    move.l     d0,gfx_base                                   ; saves base address of graphics.library in a variable
            
                    move.l     d0,a6                                         ; gfx base                   
                    move.l     $26(a6),sys_coplist                           ; saves system copperlist address
             
                    jsr        _LVOOwnBlitter(a6)                            ; takes the Blitter exclusive

                    lea        CUSTOM,a5                                     ; a5 will always contain CUSTOM chips base address $dff000
          
                    move.w     DMACONR(a5),old_dma                           ; saves state of DMA channels in a variable
                    move.w     #$7fff,DMACON(a5)                             ; disables all DMA channels
                    move.w     #DMASET,DMACON(a5)                            ; sets only dma channels that we will use

                    move.l     #copperlist,COP1LC(a5)                        ; sets our copperlist address into Copper
                    move.w     d0,COPJMP1(a5)                                ; reset Copper PC to the beginning of our copperlist       

                    move.w     #0,FMODE(a5)                                  ; sets 16 bit FMODE
                    move.w     #$c00,BPLCON3(a5)                             ; sets default value                       
                    move.w     #$11,BPLCON4(a5)                              ; sets default value

                    rts


;************************************************************************
; Releases the hardware control to the O.S.
;************************************************************************
release_system:
                    move.l     sys_coplist,COP1LC(a5)                        ; restores the system copperlist
                    move.w     d0,COPJMP1(a5)                                ; starts the system copperlist 

                    or.w       #$8000,old_dma                                ; sets bit 15
                    move.w     old_dma,DMACON(a5)                            ; restores saved DMA state

                    move.l     gfx_base,a6
                    jsr        _LVODisownBlitter(a6)                         ; release Blitter ownership
                    move.l     ExecBase,a6                                   ; base address of Exec
                    jsr        _LVOPermit(a6)                                ; enables O.S. multitasking
                    jsr        _LVOEnable(a6)                                ; enables O.S. interrupts
                    move.l     gfx_base,a1                                   ; base address of graphics.library in a1
                    jsr        _LVOCloseLibrary(a6)                          ; closes graphics.library
                    rts


;************************************************************************
; Initializes bitplane pointers
;
; parameters;
; a1   - address of bpl pointers in the copperlist
; d0.l - address of playfield
; d1.l - playfield plane size (in bytes)
;************************************************************************
init_bplpointers:
                    movem.l    d0-a6,-(sp)
              
                    move.l     #BPP-1,d7                                     ; number of iterations
.loop:
                    move.w     d0,6(a1)                                      ; copy low word of image address into BPLxPTL (low word of BPLxPT)
                    swap       d0                                            ; swap high and low word of image address
                    move.w     d0,2(a1)                                      ; copy high word of image address into BPLxPTH (high word of BPLxPT)
                    swap       d0                                            ; resets d0 to the initial condition
              ;add.l      #DISPLAY_PLANE_SZ,d0                                     ; point to the next bitplane
              ;add.l      #BGND_PLANE_SIZE,d0                                      ; point to the next bitplane
                    add.l      d1,d0                                         ; points to the next bitplane
                    add.l      #8,a1                                         ; poinst to next bplpointer
                    dbra       d7,.loop                                      ; repeats the loop for all planes
            
                    movem.l    (sp)+,d0-a6
                    rts 


;************************************************************************
; Wait for the blitter to finish
;************************************************************************
wait_blitter:
.loop:
                    btst.b     #6,DMACONR(a5)                                ; if bit 6 is 1, the blitter is busy
                    bne        .loop                                         ; and then wait until it's zero
                    rts 


;************************************************************************
; Waits for the electron beam to reach a given line.
;
; parameters:
; d2.l - line
;************************************************************************
wait_vline:
                    movem.l    d0-a6,-(sp)                                   ; saves registers into the stack

                    lsl.l      #8,d2
                    move.l     #$1ff00,d1
wait:
                    move.l     VPOSR(a5),d0
                    and.l      d1,d0
                    cmp.l      d2,d0
                    bne.s      wait

                    movem.l    (sp)+,d0-a6                                   ; restores registers from the stack
                    rts


;************************************************************************
; Waits for the vertical blank
;************************************************************************
wait_vblank:
                    movem.l    d0-a6,-(sp)                                   ; saves registers into the stack
                    move.l     #304,d2                                       ; line to wait: 304 236
                    bsr        wait_vline
                    movem.l    (sp)+,d0-a6                                   ; restores registers from the stack
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
                    movem.l    d0-a6,-(sp)                                   ; saves registers into the stack

; calculates the screen address where to draw the tile
                    mulu       #BGND_ROW_SIZE,d3                             ; y_offset = y * BGND_ROW_SIZE
                    lsr.w      #3,d2                                         ; x_offset = x / 8
                    ext.l      d2
                    add.l      d3,a1                                         ; sums offsets to a1
                    add.l      d2,a1

; calculates row and column of tile in tileset starting from index
                    ext.l      d0                                            ; extends d0 to a long because the destination operand if divu must be long
                    divu       #TILESET_COLS,d0                              ; tile_index / TILESET_COLS
                    swap       d0
                    move.w     d0,d1                                         ; the remainder indicates the tile column
                    swap       d0                                            ; the quotient indicates the tile row
         
; calculates the x,y coordinates of the tile in the tileset
                    lsl.w      #6,d0                                         ; y = row * 64
                    lsl.w      #6,d1                                         ; x = column * 64
         
; calculates the offset to add to a0 to get the address of the source image
                    mulu       #TILESET_ROW_SIZE,d0                          ; offset_y = y * TILESET_ROW_SIZE
                    lsr.w      #3,d1                                         ; offset_x = x / 8
                    ext.l      d1

                    lea        tileset,a0                                    ; source image address
                    add.l      d0,a0                                         ; add y_offset
                    add.l      d1,a0                                         ; add x_offset

                    moveq      #N_PLANES-1,d7
         
                    bsr        wait_blitter
                    move.w     #$ffff,BLTAFWM(a5)                            ; don't use mask
                    move.w     #$ffff,BLTALWM(a5)
                    move.w     #$09f0,BLTCON0(a5)                            ; enable channels A,D
                                                                                  ; logical function = $f0, D = A
                    move.w     #0,BLTCON1(a5)
                    move.w     #(TILESET_WIDTH-TILE_WIDTH)/8,BLTAMOD(a5)     ; A channel modulus
                    move.w     #(BGND_WIDTH-TILE_WIDTH)/8,BLTDMOD(a5)        ; D channel modulus
.loop:
                    bsr        wait_blitter
                    move.l     a0,BLTAPT(a5)                                 ; source address
                    move.l     a1,BLTDPT(a5)                                 ; destination address
                    move.w     #64*64+4,BLTSIZE(a5)                          ; blit size: 64 rows for 4 word
                    add.l      #TILESET_PLANE_SZ,a0                          ; advances to the next plane
                    add.l      #BGND_PLANE_SIZE,a1
                    dbra       d7,.loop
                    bsr        wait_blitter

                    movem.l    (sp)+,d0-a6                                   ; restore registers from the stack
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
                    lsl.w      #1,d0                                         ; offset_x = map_column * 2
                    ext.l      d0
                    add.l      d0,a0
         
                    moveq      #3-1,d7                                       ; number or tilemap rows - 1
                    move.w     #0,d3                                         ; y position
.loop:
                    move.w     (a0),d0                                       ; tile index
                    bsr        draw_tile
                    add.w      #TILE_HEIGHT,d3                               ; increment y position
                    add.l      #TILEMAP_ROW_SIZE,a0                          ; move to the next row of the tilemap
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
                    moveq      #5-1,d7                                       ; number of tile columns - 1 to draw
                    lea        playfield1,a1                                 ; address where draw the tile
                    move.w     #TILE_WIDTH,d2                                ; position x
.loop               bsr        draw_tile_column
                    add.w      #1,d0                                         ; increment map column
                    add.w      #1,map_ptr
                    add.w      #TILE_WIDTH,d2                                ; increase position x
                    dbra       d7,.loop

                    sub.w      #1,map_ptr
; ; draws the column to the left of the display window
;               add.w      #1,d0                                        ; map column
;               add.w      #1,map_ptr
;               move.w     #0,d2                                        ; x position
;               lea        playfield1,a1
;               bsr        draw_tile_column

; ; draws the column to the right of the display window
;               move.w     #DISPLAY_WIDTH+TILE_WIDTH,d2                 ; x position
;               lea        playfield1,a1
;               bsr        draw_tile_column

                    movem.l    (sp)+,d0-a6
                    rts


;************************************************************************
; Scrolls the background to the left.
;************************************************************************
scroll_background:
                    movem.l    d0-a6,-(sp)

                    move.w     bgnd_x,d0                                     ; x position of the part of background to draw
                    tst.w      d0
                    beq        .set_scroll
                    ext.l      d0                                            ; every 64 pixels draws a new column
                    divu       #TILE_WIDTH,d0
                    swap       d0
                    tst.w      d0                                            ; remainder of bgnd_x/TILE_WIDTH is zero?
                    beq        .draw_new_column                              ; if yes, draws new tile columns at the sides of viewport
                    bra        .set_scroll
.draw_new_column:
                    add.w      #1,map_ptr
                    cmp.w      #TILEMAP_WIDTH,map_ptr                        ; end of map?
                    bge        .return

                    move.w     map_ptr,d0                                    ; map column
                    move.w     bgnd_x,d2                                     ; x position = bgnd_x - TILE_WIDTH
                    sub.w      #TILE_WIDTH,d2
                    lea        playfield1,a1
                    bsr        draw_tile_column                              ; draws the column to the left of the viewport

                    move.w     bgnd_x,d2                                     ; x position = bgnd_x + VIEWPORT_WIDTH
                    add.w      #VIEWPORT_WIDTH,d2 
                    lea        playfield1,a1
                    bsr        draw_tile_column                              ; draws the column to the right of the viewport
              
.set_scroll:
                    move.w     bgnd_x,d0
                    and.w      #$000f,d0                                     ; selects the first 4 bits, which correspond to the shift
                    move.w     #$f,d1                                        ; since we want a left scroll, 
                    sub.w      d0,d1                                         ; we need to decrement the value of scroll, i.e. $f-scroll
                    move.w     d1,scrollx                                    ; sets the BPLCON1 value for scrolling

                    tst.w      d1                                            ; scroll = 0?
                    beq        .update_bplptr                                ; yes, update bitplane pointers
                    bra        .check_bgnd_end
.update_bplptr:
                    move.w     bgnd_x,d1 
                    asr.w      #3,d1                                         ; offset_x = bgnd_x/8
                    and.w      #$fffe,d1                                     ; rounds to even addresses
                    ext.l      d1                                            ; extends to long
                    lea        bplpointers1,a1
                    move.l     #playfield1,d0
                    add.l      d1,d0                                         ; adds offset_x
                    move.l     #BGND_PLANE_SIZE,d1
                    bsr        init_bplpointers
                    move.w     #$000f,scrollx                                ; resets scroll value

.check_bgnd_end:
                    cmp.w      #TILE_WIDTH+VIEWPORT_WIDTH,bgnd_x             ; end of background surface?
                    ble        .incr_x
                    move.w     #0,bgnd_x                                     ; resets x position of the part of background to draw
                    lea        bplpointers1,a1
                    move.l     #playfield1-2,d0
                    move.l     #BGND_PLANE_SIZE,d1
                    bsr        init_bplpointers
                    move.w     #$000f,scrollx                                ; resets scroll value
                    bra        .return
.incr_x:       
                    add.w      #1,bgnd_x                                     ; increases x position of the part of background to draw

.return             movem.l    (sp)+,d0-a6
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
                    mulu.w     #PF2_ROW_SIZE,d1                              ; offset_y = y * PF2_ROW_SIZE
                    add.l      d1,a2                                         ; adds offset_y to destination address
                    move.w     bob.x(a3),d0
                    lsr.w      #3,d0                                         ; offset_x = x/8
                    and.w      #$fffe,d0                                     ; makes offset_x even
                    add.w      d0,a2                                         ; adds offset_x to destination address
    
    ; saves background information to be cleared in a list
                    cmp.w      #BGND_LIST_MAX_ITEMS-1,bgnd_list_counter      ; if the list is full
                    beq        .skip_save_bgnd                               ; skips saving background
                    move.l     bgnd_list_ptr,a0                              ; locates the first free element in the background list
                    move.w     bgnd_list_counter,d0
                    mulu.w     #bob_bgnd.length,d0
                    add.l      d0,a0
                    move.l     a2,bob_bgnd.addr(a0)                          ; saves background address in list
                    move.w     bob.width(a3),bob_bgnd.width(a0)              ; saves width
                    move.w     bob.height(a3),bob_bgnd.height(a0)            ; saves height
                    add.w      #1,bgnd_list_counter
.skip_save_bgnd:         
    ; calculates source address (channels A,B)
                    move.l     bob.imgdata(a3),a0
                    move.l     bob.mask(a3),a1
                    move.w     bob.width(a3),d1             
                    lsr.w      #3,d1                                         ; bob width in bytes (bob_width/8)
                    move.w     bob.ssheet_c(a3),d4
                    mulu       d1,d4                                         ; offset_x = column * (bob_width/8)
                    add.w      d4,a0                                         ; adds offset_x to the base address of bob's image
                    add.w      d4,a1                                         ; and bob's mask
                    move.w     bob.height(a3),d3
                    move.w     bob.ssheet_r(a3),d5
                    mulu       d3,d5                                         ; bob_height * row
                    move.w     bob.ssheet_w(a3),d1
                    asr.w      #3,d1                                         ; spritesheet_row_size = spritesheet_width / 8
                    mulu       d1,d5                                         ; offset_y = row * bob_height * spritesheet_row_size
                    add.w      d5,a0                                         ; adds offset_y to the base address of bob's image
                    add.w      d5,a1                                         ; and bob's mask

    ; calculates the modulus of channels A,B
                    move.w     bob.ssheet_w(a3),d1                           ; copies spritesheet_width in d1
                    move.w     bob.width(a3),d2
                    sub.w      d2,d1                                         ; spritesheet_width - bob_width
                    sub.w      #16,d1                                        ; spritesheet_width - bob_width -16
                    asr.w      #3,d1                                         ; (spritesheet_width - bob_width -16)/8

    ; calculates the modulus of channels C,D
                    move.w     bob.width(a3),d2
                    lsr        #3,d2                                         ; bob_width/8
                    add.w      #2,d2                                         ; adds 2 to the sprite width in bytes, due to the shift
                    move.w     #PF2_ROW_SIZE,d4                              ; screen width in bytes
                    sub.w      d2,d4                                         ; modulus (d4) = screen_width - bob_width
    
    ; calculates the shift value for channels A,B (d6) and value of BLTCON0 (d5)
                    move.w     bob.x(a3),d6
                    and.w      #$000f,d6                                     ; selects the first 4 bits of x
                    lsl.w      #8,d6                                         ; moves the shift value to the upper nibble
                    lsl.w      #4,d6                                         ; so as to have the value to insert in BLTCON1
                    move.w     d6,d5                                         ; copy to calculate the value to insert in BLTCON0
                    or.w       #$0fca,d5                                     ; value to insert in BLTCON0
                                                       ; logic function LF = $ca

    ; calculates the blit size (d3)
                    move.w     bob.height(a3),d3
                    lsl.w      #6,d3                                         ; bob_height<<6
                    lsr.w      #1,d2                                         ; bob_width/2 (in word)
                    or         d2,d3                                         ; combines the dimensions into the value to be inserted into BLTSIZE

    ; calculates the size of a BOB spritesheet bitplane
                    move.w     bob.ssheet_w(a3),d2                           ; copies spritesheet_width in d2
                    lsr.w      #3,d2                                         ; spritesheet_width/8
                    and.w      #$fffe,d2                                     ; makes even
                    move.w     bob.ssheet_h(a3),d0                           ; spritesheet_height
                    mulu       d0,d2                                         ; multiplies by the height

    ; initializes the registers that remain constant
                    bsr        wait_blitter
                    move.w     #$ffff,BLTAFWM(a5)                            ; first word of channel A: no mask
                    move.w     #$0000,BLTALWM(a5)                            ; last word of channel A: reset all bits
                    move.w     d6,BLTCON1(a5)                                ; shift value for channel A
                    move.w     d5,BLTCON0(a5)                                ; activates all 4 channels,logic_function=$CA,shift
                    move.w     d1,BLTAMOD(a5)                                ; modules for channels A,B
                    move.w     d1,BLTBMOD(a5)
                    move.w     d4,BLTCMOD(a5)                                ; modules for channels C,D
                    move.w     d4,BLTDMOD(a5)
                    moveq      #N_PLANES-1,d7                                ; number of cycle repetitions

    ; copy cycle for each bitplane
.plane_loop:
                    bsr        wait_blitter
                    move.l     a1,BLTAPT(a5)                                 ; channel A: Bob's mask
                    move.l     a0,BLTBPT(a5)                                 ; channel B: Bob's image
                    move.l     a2,BLTCPT(a5)                                 ; channel C: draw buffer
                    move.l     a2,BLTDPT(a5)                                 ; channel D: draw buffer
                    move.w     d3,BLTSIZE(a5)                                ; blit size and starts blit operation

                    add.l      d2,a0                                         ; points to the next bitplane
                    add.l      #PF2_PLANE_SZ,a2                                         
                    dbra       d7,.plane_loop                                ; repeats the cycle for each bitplane

                    movem.l    (sp)+,d0-a6
                    rts


;***************************************************************************
; Erases the background of a bob.
;
; parameters:
; a1 - bob_bgnd instance
;***************************************************************************
erase_bob_bgnd:
                    movem.l    d0-a6,-(sp)

; calculates channel D module (d4)
                    move.w     bob_bgnd.width(a1),d2
                    lsr.w      #3,d2                                         ; width/8
                    and.w      #$fffe,d2                                     ; makes it even
                    addq.w     #2,d2                                         ; blit 1 word wider due to shift
                    move.w     #PF2_ROW_SIZE,d4                              ; playfield2 width in bytes
                    sub.w      d2,d4                                         ; modulus = pf2 width - bob width

; calculates blit size (d3)
                    move.w     bob_bgnd.height(a1),d3
                    lsl.w      #6,d3                                         ; height * 64
                    lsr.w      #1,d2                                         ; width in word
                    or.w       d2,d3                                         ; puts the dimensions together

; initializes the registers that remain constant during the loop
                    bsr        wait_blitter
                    move.w     #$0000,BLTCON1(a5)
                    move.w     #$0100,BLTCON0(a5)                            ; resets the destination             
                    move.w     d4,BLTDMOD(a5)
                    move.l     bob_bgnd.addr(a1),a0
                    moveq      #BPP-1,d7                                     ; number of loop iterations
.plane_loop:
                    bsr        wait_blitter
                    move.l     a0,BLTDPT(a5)                                 ; channel D: background address to delete
                    move.w     d3,BLTSIZE(a5)                                ; sets the size and starts the blitter
                    add.l      #PF2_PLANE_SZ,a0                              ; points to the next plane
                    dbra       d7,.plane_loop                                ; repeats the loop for each plane

                    movem.l    (sp)+,d0-a6
                    rts


;***************************************************************************
; Clears backgrounds of bobs using a list.
;***************************************************************************
erase_bgnds:
                    movem.l    d0-a6,-(sp)

                    move.w     bgnd_list_counter,d7                          ; number of loop iterations
                    tst.w      d7                                            ; if the list is empty, returns immediately
                    beq        .return
                    sub.w      #1,d7
                    move.l     bgnd_list_ptr,a1                              ; points to the backgrounds list
.loop:
                    bsr        erase_bob_bgnd
                    add.l      #bob_bgnd.length,a1                           ; points to the next item in the list
                    dbra       d7,.loop

                    clr.w      bgnd_list_counter

.return:
                    movem.l    (sp)+,d0-a6
                    rts


;****************************************************************
; Initializes the player's ship state
;****************************************************************
plship_init:
                    movem.l    d0-a6,-(sp)

                    lea        player_ship,a0
                    move.w     #PLSHIP_X0,bob.x(a0)
                    move.w     #PLSHIP_Y0,bob.y(a0)
                    clr.w      bob.ssheet_c(a0)
                    move.w     ship.anim_duration(a0),ship.anim_timer(a0)

                    lea        player_ship_engine,a1
                    move.w     #PLSHIP_X0-17,bob.x(a1)
                    move.w     #PLSHIP_Y0+9,bob.y(a1)
                    clr.w      bob.ssheet_c(a1)
                    move.w     ship.anim_duration(a1),ship.anim_timer(a1)
                  
.return:
                    movem.l    (sp)+,d0-a6
                    rts


;****************************************************************
; Draws the player's ship.
;****************************************************************
plship_draw:
                    movem.l    d0-a6,-(sp)

                    lea        player_ship,a3
                    move.l     draw_buffer,a2
                    bsr        draw_bob                                      ; draws ship

                    lea        player_ship_engine,a3
                    move.l     draw_buffer,a2
                    bsr        draw_bob                                      ; draws engine fire                   
                  
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
                    btst.l     #1,d0                                         ; joy right?
                    bne        .set_right
                    btst.l     #9,d0                                         ; joy left?
                    bne        .set_left
                    bra        .check_up
.set_right:
                    add.w      d2,bob.x(a0)                                  ; ship.x += ship.speed 
                    bra        .check_up
.set_left:
                    sub.w      d2,bob.x(a0)                                  ; ship.x -= ship.speed
.check_up:
                    move.w     d0,d1
                    lsr.w      #1,d1
                    eor.w      d1,d0
                    btst.l     #8,d0                                         ; joy up?
                    bne        .set_up
                    btst.l     #0,d0                                         ; joy down?
                    bne        .set_down
                    bra        .return
.set_up:
                    sub.w      d2,bob.y(a0)                                  ; ship.y-= ship.speed
                    bra        .return
.set_down:
                    add.w      d2,bob.y(a0)                                  ; ship.y+= ship.speed

.return:
                    movem.l    (sp)+,d0-a6
                    rts


;****************************************************************
; Updates the player's ship state
;****************************************************************
plship_update:
                    movem.l    d0-a6,-(sp)

                    lea        player_ship,a0
                    bsr        plship_move_with_joystick
                    bsr        plship_limit_movement

; sets engine fire bob position
                    lea        player_ship_engine,a1
                    move.w     bob.x(a0),d0
                    sub.w      #17,d0
                    move.w     d0,bob.x(a1)                                  ; engine.x = ship.x - 17
                    move.w     bob.y(a0),d0
                    add.w      #9,d0
                    move.w     d0,bob.y(a1)                                  ; engine.y = ship.y + 9

; animates engine fire
                    sub.w      #1,ship.anim_timer(a1)
                    tst.w      ship.anim_timer(a1)                           ; anim_timer = 0?
                    beq        .incr_frame
                    bra        .return
.incr_frame:
                    add.w      #1,bob.ssheet_c(a1)                           ; increases animation frame
                    cmp.w      #4,bob.ssheet_c(a1)                           ; ssheet_c >= 4?
                    bge        .reset_frame
                    bra        .reset_timer
.reset_frame:
                    clr.w      bob.ssheet_c(a1)                              ; resets animation frame
.reset_timer:
                    move.w     ship.anim_duration(a1),ship.anim_timer(a1)    ; resets anim_timer
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
                    cmp.w      #PLSHIP_XMIN,d0                               ; x < PLSHIP_XMIN?
                    blt        .limit_xmin
                    bra        .check_xmax
.limit_xmin:
                    move.w     #PLSHIP_XMIN,bob.x(a0)                        ; x = PLSHIP_XMIN
                    bra        .check_ymin
.check_xmax:
                    cmp.w      #PLSHIP_XMAX,d0                               ; x > PLSHIP_XMAX?
                    bgt        .limit_xmax
                    bra        .check_ymin
.limit_xmax:
                    move.w     #PLSHIP_XMAX,bob.x(a0)                        ; x = PLSHIP_XMAX
.check_ymin:
                    move.w     bob.y(a0),d0
                    cmp.w      #PLSHIP_YMIN,d0                               ; y < PLSHIP_YMIN?
                    blt        .limit_ymin
                    bra        .check_ymax
.limit_ymin:
                    move.w     #PLSHIP_YMIN,bob.y(a0)                        ; y = PLSHIP_YMIN
                    bra        .return
.check_ymax:
                    cmp.w      #PLSHIP_YMAX,d0                               ; y > PLSHIP_YMAX?
                    bgt        .limit_ymax
                    bra        .return
.limit_ymax:
                    move.w     #PLSHIP_YMAX,bob.y(a0)                        ; y = PLSHIP_YMAX
.return:
                    movem.l    (sp)+,d0-a6
                    rts


;************************************************************************
; Swaps video buffers, causing draw_buffer to be displayed.
;************************************************************************
swap_buffers:
                    movem.l    d0-a6,-(sp)                                   ; saves registers into the stack

                    move.l     draw_buffer,d0                                ; swaps the values ​​of draw_buffer and view_buffer
                    move.l     view_buffer,draw_buffer
                    move.l     d0,view_buffer
                    ;add.l      #CLIP_WIDTH/8,d0
                    lea        bplpointers2,a1                               ; sets the bitplane pointers to the view_buffer 
                    moveq      #BPP-1,d1                                            
.loop:
                    move.w     d0,6(a1)                                      ; copies low word
                    swap       d0                                            ; swaps low and high word of d0
                    move.w     d0,2(a1)                                      ; copies high word
                    swap       d0                                            ; resets d0 to the initial condition
                    add.l      #PF2_PLANE_SZ,d0                              ; points to the next bitplane
                    add.l      #8,a1                                         ; points to next bplpointer
                    dbra       d1,.loop                                      ; repeats the loop for all planes

                    move.l     bgnd_list_ptr,d0                              ; swaps pointers to the list of bob backgrounds to delete
                    move.l     bgnd_list_ptr2,bgnd_list_ptr
                    move.l     d0,bgnd_list_ptr2
                    move.w     bgnd_list_counter,d0                          ; swaps backgrounds list counters
                    move.w     bgnd_list_counter2,bgnd_list_counter
                    move.w     d0,bgnd_list_counter2

                    movem.l    (sp)+,d0-a6                                   ; restores registers from the stack
                    rts


;************************************************************************
; VARIABLES
;************************************************************************
gfx_name            dc.b       "graphics.library",0,0                        ; string containing the name of graphics.library
gfx_base            dc.l       0                                             ; base address of graphics.library
old_dma             dc.w       0                                             ; saved state of DMACON
sys_coplist         dc.l       0                                             ; address of system copperlist                                     

map_ptr             dc.w       0                                             ; current map column
bgnd_x              dc.w       0                                             ; current x coordinate of camera into background surface
map                 include    "gfx/shooter_map.i"

view_buffer         dc.l       playfield2a                                   ; buffer displayed on screen
draw_buffer         dc.l       playfield2b                                   ; drawing buffer (not visible)

bgnd_list_ptr       dc.l       bgnd_list1                                    ; points to the list of bob backgrounds to delete
bgnd_list_ptr2      dc.l       bgnd_list2                                    ; two pointers to swap in swap_buffers due to double buffering

bgnd_list_counter   dc.w       0                                             ; number of items in the backgrounds list
bgnd_list_counter2  dc.w       0                                             ; doubled for double buffering

player_ship         dc.w       0                                             ; bob.x
                    dc.w       0                                             ; bob.y
                    dc.w       1                                             ; bob.speed
                    dc.w       64                                            ; bob.width
                    dc.w       28                                            ; bob.height  
                    dc.w       0                                             ; bob.ssheet_c
                    dc.w       0                                             ; bob.ssheet_r
                    dc.w       64                                            ; bob.ssheet_w
                    dc.w       28                                            ; bob.ssheet_h
                    dc.l       player_ship_gfx                               ; bob.imgdata
                    dc.l       player_ship_mask                              ; bob.mask
                    dc.w       0                                             ; ship.anim_duration 
                    dc.w       0                                             ; ship.anim_timer


player_ship_engine  dc.w       0                                             ; x position
                    dc.w       0                                             ; y position
                    dc.w       1                                             ; speed
                    dc.w       32                                            ; width
                    dc.w       16                                            ; height  
                    dc.w       0                                             ; spritesheet column of the bob
                    dc.w       0                                             ; spritesheet row of the bob
                    dc.w       128                                           ; spritesheet width in pixels
                    dc.w       16                                            ; spritesheet height in pixels
                    dc.l       ship_engine_gfx                               ; image data address
                    dc.l       ship_engine_mask                              ; mask address
                    dc.w       5                                             ; ship.anim_duration
                    dc.w       5                                             ; ship.anim_timer


;************************************************************************
; Graphics data
;************************************************************************

; segment loaded in CHIP RAM
                    SECTION    graphics_data,DATA_C

copperlist:
                    dc.w       DIWSTRT,$2c81                                 ; display window start at ($81,$2c)
                    dc.w       DIWSTOP,$2cc1                                 ; display window stop at ($1c1,$12c)
                    dc.w       DDFSTRT,$28                                   ; display data fetch start at $28 to hide scrolling artifacts
                    dc.w       DDFSTOP,$d0                                   ; display data fetch stop at $d0
                    dc.w       BPLCON1
scrollx             dc.w       $000f                                         ; bits 0-3 scroll value of pf1

;                                       5432109876543210
                    dc.w       BPLCON2,%0000000001000000                     ; priority to pf2

                    dc.w       BPL1MOD,PF1_MOD-4                             ; -4 because we fetch 32 more pixels                                          
                    dc.w       BPL2MOD,PF2_MOD-4
            

  ; BPLCON0 ($100)
  ; bit 0: set to 1 to enable BLTCON3 register
  ; bit 4: most significant bit of bitplane number
  ; bit 9: set to 1 to enable composite video output
  ; bit 10: set to 1 to enable dual playfield mode
  ; bit 12-14: least significant bits of bitplane number
  ;                                     5432109876543210
                    dc.w       BPLCON0,%0000011000010000
                    dc.w       FMODE,0                                       ; 16 bit fetch mode

bplpointers1:
                    dc.w       $e0,0,$e2,0                                   ; plane 1
                    dc.w       $e8,0,$ea,0                                   ; plane 3
                    dc.w       $f0,0,$f2,0                                   ; plane 5
                    dc.w       $f8,0,$fa,0                                   ; plane 7

bplpointers2:
                    dc.w       $e4,0,$e6,0                                   ; plane 2
                    dc.w       $ec,0,$ee,0                                   ; plane 4
                    dc.w       $f4,0,$f6,0                                   ; plane 6
                    dc.w       $fc,0,$fe,0                                   ; plane 8

;                                       5432109876543210
                    dc.w       BPLCON3,%0001000000000000                     ; offset 16 tra le palette dei due playfield

pf1_palette:
                    incbin     "gfx/shooter_tiles_16.pal"                    ; background palette

pf2_palette:
                    incbin     "gfx/pf2_palette.pal"                         ; foreground palette

                    dc.w       $ffff,$fffe                                   ; end of copperlist

         
tileset             incbin     "gfx/shooter_tiles_16.raw"                    ; image 640 x 512 pixel , 8 bitplanes

player_ship_gfx     incbin     "gfx/ship.raw"
player_ship_mask    incbin     "gfx/ship.mask"

ship_engine_gfx     incbin     "gfx/ship_engine.raw"
ship_engine_mask    incbin     "gfx/ship_engine.mask"

;************************************************************************
; BSS DATA
;************************************************************************

                    SECTION    bss_data,BSS_C

playfield1          ds.b       (PF1_PLANE_SZ*BPP)                            ; used for scrolling background

playfield2a         ds.b       (PF2_PLANE_SZ*BPP)                            ; used to draw BOBs using double buffering
playfield2b         ds.b       (PF2_PLANE_SZ*BPP)

bgnd_list1          ds.b       (bob_bgnd.length*BGND_LIST_MAX_ITEMS)         ; list containing the backgrounds of the bobs to be deleted
bgnd_list2          ds.b       (bob_bgnd.length*BGND_LIST_MAX_ITEMS)         ; we have two lists due to double buffering

                    END