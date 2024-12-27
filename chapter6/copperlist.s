;****************************************************************
; Copperlist
;
; (c) 2024 Stefano Coppi
;****************************************************************


;****************************************************************
; Graphics data
;****************************************************************

; segment loaded in CHIP RAM
  SECTION    graphics_data,DATA_C

  xdef       copperlist
copperlist:
  ; BPLCON0 lowres video mode
  dc.w       $100,$0200
  ; puts blue value into COLOR0 register                
  dc.w       $0180,$000f
  ; WAIT line 192 ($c0)               
  dc.w       $c001,$fffe
  ; puts black value into COLOR0 register
  dc.w       $0180,$0000
  ; end of copperlist               
  dc.w       $ffff,$fffe 