;****************************************************************
; Assets management
;
; (c) 2024 Stefano Coppi
;****************************************************************
 
        include    "assets.i"

        xdef       load_assets

        xref       release_system
        xref       init_file
        xref       load_file
        xref       quit_file
        xref       take_system
        xref       init_keyboard
        xref       init_sound
        xref       hud_bar_gfx
        xref       hud_bar_gfx_mask
        xref       hud_bgnd
        xref       player_ship_gfx
        xref       player_ship_mask


;****************************************************************
; CONSTANTS
;****************************************************************
NUM_ASSETS equ 4


;****************************************************************
; VARIABLES
;****************************************************************
        SECTION    code_section,CODE

assets_array:
asset1  dc.b       "gfx/bar.raw",0
        dcb.b      24-12,0
        dc.l       hud_bar_gfx
        dc.w       4400
asset2  dc.b       "gfx/bar.mask",0
        dcb.b      24-13,0
        dc.l       hud_bar_gfx_mask
        dc.w       880
asset3  dc.b       "gfx/ship.raw",0
        dcb.b      24-13,0
        dc.l       player_ship_gfx
        dc.w       896
asset4  dc.b       "gfx/ship.mask",0
        dcb.b      24-14,0
        dc.l       player_ship_mask
        dc.w       224




;****************************************************************
; SUBROUTINES
;****************************************************************
              


;****************************************************************
;  Load assets
;****************************************************************
load_assets:
        movem.l    d0-a6,-(sp)

        jsr        release_system               ; releases the system to Amiga O.S.
        jsr        init_file                    ; initializes file module
              
        move.l     #NUM_ASSETS-1,d7
        lea        assets_array,a0
.loop:
        move.l     a0,d1
        move.l     asset.dest_address(a0),d2
        move.w     asset.length(a0),d3
        jsr        load_file                    ; loads asset from file
        add.l      #asset.size,a0               ; points to next element
        dbra       d7,.loop
              
        jsr        quit_file                    ; quits file module
        jsr        take_system                  ; takes control of hardware
        jsr        init_keyboard                ; initializes keyboard IRQ
        jsr        init_sound                   ; initializes sound IRQ

        movem.l    (sp)+,d0-a6
        rts

