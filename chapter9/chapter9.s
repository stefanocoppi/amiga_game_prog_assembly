;************************************************************************
; Amiga Assembly Game Programming Book
; 
; Chapter 9 - Tiles and tilemaps
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
Disable          equ -$78
Forbid           equ -132
Enable           equ -$7e
Permit           equ -138
OpenLibrary      equ -$198
CloseLibrary     equ -$19e
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
TILEMAP_ROW_SIZE equ 100*2


             SECTION    code_section,CODE

;************************************************************************
; MAIN PROGRAM
;************************************************************************
main:
             nop
             nop
             bsr        take_system                                  ; takes the control of Amiga's hardware
             move.l     #screen,d0                                   ; address of screen in d0
             bsr        init_bplpointers                             ; initializes bitplane pointers to our image

            ;  lea        screen,a1                                    ; address where draw the tile
            ;  move.w     #0,d2                                        ; x position
            ;  move.w     #256-64,d3                                   ; y position
            ;  move.w     #2,d0                                        ; tile index
            ;  bsr        draw_tile
            ;  move.w     #64,d2                                       ; x position
            ;  move.w     #256-64,d3                                   ; y position
            ;  move.w     #3,d0                                        ; tile index
            ;  bsr        draw_tile

            ;  lea        screen,a1                                    ; address where draw the tile
            ;  move.w     #11,d0                                       ; map column to draw
            ;  move.w     #0,d2                                        ; x position (multiple of 16)
            ;  bsr        draw_tile_column

             lea        screen,a1                                    ; address where draw the tile
             move.w     #11,d0                                       ; map column to start drawing from
             bsr        fill_screen_with_tiles
mainloop: 
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
; parameters:
; d0.l - address of bitplanes
;************************************************************************
init_bplpointers:
             movem.l    d0-a6,-(sp)
                   
             lea        bplpointers,a1                               ; bitplane pointers in a1
             move.l     #(N_PLANES-1),d1                             ; number of loop iterations in d1
.loop:
             move.w     d0,6(a1)                                     ; copy low word of image address into BPLxPTL (low word of BPLxPT)
             swap       d0                                           ; swap high and low word of image address
             move.w     d0,2(a1)                                     ; copy high word of image address into BPLxPTH (high word of BPLxPT)
             swap       d0                                           ; resets d0 to the initial condition
             add.l      #DISPLAY_PLANE_SZ,d0                         ; point to the next bitplane
             add.l      #8,a1                                        ; point to next bplpointer
             dbra       d1,.loop                                     ; repeats the loop for all planes
            
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
             mulu       #DISPLAY_ROW_SIZE,d3                         ; y_offset = y * DISPLAY_ROW_SIZE
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
             move.w     #(DISPLAY_WIDTH-TILE_WIDTH)/8,BLTDMOD(a5)    ; D channel modulus
.loop:
             bsr        wait_blitter
             move.l     a0,BLTAPT(a5)                                ; source address
             move.l     a1,BLTDPT(a5)                                ; destination address
             move.w     #64*64+4,BLTSIZE(a5)                         ; blit size: 64 rows for 4 word
             add.l      #TILESET_PLANE_SZ,a0                         ; advances to the next plane
             add.l      #DISPLAY_PLANE_SZ,a1
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
; Fills the screen with tiles.
;
; parameters:
; d0.w - map column from which to start drawing tiles
; a1   - address where draw the tile
;************************************************************************
fill_screen_with_tiles:
             movem.l    d0-a6,-(sp)

             moveq      #5-1,d7                                      ; number of tile columns - 1 to draw
             move.w     #0,d2                                        ; position x
.loop        bsr        draw_tile_column
             add.w      #1,d0                                        ; increments map column
             add.w      #64,d2                                       ; increases position x
             dbra       d7,.loop

             movem.l    (sp)+,d0-a6
             rts


;************************************************************************
; VARIABLES
;************************************************************************
gfx_name     dc.b       "graphics.library",0,0                       ; string containing the name of graphics.library
gfx_base     dc.l       0                                            ; base address of graphics.library
old_dma      dc.w       0                                            ; saved state of DMACON
sys_coplist  dc.l       0                                            ; address of system copperlist                                     

map          include    "gfx/shooter_map.i"

;************************************************************************
; Graphics data
;************************************************************************

; segment loaded in CHIP RAM
             SECTION    graphics_data,DATA_C

copperlist:
             dc.w       DIWSTRT,$2c81                                ; display window start at ($81,$2c)
             dc.w       DIWSTOP,$2cc1                                ; display window stop at ($1c1,$12c)
             dc.w       DDFSTRT,$38                                  ; display data fetch start at $38
             dc.w       DDFSTOP,$d0                                  ; display data fetch stop at $d0
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
  ;                              5432109876543210
             dc.w       BPLCON0,%0000001000010001
             dc.w       FMODE,0                                      ; 16 bit fetch mode

bplpointers:
             dc.w       $e0,0,$e2,0                                  ; plane 1
             dc.w       $e4,0,$e6,0                                  ; plane 2
             dc.w       $e8,0,$ea,0                                  ; plane 3
             dc.w       $ec,0,$ee,0                                  ; plane 4
             dc.w       $f0,0,$f2,0                                  ; plane 5
             dc.w       $f4,0,$f6,0                                  ; plane 6
             dc.w       $f8,0,$fa,0                                  ; plane 7
             dc.w       $fc,0,$fe,0                                  ; plane 8

palette      incbin     "gfx/shooter_tiles.pal"                      ; palette

             dc.w       $ffff,$fffe                                  ; end of copperlist

         
tileset      incbin     "gfx/shooter_tiles.raw"                      ; image 640 x 512 pixel , 8 bitplanes


;************************************************************************
; BSS DATA
;************************************************************************

             SECTION    bss_data,BSS_C

screen       ds.b       (DISPLAY_PLANE_SZ*N_PLANES)                  ; visible screen

             END