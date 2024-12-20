;****************************************************************
; Copperlist
;
; (c) 2024 Stefano Coppi
;****************************************************************
            
              incdir     "include"
              include    "hw.i"
              include    "playfield.i"
              include    "hardware/custom.i"

              xdef       bplpointers
              xdef       sprite_pointers
              xdef       bgnd_palette
            
;****************************************************************
; Graphics data
;****************************************************************

; segment loaded in CHIP RAM
              SECTION    graphics_data,DATA_C

              xdef       copperlist
copperlist:
              dc.w       DIWSTRT,$2c81                ; display window start at ($81,$2c)
              dc.w       DIWSTOP,$2cc1                ; display window stop at ($1c1,$12c)
              dc.w       DDFSTRT,$38                  ; display data fetch start at $38
              dc.w       DDFSTOP,$d0                  ; display data fetch stop at $d0
              dc.w       BPLCON1,0                                       
              dc.w       BPLCON2,%100100              ; sets sprites priority over playfield                                              
              dc.w       BPL1MOD,0                                         
              dc.w       BPL2MOD,0
            

  ; BPLCON0 ($100)
  ; bit 0: set to 1 to enable BLTCON3 register
  ; bit 4: most significant bit of bitplane number
  ; bit 9: set to 1 to enable composite video output
  ; bit 12-14: least significant bits of bitplane number
  ;                               5432109876543210
              dc.w       BPLCON0,%0100001000000000

  ; Controls sprite-bitplane collisions
  ; bit 12: enable sprite 1
  ; bit 6-9: enable bitplanes 1-4
  ; bit 0-5: color index for collisions with playfield
  ;                              5432109876543210
              dc.w       CLXCON,%0001001111001000

bplpointers:
              dc.w       $e0,0,$e2,0                  ; plane 1
              dc.w       $e4,0,$e6,0                  ; plane 2
              dc.w       $e8,0,$ea,0                  ; plane 3
              dc.w       $ec,0,$ee,0                  ; plane 4


sprite_pointers:
              dc.w       SPR0PTH,0,SPR0PTL,0
              dc.w       SPR1PTH,0,SPR1PTL,0
              dc.w       SPR2PTH,0,SPR2PTL,0
              dc.w       SPR3PTH,0,SPR3PTL,0
              dc.w       SPR4PTH,0,SPR4PTL,0
              dc.w       SPR5PTH,0,SPR5PTL,0
              dc.w       SPR6PTH,0,SPR6PTL,0
              dc.w       SPR7PTH,0,SPR7PTL,0

bgnd_palette  incbin     "gfx/bgnd.pal"
palette       incbin     "gfx/alien.pal"


              dc.w       $ffff,$fffe                  ; end of copperlist