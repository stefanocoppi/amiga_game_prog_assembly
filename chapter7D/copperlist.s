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
; Graphics data
;****************************************************************

; segment loaded in CHIP RAM
         SECTION    graphics_data,DATA_C

         xdef       copperlist
copperlist:
         dc.w       DIWSTRT,$2c81
         dc.w       DIWSTOP,$2cc1
         dc.w       DDFSTRT,$3c
         dc.w       DDFSTOP,$d4
         dc.w       BPLCON1,0                                          
         dc.w       BPLCON2,0                                             
         dc.w       BPL1MOD,80                                             
         dc.w       BPL2MOD,80
            

  ; BPLCON0 ($100)
  ; bit 0: set to 1 to enable BLTCON3 register
  ; bit 2: interlaced mode
  ; bit 4: most significant bit of bitplane number
  ; bit 9: set to 1 to enable composite video output
  ; bit 12-14: least significant bits of bitplane number
  ; bit 15: hires mode
  ;                          5432109876543210
         dc.w       BPLCON0,%1100001000000100

         xdef       bplpointers
bplpointers:
         dc.w       $e0,0,$e2,0                  ; plane 1
         dc.w       $e4,0,$e6,0                  ; plane 2
         dc.w       $e8,0,$ea,0                  ; plane 3
         dc.w       $ec,0,$ee,0                  ; plane 4
         dc.w       $f0,0,$f2,0                  ; plane 5
         dc.w       $f4,0,$f6,0                  ; plane 6
         dc.w       $f8,0,$fa,0                  ; plane 7
         dc.w       $fc,0,$fe,0                  ; plane 8

palette  incbin     "gfx/image640.pal"           ; palette

         dc.w       $ffff,$fffe                  ; end of copperlist
