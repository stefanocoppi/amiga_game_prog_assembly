;****************************************************************
; Takes and releases control of Amiga hardware.
;
; (c) 2024 Stefano Coppi
;****************************************************************

            IFND    TAKEOVER_I
TAKEOVER_I  SET     1



;****************************************************************
; CONSTANTS
;****************************************************************

; DMACON register settings
; enables blitter DMA (bit 6)
; enables only copper DMA (bit 7)
; enables bitplanes DMA (bit 8)
          ; 5432109876543210
DMASET equ %1000001111000000 

            ENDC  

  