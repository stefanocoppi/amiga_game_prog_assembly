;****************************************************************
; Title screen state
;
; (c) 2024 Stefano Coppi
;****************************************************************

                       incdir     "include"
                       include    "hw.i"
                       include    "game_state.i"
                       include    "sound.i"

                       xdef       init_titlescreen_state
                       xdef       update_titlescreen_state

                       xref       coplist_title
                       xref       bplpointers_title
                       xref       init_bplpointers
                       xref       game_state
                       xref       title_palette
                       xref       change_gamestate
                       xref       play_sfx
                       xref       title_music
                       xref       play_pt_module
                       xref       mouse_lbtn
                       xref       load_assets
    

;****************************************************************
; CONSTANTS
;****************************************************************
TITLE_BPP       equ 5
TITLE_WIDTH     equ 320
TITLE_HEIGHT    equ 256
TITLE_ROW_SIZE  equ TITLE_WIDTH/8
TITLE_PLANE_SZ  equ TITLE_HEIGHT*TITLE_ROW_SIZE
TITLE_FLASH_DUR equ 50/5                                                ; 5 fps


;****************************************************************
; GRAPHICS DATA in chip ram
;****************************************************************
                       SECTION    graphics_data,DATA_C
title_static_gfx       incbin     "gfx/title_screen.raw"



;****************************************************************
; VARIABLES
;****************************************************************
                       SECTION    code_section,CODE

title_flash_timer      dc.w       0
title_flash_colors     dc.w       $0ee1
                       dc.w       $0112
title_flash_color_idx  dc.w       0


;****************************************************************
; SUBROUTINES
;****************************************************************


;****************************************************************
; Initializes the TITLE_SCREEN game state.
;****************************************************************
init_titlescreen_state:
                       movem.l    d0-a6,-(sp)

; sets up the copperlist for title screen
                       move.l     #coplist_title,COP1LC(a5)
                       move.w     d0,COPJMP1(a5)

; sets bitplane pointers to title_static_gfx image
                       move.l     #TITLE_BPP,d7  
                       lea        bplpointers_title,a1
                       move.l     #title_static_gfx,d0
                       move.l     #TITLE_PLANE_SZ,d1 
                       jsr        init_bplpointers

; initializes timer for flashing of "press fire to start" text
                       move.w     #TITLE_FLASH_DUR,title_flash_timer
                       clr.w      title_flash_color_idx
             
; changes the game state to TITLESCREEN
                       move.w     #GAME_STATE_TITLESCREEN,game_state

; loads assets from file
                       jsr        load_assets
                    
; plays pro-tracker music
                    ;    lea        title_music,a0
                    ;    jsr        play_pt_module

                       movem.l    (sp)+,d0-a6
                       rts


;****************************************************************
; Updates the TITLE_SCREEN game state.
;****************************************************************
update_titlescreen_state:
                       movem.l    d0-a6,-(sp)

                       bsr        animate_press_fire_text

                       cmp.w      #1,mouse_lbtn                         ; left mouse button pressed?
                       beq        .change_state

 ; fire button of joystick #1 pressed?
                       btst       #7,CIAAPRA                                    
                       beq        .change_state
                       bra        .return

.change_state:
; plays sound fx
                       move.w     #SFX_ID_START,d0
                       clr.w      d1                                    ; no loop
                       ;jsr        play_sfx
                       jsr        play_sample

; changes state to PLAYING
                       move.w     #GAME_STATE_PLAYING,d0
                       jsr        change_gamestate

.return:
                       movem.l    (sp)+,d0-a6
                       rts


;****************************************************************
; Animates the "press fire..." text using color cycle.
;****************************************************************
animate_press_fire_text:
                       movem.l    d0-a6,-(sp)

; flashing of "press fire..." text
; this animation is color based:
; every time the timer reaches 0, the color of the text is changed
; the color is switched from an array of two colors

; decrements flash timer
                       sub.w      #1,title_flash_timer
; if timer = 0, jumps to change_color                  
                       beq        .change_color
                       bra        .return
.change_color:
; resets flash timer
                       move.w     #TITLE_FLASH_DUR,title_flash_timer
; increases flash color index
                       add.w      #1,title_flash_color_idx
; if flash color index >= 2, resets to 0
                       cmp.w      #2,title_flash_color_idx
                       bge        .reset_idx
                       bra        .update_palette
.reset_idx:
                       clr.w      title_flash_color_idx
.update_palette:
                       move.w     title_flash_color_idx,d0
; multiplies index by array element length (2)
                       lsl.w      #1,d0
                       lea        title_flash_colors,a0
; reads array element pointed to index: contains new color
                       move.w     0(a0,d0.w),d1
; sets the new color in the palette
                       move.w     d1,title_palette+$06

.return:
                       movem.l    (sp)+,d0-a6
                       rts


