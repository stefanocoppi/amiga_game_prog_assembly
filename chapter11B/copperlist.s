;****************************************************************
; Copperlist
;
; (c) 2024 Stefano Coppi
;****************************************************************
            
              incdir     "include"
              include    "hw.i"
              include    "playfield.i"
              include    "hardware/custom.i"


;****************************************************************
; PUBLIC SYMBOLS
;****************************************************************
              xdef       copperlist
              xdef       bplpointers
              xdef       sprite_pointers
              xdef       bgnd_palette


;****************************************************************
; Graphics data
;****************************************************************

; segment loaded in CHIP RAM
              SECTION    graphics_data,DATA_C

              
              CNOP       0,8                          ; 64-bit alignment
copperlist:
              dc.w       DIWSTRT,$2c81                ; display window start at ($81,$2c)
              dc.w       DIWSTOP,$2cc1                ; display window stop at ($1c1,$12c)
              dc.w       DDFSTRT,$38                  ; display data fetch start at $38
              dc.w       DDFSTOP,$d0                  ; display data fetch stop at $d0
              dc.w       BPLCON1,0                                       
              dc.w       BPLCON2,%100100              ; sets sprites priority over playfield                                              
              dc.w       BPL1MOD,-8                   ; due to 64 bit fetch mode                         
              dc.w       BPL2MOD,-8
            

; BPLCON0 ($100)
; bit 0: set to 1 to enable BLTCON3 register
; bit 4: most significant bit of bitplane number
; bit 9: set to 1 to enable composite video output
; bit 12-14: least significant bits of bitplane number
;                                 5432109876543210
              dc.w       BPLCON0,%0000001000010001


; BPLCON4
; bit 0-3 palette selection for even sprites
; bit 4-7 palette selection for odd sprites
; we select palette 7 for both so %1110
              dc.w       BPLCON4,%11101110

; FMODE
; bit 0-1: 64 bit fetch mode
; bit 2-3: 64 pixel sprite width
              dc.w       FMODE,%1111

; Controls sprite-bitplane collisions
; bit 13: set to enable sprite 3
; bit 12: enable sprite 1
; bit 6-11: enable bitplanes 1-6
; bit 0-5: color index for collisions with playfield
;                                5432109876543210
              dc.w       CLXCON,%0011111111010001

bplpointers:
              dc.w       $e0,0,$e2,0                  ; plane 1
              dc.w       $e4,0,$e6,0                  ; plane 2
              dc.w       $e8,0,$ea,0                  ; plane 3
              dc.w       $ec,0,$ee,0                  ; plane 4
              dc.w       $f0,0,$f2,0                  ; plane 5
              dc.w       $f4,0,$f6,0                  ; plane 6
              dc.w       $f8,0,$fa,0                  ; plane 7
              dc.w       $fc,0,$fe,0                  ; plane 8


sprite_pointers:
              dc.w       SPR0PTH,0,SPR0PTL,0
              dc.w       SPR1PTH,0,SPR1PTL,0
              dc.w       SPR2PTH,0,SPR2PTL,0
              dc.w       SPR3PTH,0,SPR3PTL,0
              dc.w       SPR4PTH,0,SPR4PTL,0
              dc.w       SPR5PTH,0,SPR5PTL,0
              dc.w       SPR6PTH,0,SPR6PTL,0
              dc.w       SPR7PTH,0,SPR7PTL,0

bgnd_palette  incbin     "gfx/bgnd_256.pal"
palette       incbin     "gfx/ship.pal"


              dc.w       $ffff,$fffe                  ; end of copperlist