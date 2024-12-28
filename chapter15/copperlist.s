;****************************************************************
; Copperlist
;
; (c) 2024 Stefano Coppi
;****************************************************************

         incdir     "include/"
         include    "hw.i"
         include    "playfield.i"

; segment loaded in CHIP RAM
         SECTION    graphics_data,DATA_C

         xdef       copperlist
copperlist:
         dc.w       DIWSTRT,$2c81                 ; display window start at ($81,$2c)
         dc.w       DIWSTOP,$2cc1                 ; display window stop at ($1c1,$12c)
         dc.w       DDFSTRT,$28                   ; display data fetch start at $28 to hide scrolling artifacts
         dc.w       DDFSTOP,$d0                   ; display data fetch stop at $d0
         dc.w       BPLCON1
         xdef       scrollx
scrollx  dc.w       $000f                         ; bits 0-3 scroll value of pf1

;                            5432109876543210
         dc.w       BPLCON2,%0000000001000000     ; priority to pf2

         dc.w       BPL1MOD,PF1_MOD-4             ; -4 because we fetch 32 more pixels                                          
         dc.w       BPL2MOD,PF2_MOD-4
            

  ; BPLCON0 ($100)
  ; bit 0: set to 1 to enable BLTCON3 register
  ; bit 4: most significant bit of bitplane number
  ; bit 9: set to 1 to enable composite video output
  ; bit 10: set to 1 to enable dual playfield mode
  ; bit 12-14: least significant bits of bitplane number
  ;                          5432109876543210
         dc.w       BPLCON0,%0000011000010000
         dc.w       FMODE,0                       ; 16 bit fetch mode

         xdef       bplpointers1
bplpointers1:
         dc.w       $e0,0,$e2,0                   ; plane 1
         dc.w       $e8,0,$ea,0                   ; plane 3
         dc.w       $f0,0,$f2,0                   ; plane 5
         dc.w       $f8,0,$fa,0                   ; plane 7

         xdef       bplpointers2
bplpointers2:
         dc.w       $e4,0,$e6,0                   ; plane 2
         dc.w       $ec,0,$ee,0                   ; plane 4
         dc.w       $f4,0,$f6,0                   ; plane 6
         dc.w       $fc,0,$fe,0                   ; plane 8

;                            5432109876543210
         dc.w       BPLCON3,%0001000000000000     ; offset 16 tra le palette dei due playfield

pf1_palette:
         incbin     "gfx/shooter_tiles_16.pal"    ; background palette

pf2_palette:
         incbin     "gfx/pf2_palette.pal"         ; foreground palette

         dc.w       $ffff,$fffe                   ; end of copperlist