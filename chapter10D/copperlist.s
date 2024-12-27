;****************************************************************
; Copperlist
;
; (c) 2024 Stefano Coppi
;****************************************************************

         incdir     "include/"
         include    "hw.i"
         include    "map.i"

         
; segment loaded in CHIP RAM
         SECTION    graphics_data,DATA_C

         xdef       copperlist
copperlist:
         dc.w       DIWSTRT,$2c81                ; display window start at ($81,$2c)
         dc.w       DIWSTOP,$2cc1                ; display window stop at ($1c1,$12c)
         dc.w       DDFSTRT,$30                  ; display data fetch start at $30 to hide scrolling artifacts
         dc.w       DDFSTOP,$d0                  ; display data fetch stop at $d0
         dc.w       BPLCON1
         xdef       scrollx
scrollx  dc.w       $0000                        ; bits 0-7 scroll value

         dc.w       BPL1MOD,MAP_MOD-2            ; -2 because we fetch 16 more pixels                                          
         dc.w       BPL2MOD,MAP_MOD-2
            

  ; BPLCON0 ($100)
  ; bit 9: set to 1 to enable composite video output
  ; bit 12-14: bitplane number: 4 (%100)
  ;                          5432109876543210
         dc.w       BPLCON0,%0100001000000000
         dc.w       FMODE,0                      ; 16 bit fetch mode

         xdef       bplpointers
bplpointers:
         dc.w       $e0,0,$e2,0                  ; plane 1
         dc.w       $e4,0,$e6,0                  ; plane 2
         dc.w       $e8,0,$ea,0                  ; plane 3
         dc.w       $ec,0,$ee,0                  ; plane 4

palette:
         incbin     "gfx/map.pal"                ; background palette

         dc.w       $ffff,$fffe                  ; end of copperlist
