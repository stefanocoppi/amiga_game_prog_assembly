;****************************************************************
; HUD (Head Up Display)
;
; (c) 2024 Stefano Coppi
;****************************************************************

          xref       init_bplpointers
          xref       bplpointers_hud

          xdef       init_hud_plf

;****************************************************************
; CONSTANTS
;****************************************************************
HUD_WIDTH    equ 320
HUD_HEIGHT   equ 64
HUD_ROW_SIZE equ HUD_WIDTH/8
HUD_PLANE_SZ equ HUD_ROW_SIZE*HUD_HEIGHT
HUD_BPP      equ 5


;****************************************************************
; BSS DATA
;****************************************************************
          SECTION    bss_data,BSS_C

;hud_pf    ds.b       (HUD_PLANE_SZ*HUD_BPP)    ; playfield used for hud

;****************************************************************
; GRAPHICS DATA in chip ram
;****************************************************************
          SECTION    graphics_data,DATA_C

hud_bgnd  incbin     "gfx/hud_bgnd.raw"


;****************************************************************
; SUBROUTINES
;****************************************************************
          SECTION    code_section,CODE


;****************************************************************
; Initializes the hud playfield.
;****************************************************************
init_hud_plf:
          movem.l    d0-a6,-(sp)

    ; sets bitplane pointers to hud background image
          lea        bplpointers_hud,a1          
          move.l     #hud_bgnd,d0
          move.l     #HUD_PLANE_SZ,d1
          move.l     #HUD_BPP,d7
          jsr        init_bplpointers

          movem.l    (sp)+,d0-a6
          rts