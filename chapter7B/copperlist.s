;****************************************************************
; Copperlist
;
; (c) 2024 Stefano Coppi
;****************************************************************


;****************************************************************
; INCLUDES
;****************************************************************
         incdir     "include"
         include    "hw.i"


;****************************************************************
; GLOBAL SYMBOLS
;****************************************************************
         xdef       bplpointers


;****************************************************************
; Graphics data
;****************************************************************

; segment loaded in CHIP RAM
         SECTION    graphics_data,DATA_C

         xdef       copperlist
copperlist:
         dc.w       DIWSTRT,$2c71                ; display window start at ($71,$2c)
         dc.w       DIWSTOP,$2cd1                ; display window stop at ($1d1,$12c)
         dc.w       DDFSTRT,$30                  ; display data fetch start at $30
         dc.w       DDFSTOP,$d8                  ; display data fetch stop at $d8
         dc.w       BPLCON1,0                                          
         dc.w       BPLCON2,0                                             
         dc.w       BPL1MOD,0                                             
         dc.w       BPL2MOD,0
            

  ; BPLCON0 ($100)
  ; bit 0: set to 1 to enable BLTCON3 register
  ; bit 4: most significant bit of bitplane number
  ; bit 9: set to 1 to enable composite video output
  ; bit 12-14: least significant bits of bitplane number
  ;                          5432109876543210
         dc.w       BPLCON0,%0100001000000000

bplpointers:
         dc.w       $e0,0,$e2,0                  ; plane 1
         dc.w       $e4,0,$e6,0                  ; plane 2
         dc.w       $e8,0,$ea,0                  ; plane 3
         dc.w       $ec,0,$ee,0                  ; plane 4
         dc.w       $f0,0,$f2,0                  ; plane 5
         dc.w       $f4,0,$f6,0                  ; plane 6
         dc.w       $f8,0,$fa,0                  ; plane 7
         dc.w       $fc,0,$fe,0                  ; plane 8

palette  incbin     "gfx/image352.pal"           ; palette

         dc.w       $ffff,$fffe                  ; end of copperlist
