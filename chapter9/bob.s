;************************************************************************
; Blitter Objects (Bobs) management
;
; (c) 2024 Stefano Coppi
;************************************************************************

  incdir     "include"
  include    "hw.i"

  SECTION    code_section,CODE

;************************************************************************
; Wait for the blitter to finish
;************************************************************************
  xdef       wait_blitter
wait_blitter:
.loop:
  btst.b     #6,DMACONR(a5)       ; if bit 6 is 1, the blitter is busy
  bne        .loop                ; and then wait until it's zero
  rts 